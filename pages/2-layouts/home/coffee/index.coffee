$ = require 'jquery'

$ ->
	socket.on 'time left', (time) ->
		$('.timer').html "#{time}"

	socket.on 'begin exam', ->
		$('.button').removeAttr 'disabled'

	socket.on 'end exam', ->
		$('.button').attr 'disabled', true

	$('.button').click ->
		window.location = '/exam';