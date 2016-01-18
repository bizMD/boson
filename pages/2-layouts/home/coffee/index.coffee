$ = require 'jquery'

$ ->
	socket.on 'time left', (time) ->
		$('.timer').html "#{time}"
		$('.button').removeAttr 'disabled'

	socket.on 'end exam', ->
		$('.button').attr 'disabled', true