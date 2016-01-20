require 'sugar'
$ = require 'jquery'
oboe = require 'oboe'

toggleActivity = (active) ->
	switch active
		when 'Start'
			$('.status').html 'now ongoing'
			$('.toggle').html 'conclude'
			$('.button').html 'Stop the Exam'
		when 'Stop'
			$('.status').html 'inactive'
			$('.toggle').html 'enable'
			$('.button').html 'Start'

concludeActivity = ->
	$('.button').remove()
	$('.instructions').remove()
	$('.status').html 'now concluded'
	$('.timer').html '0:00'

createBlock = (data) ->
	{qid, answer, user} = data
	console.log data

	console.log 'Creating the block'
	block = $ '<div></div>'
			.addClass 'block'
	
	console.log 'Creating the qidSpan'
	qidSpan = $ '<span></span>'
			.html qid
			.addClass 'qid'
	console.log 'Creating the qidHolder'
	qidHolder = $ '<div></div>'
			.addClass 'lefty'
			.html 'QID: '
	console.log 'Appending qidSpan to qidHolder'
	qidSpan.appendTo qidHolder

	console.log 'Creating the userSpan'
	userSpan = $ '<span></span>'
			.html user
			.addClass 'user'
	console.log 'Creating the userHolder'
	userHolder = $ '<div></div>'
			.addClass 'righty'
			.html 'User: '
	console.log 'Appending userSpan to userHolder'
	userSpan.appendTo userHolder

	console.log 'Creating the answerSpan'
	answerSpan = $ '<span></span>'
			.html answer
			.addClass 'answer'
	console.log 'Creating the answerHolder'
	answerHolder = $ '<div></div>'
			.addClass 'answerText'
			.html 'Their Answer: <br/>'
	console.log 'Appending answerSpan to answerHolder'
	answerSpan.appendTo answerHolder

	correct = $ '<div></div>'
			.addClass 'correct submission'
			.html 'Correct'
	incorrect = $ '<div></div>'
			.addClass 'incorrect submission'
			.html 'Incorrect'
	checker = $ '<div></div>'
			.addClass 'checker'
	correct.appendTo checker
	incorrect.appendTo checker

	qidHolder.appendTo block
	userHolder.appendTo block
	answerHolder.appendTo block
	checker.appendTo block

	block.appendTo $ '.checking'

createBadge = (data) ->
	badge = $ '<div></div>'
		.addClass 'examinee badge'

	id = $ '<span></span>'
		.addClass 'badge id'
		.html data.id
	idVal = $ '<div></div>'
		.addClass 'badge id value'
		.html 'Examinee ID: '

	score = $ '<span></span>'
		.addClass 'badge score'
		.html '0'
	scoreVal = $ '<div></div>'
		.addClass 'badge score value'
		.html 'Score: '

	id.appendTo idVal
	idVal.appendTo badge
	score.appendTo scoreVal
	scoreVal.appendTo badge

	badge.appendTo $ '.examinee.scoreboard'

$ ->
	socket.on 'time left', (time) ->
		$('.timer').html "#{time}"

	socket.on 'end exam', ->
		concludeActivity()

	socket.on 'authentication failed', (message) ->
		console.log message

	socket.on 'user answered', (data) ->
		createBlock data
		console.log data

	socket.on 'new user registered', (data) ->
		console.log data
		createBadge data

	socket.on 'update user score', (user) ->
		score = $ '.examinee.scoreboard'
				.find ".badge.id:contains('#{user}')"
				.parent()
				.find '.badge.score'
				.children()
		score.html score.html().toNumber() + 1

	socket.emit 'admin authenticate'

	$('body').on 'click', '.submission', ->
		checked = $(this).html()
		parent = $(this).parent().parent()
		qid = parent.find('.qid').html()
		user = parent.find('.user').html()
		answer = parent.find('.answer').html()
		socket.emit 'checked user submission',
			qid: qid
			user: user
			answer: answer
			checked: checked
		parent.remove()

	$('.button').click ->
		return false if $('.timer').html() is '0:00'
		socket.emit 'toggle exam', true
		toggleActivity $('.button').html()

	oboe '/question/answered'
	.done (data) ->
		size = Object.size data
		console.log data
		createBlock data if size > 0