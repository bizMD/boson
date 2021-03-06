require 'sugar'
fs = require 'fs'
del = require 'del'
docco = require 'docco'
globby = require 'globby'
Promise = require 'bluebird'
coffeeify = require 'coffeeify'
browserify = require 'browserify'
{exec, spawn} = require 'child_process'
{watch} = require 'chokidar'
{resolve, sep, dirname, extname, basename} = require 'path'

option '-t', '--test', 'Does nothing'

spinServer = (server) ->
	if server?
		console.log "Server [pid #{server.pid}] is shutting down"
		process.kill server.pid, 'SIGTERM'
	server = spawn 'node' , ['node_modules/coffee-script/bin/coffee' , 'server.coffee']
	console.log "Server [pid #{server.pid}] is starting up"
	server.on 'error', (err) -> throw err if err?
	server.stdout.on 'data', (data) -> console.log data.toString()
	server.stderr.on 'data', (data) -> console.log data.toString()
	server.on 'exit', -> console.log "Server [pid #{server.pid}] has shut down"
	server

task 'docs', 'Create documentation for the source code', ->
	docco_cmd = "node node_modules/docco/bin/docco --layout linear"
	globby ['Cakefile', 'server.coffee']
	.then (paths) ->
		for path in paths
			pathDir = dirname path
			docco_cmd += " -o docs/#{pathDir} #{path}"
		exec docco_cmd, (error, stdout, stderr) ->
			reject error if error?
	.catch (error) ->
		console.log 'ERROR! Could not generate documents'
		console.log error

task 'clean', 'Remove all the built JS, CSS files', ->
	del ['pages/**/build/*', '!**/.gitkeep', 'db/loki.db']
	.then (paths) ->
		console.log "Deleting file: #{path}" for path in paths
	.catch (error) ->
		console.log 'ERROR! Could not clean build'
		console.log error

task 'style', 'Compile SCSS into CSS', ->
	console.log 'Compiling SCSS files...'
	sass_cmd = "sass -r sass-globbing styles.scss ../build/styles.css"
	globby ['**/styles.scss']
	.then (paths) ->
		#new Promise (done, reject) ->
		for path, index in paths
			sass_dir = dirname path
			console.log "SCSS to CSS: #{path}"
			exec sass_cmd, cwd: sass_dir#, (error) ->
				#reject error if error?
				#done() if index -= 1 is 0

task 'script', 'Compile Coffeescript into JS', ->
	console.log 'Compiling CoffeeScript files...'
	browserify_cmd = 'browserify -t coffeeify --extension=".coffee" -o '
	globby ['pages/**/index.coffee', '!*/0-vendor/**']
	.then (paths) ->
		#new Promise (done, reject) ->
		for path, index in paths
			run = browserify_cmd
			.concat resolve path, '../..', 'build'
			.concat "#{sep}index.js "
			.concat path
			console.log "Coffee to JS: #{path}"
			exec run#, (error) ->
				#reject error if error?
				#done() if index -= 1 is 0

task 'minify', 'Minify all index.js and styles.css files', ->
	console.log 'Minifying all index.js and styles.css files'

	minifyjs_cmd = 'minify index.js'
	globby ['pages/**/index.js']
	.then (paths) -> exec minifyjs_cmd, cwd: dirname path for path in paths
	
	minifycss_cmd = 'minify styles.css'
	globby ['pages/**/styles.css']
	.then (paths) -> exec minifycss_cmd, cwd: dirname path for path in paths

task 'build', 'Compile CSS and JS at the same time', ->
	invoke 'clean'
	.then ->
		(->
			Promise.join (invoke 'style'), (invoke 'script')
			.then ->
				(-> invoke 'minify').delay 5000
		).delay 5000
	.catch (error) ->
		console.log 'ERROR! Could not build'
		console.log error

task 'test', 'Run unit tests with Mocha, Chai, and Zombie', ->
	console.log 'Not yet implemented'

task 'benchmark', 'Run performance tests with Matcha', ->
	console.log 'Not yet implemented'

task 'watch', 'Reset the server on file change', ->
	server = spinServer()
	reboot = (path) ->
		console.log "Change detected in #{path}"
		server = spinServer server
	eyes = watch ['server.coffee', 'pages/**']
	eyes.on 'change', (path) -> reboot 'server.coffee'