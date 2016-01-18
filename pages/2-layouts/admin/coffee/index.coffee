$ = require 'jquery'

toggleActivity = (active) ->
	switch active
		when 'Enable'
			$('.status').html 'active'
			$('.toggle').html 'disable'
			$('.button').html 'Disable'
		when 'Disable'
			$('.status').html 'inactive'
			$('.toggle').html 'enable'
			$('.button').html 'Enable'

$ ->
	socket.on 'time left', (time) ->
		$('.timer').html "#{time}"

	socket.on 'cannot toggle', (time) ->
		console.log 'Cannot toggle'

	socket.on 'end exam', ->
		toggleActivity 'Disable'

	$('.button').click ->
		return false if $('.timer').html() is '0:00'
		socket.emit 'toggle exam', true
		toggleActivity $('.button').html()