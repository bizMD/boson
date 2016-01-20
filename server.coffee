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
#DB = require resolve 'db', 'DB.coffee'
loki = require 'lokijs'
db = new loki 'db/loki.db'
db.addCollection 'answers'
db.addCollection 'users'

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
adminSocket = {}

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

server.get '/question/answered', (rq, rs, nx) ->
	rs.writeHead 200, {"Content-Type": "application/json"}
	answers = db.getCollection 'answers'
	users = db.getCollection 'users'
	answer = answers
			.chain()
			.where (item) -> not item.checked?
			.simplesort 'qid'
			.data()
	for ans in answer
		pack = Object.reject ans, 'meta', '$loki'
		user = users.findOne key: ans.user
		pack.user = user.id
		console.log JSON.stringify pack
		rs.write JSON.stringify pack
	rs.end()

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
	console.log 'Getting all the params'
	console.log rq.params
	answers = db.getCollection 'answers'
	users = db.getCollection 'users'
	console.log 'Finding the one user'
	user = users.findOne key: userid
	console.log user
	console.log 'Preparing the record'
	record =
		qid: qid
		answer: answer
		user: user.key
	answers.insert record
	console.log 'Inserted record into collection'
	console.log record
	eventio.emit 'insert to answers collection', record
	console.log 'Notified internal emitter of insert event'
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
		adminSocket = socket if Object.equal adminSocket, {}

	socket.on 'checked user submission', (data) ->
		{qid, user, answer, checked} = data
		#scores = db.getCollection 'scores'
		answers = db.getCollection 'answers'
		ans = answers.findOne
			qid: qid
			answer: answer
			user: user
		ans['checked'] = checked

		test = answers.find
			qid: qid
			answer: answer
			user: user
		console.log test
		###
		scores.insert
			qid: qid
			answer: answer
			user: user
			checked: checked
		###
		answers.update ans
		#console.log scores.data
		console.log ans

	socket.on 'request for user score', (id) ->
		console.log 'User requested their score'
		answers = db.getCollection 'answers'
		console.log 'Answers collection gotten'
		answer = answers.chain().find user: id
		wrongs = answer.copy().find(checked: 'Incorrect').data()
		rights = answer.copy().find(checked: 'Correct').data()
		console.log 'Answer found. Here it is:'
		console.log answer
		console.log rights
		console.log wrongs
		socket.emit 'correctly answered questions', rights
		socket.emit 'incorrectly answered questions', wrongs

	socket.on 'error', (error) ->
		console.warn error

	socket.on 'disconnect', ->
		console.log 'A user disconnected...'

eventio.on 'insert to answers collection', (data) ->
	users = db.getCollection 'users'
	user = users.findOne key: data.user
	pack = Object.reject data, 'meta', '$loki'
	pack.user = user.id
	console.log 'Insert to answers collection'
	console.log pack
	adminSocket.emit 'user answered', pack

# Run the server under an active domain
d.run ->
	# Log when the web server starts up
	server.listen 80, -> console.log "#{server.name}[#{process.pid}] online: #{server.url}"
	console.log "#{server.name} is starting..."