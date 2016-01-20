socket.emit 'authenticate user', localStorage.getItem 'user id'

$ = require 'jquery'

$ ->
	socket.on 'time left', (time) ->
		$('.timer').html "#{time}"

	socket.on 'end exam', ->
		socket.emit 'request for user score', localStorage.getItem 'user id'