require 'sugar'
fs = require 'fs'
crypto = require 'crypto'
domain = require 'domain'
restify = require 'restify'
socketio = require 'socket.io'
querystring = require 'querystring'
{resolve, sep} = require 'path'

# Require the routes directory
requireDir = require 'require-dir'
require('coffee-script/register')
routes = requireDir 'routes', recurse: true

# Create event emitter class
{EventEmitter} = require 'events'
class EventedIO extends EventEmitter
eventio = new EventedIO

# Require the marko adapter
require('marko/node-require').install();

# Activate the domain
d = domain.create()
d.on 'error', (error) -> console.log error

# Create the database connection
DB = require resolve 'db', 'DB.coffee'
db = new DB

# Create the web server and use middleware
server = restify.createServer name: 'Boson'
server.use restify.bodyParser()
server.pre restify.pre.sanitizePath()
server.use restify.CORS()
server.use restify.fullResponse()

io = socketio.listen server.server

# Status of the exam
active = false
timer = 15 * 60 * 1000

sessionKey = ->
    sha = crypto.createHash 'sha256'
    sha.update Math.random().toString()
    sha.digest 'hex'

timestyle = (timer) ->
	time = timer/1000
	minutes = Math.floor time/60
	seconds = time - minutes * 60
	seconds2 = if seconds < 10 then "0#{seconds}" else seconds
	"#{minutes}:#{seconds2}"

timekeep = ->
	timer -= 1000
	io.emit 'time left', timestyle timer
	timekeep.delay 1000 if timer != 0
	timestop() if timer == 0

timestop = ->
	io.emit 'end exam'
	active = false
	timekeep.cancel()
	timer = 0

# Redirect to home if accessing root
server.get '/', (rq, rs, nx) -> rs.redirect '/home', nx

# Serve layout CSS and JS
server.get '/layouts/:name/:type', (args...) -> routes.utils.serveLayouts args

##
#Temp var to store the questions
##
fs = require 'fs'

server.get '/question/test', (rq, rs, nx) ->
	rs.writeHead 200, {"Content-Type": "application/json"}
	q = fs.createReadStream './db/questions.json'
	q.pipe rs

server.get '/question/current', (rq, rs, nx) ->
	{userid} = querystring.parse rq.query()
	rs.writeHead 200, {"Content-Type": "application/json"}
	answers = db.getCollection 'answers'
	answered = answers
				.chain()
				.find user: userid
				.simplesort 'qid'
				.data()
	if answered.isEmpty() then rs.end '0'
	else
		qid = 1 + answered.last()?.qid.toNumber()
		rs.end "#{qid}"
	nx()

server.get '/:name', (rq, rs, nx) ->
	{name} = rq.params
	# Cannot take exam if time is over, test is inactive
	rs.redirect '/home', nx if name == 'exam' and (timer == 0 or active == false)
	rs.writeHead 200, {"Content-Type": "text/html"}
	template = resolve 'pages', '2-layouts', name, 'marko', 'template.marko'
	view  = require template
	view.render
		name: name
		active: active
		timer: timestyle timer
	, rs

server.post '/submit', (rq, rs, nx) ->
	rs.writeHead 200, {"Content-Type": "text/html"}
	{qid, answer, userid} = rq.params
	answers = db.getCollection 'answers'
	users = db.getCollection 'users'
	user = users.findOne key: userid
	record =
		qid: qid
		answer: answer
		user: user.key
	answers.insert record
	eventio.emit 'insert to answers collection', record
	rs.end()

io.sockets.on 'connection', (socket) ->
	console.log 'a user connected'

	socket.on 'toggle exam', ->
		return false if timer == 0
		active = !active
		switch active
			when true
				socket.broadcast.emit 'begin exam', true
				timekeep()
			when false then timestop()

	socket.on 'user registered', ->
		# Super no security method
		users = db.getCollection 'users'
		key = sessionKey()
		id = users.data.length
		record =
			key: key
			id: id
		users.insert record
		socket.emit 'user id', record

	socket.on 'authenticate user', (id) ->
		users = db.getCollection 'users'
		user = users.find {key: id}
		console.log "Authentication requested: #{id}"
		if not user.isEmpty() then socket.emit 'authenticated'
		else socket.emit 'not authenticated'

	socket.on 'admin authenticate', ->
		console.log 'Admin authenticated'
		eventio.on 'insert to answers collection', (data) ->
			users = db.getCollection 'users'
			user = users.findOne key: data.user
			pack = Object.reject data, 'meta', '$loki'
			pack.user = user.id
			console.log pack
			socket.emit 'user answered', pack

	socket.on 'checked user submission', (data) ->
		{qid, user, answer, checked} = data
		scores = db.getCollection 'scores'
		scores.insert
			qid: qid
			answer: answer
			user: user
			checked: checked

	socket.on 'request for user score', (id) ->
		scores = db.getCollection 'scores'
		score = answers.find user: id
		console.log score

	socket.on 'disconnect', ->
		console.log 'A user disconnected...'

# Run the server under an active domain
d.run ->
	# Log when the web server starts up
	server.listen 80, -> console.log "#{server.name}[#{process.pid}] online: #{server.url}"
	console.log "#{server.name} is starting..."