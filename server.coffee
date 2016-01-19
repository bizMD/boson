require 'sugar'
fs = require 'fs'
crypto = require 'crypto'
domain = require 'domain'
restify = require 'restify'
socketio = require 'socket.io'
{resolve, sep} = require 'path'

# Require the routes directory
requireDir = require 'require-dir'
require('coffee-script/register')
routes = requireDir 'routes', recurse: true

# Require the marko adapter
require('marko/node-require').install();

# Activate the domain
d = domain.create()
d.on 'error', (error) -> console.log error

# Create the database connection
#DB = require resolve 'db', 'DB.coffee'
#db = new DB

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
users = {}

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

server.get '/:name', (rq, rs, nx) ->
	{name} = rq.params
	rs.writeHead 200, {"Content-Type": "text/html"}
	template = resolve 'pages', '2-layouts', name, 'marko', 'template.marko'
	view  = require template
	view.render
		name: name
		active: active
		timer: timestyle timer
		options: [
			'test1'
			'test2'
			'test3'
			'test4'
			'test5'
		]
	, rs

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
		key = sessionKey()
		users[key] = socket
		socket.emit 'user id', {key: key, id: Object.size users}

	socket.on 'authenticate user', (id) ->
		console.log "Authentication requested: #{id}"
		if users[id] then socket.emit 'authenticated'
		else socket.emit 'not authenticated'

# Run the server under an active domain
d.run ->
	# Log when the web server starts up
	server.listen 80, -> console.log "#{server.name}[#{process.pid}] online: #{server.url}"
	console.log "#{server.name} is starting..."
