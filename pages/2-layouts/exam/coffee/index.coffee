socket.emit 'authenticate user', localStorage.getItem 'user id'

$ = require 'jquery'
oboe = require 'oboe'

#loki = require 'lokijs'
#db = new loki
#questions.addCollection 'questions'

questions = []

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

renderTextbox = ->
	freetext = $ '<input>'
		.addClass 'freetext'
		.prop 'name', 'answer'
		.prop 'type', 'text'
		.prop 'placeholder', 'Enter your answer here'

	freetext.appendTo $ '.textbox'

hideQuestion = ->
	$('.textbox')
		.addClass 'hidden'
		.empty()
	$('.code').addClass 'hidden'
	$('.choices').empty()

recordAnswer = ->
	textAnswer = $('input[name="answer"]')
	checkAnswer =  $('input[name="answer"]:checked')
	answer = if textAnswer.length is 1 then textAnswer.val() else checkAnswer.val()
	$.post '/submit',
		qid: qid
		answer: answer
		userid: localStorage.getItem 'user id'
	, ->
		hideQuestion()
		renderQuestion ++qid

renderQuestion = (num) ->
	question = questions[num]
	$('.section').html question.section.toUpperCase()
	$('.text').html question.question
	if question.answer is 'text'
		$('.textbox').removeClass 'hidden'
		renderTextbox()
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
		textAnswer = $('input[name="answer"]')
		checkAnswer =  $('input[name="answer"]:checked')
		answer = if textAnswer.length is 1 then textAnswer.val() else checkAnswer.val()
		socket.emit 'user answer',
			qid: qid
			answer: answer
		if qid + 1 != questions.length then recordAnswer()
		else console.log 'End the quiz'

	oboe '/question/test'
	.node '!.*', (module) ->
		questions.push module
	.done ->
		$.get '/question/current', userid: localStorage.getItem 'user id', (qid) ->
			renderQuestion qid

	$('.number').html ('0000' + localStorage.getItem 'exam id').slice -4