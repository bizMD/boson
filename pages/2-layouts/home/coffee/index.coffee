###
commenced = localStorage.getItem 'user id'
if commenced is
	window.location = '/exam'
###

require 'sugar'
$ = require 'jquery'

$ ->
	socket.on 'begin exam', ->
		$('.button').prop 'disabled', false
		$('.button').html 'Start Test'

	socket.on 'time left', (time) ->
		$('.timer').html "#{time}"

	socket.on 'end exam', ->
		$('.button').prop 'disabled', true
		$('.button').html 'Test Is Over'
		$('.timer').html '0:00'

	socket.on 'user id', (id) ->
		localStorage.setItem 'user id', id.key
		localStorage.setItem 'exam id', id.id
		(-> window.location = '/exam').delay 100

	$('.button').click ->
		socket.emit 'user registered'