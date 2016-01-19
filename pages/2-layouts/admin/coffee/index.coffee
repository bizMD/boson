$ = require 'jquery'

toggleActivity = (active) ->
	switch active
		when 'Start'
			$('.status').html 'active'
			$('.toggle').html 'conclude'
			$('.button').html 'Stop'
		when 'Stop'
			$('.status').html 'inactive'
			$('.toggle').html 'enable'
			$('.button').html 'Start'

concludeActivity = ->
	$('.button').remove()
	$('.instructions').remove()
	$('.status').html 'concluded'
	$('.timer').html '0:00'

$ ->
	socket.on 'time left', (time) ->
		$('.timer').html "#{time}"

	socket.on 'end exam', ->
		concludeActivity()

	$('.button').click ->
		return false if $('.timer').html() is '0:00'
		socket.emit 'toggle exam', true
		toggleActivity $('.button').html()