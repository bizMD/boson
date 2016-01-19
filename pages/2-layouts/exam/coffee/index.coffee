socket.emit 'authenticate user', localStorage.getItem 'user id'
localStorage.setItem 'answer responses', []

$ = require 'jquery'
oboe = require 'oboe'
questions = []
qid = 0

renderChoices = (choices) ->
	for choice in choices
		input = $ '<input>'
			.addClass 'radio'
			.prop 'name', 'answer'
			.prop 'type', 'radio'
			.prop 'id', choice
			.prop 'value', choice

		label = $ '<label></label>'
			.addClass 'label'
			.prop 'for', choice
			.html choice

		choice = $ '<div>'
			.addClass 'choice'

		input.appendTo choice
		label.appendTo choice
		choice.appendTo $ '.choices'

hideQuestion = ->
	$('.textbox').addClass 'hidden'
	$('.freetext').val ''
	$('.code').addClass 'hidden'
	$('.choices').empty()

recordAnswer = ->


renderQuestion = (num) ->
	question = questions[num]
	$('.section').html question.section.toUpperCase()
	$('.text').html question.question
	if question.answer is 'text'
		$('.textbox').removeClass 'hidden'
	if question.answer is 'choices'
		$('.choices').removeClass 'hidden'
		renderChoices question.choices
	if question.code?
		$('code').html question.code
		$('.code').removeClass 'hidden'

$ ->
	socket.on 'not authenticated', ->
		window.location = '/home'

	socket.on 'time left', (time) ->
		$('.timer').html "#{time}"

	$('.button').click ->
		answer = $('input[name="answer"]').val()
		socket.emit 'user answer',
			qid: qid
			answer: answer
		if qid + 1 != questions.length
			recordAnswer()
			hideQuestion()
			renderQuestion ++qid
		else
			console.log 'End the quiz'

	oboe '/question/test'
	.node '!.*', (module) ->
		questions.push module
	.done -> renderQuestion qid

	$('.number').html '0000' + localStorage.getItem 'exam id'