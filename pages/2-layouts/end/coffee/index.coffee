socket.emit 'authenticate user', localStorage.getItem 'user id'

require 'sugar'
$ = require 'jquery'

$ ->
	socket.on 'time left', (time) ->
		$('.timer').html "#{time}"

	socket.on 'not authenticated', ->
		window.location = '/'

	socket.on 'correctly answered questions', (data) ->
		console.log data
		$('.score').html data.length
		$('.items').html $('.total').html().toNumber() + data.length

	socket.on 'incorrectly answered questions', (data) ->
		console.log data
		$('.items').html $('.total').html().toNumber() + data.length

	socket.on 'end exam', ->
		console.log 'End exam was fired!'
		socket.emit 'request for user score', localStorage.getItem 'user id'
		console.log 'Requested for user score!'
		$('.timer').html '0:00'
		localStorage.removeItem 'user id'
		localStorage.removeItem 'exam id'
		$('.instructions').remove()
		$('.congratulations').removeClass 'hidden'