socket.emit 'authenticate user', localStorage.getItem 'user id'

require 'sugar'
$ = require 'jquery'
oboe = require 'oboe'

#loki = require 'lokijs'
#db = new loki
#questions.addCollection 'questions'

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
	$('input[type="radio"]:first').prop 'checked', true

renderTextbox = ->
	freetext = $ '<input>'
		.addClass 'freetext'
		.prop 'name', 'answer'
		.prop 'type', 'text'
		.prop 'placeholder', 'Enter your answer here'

	freetext.appendTo $ '.textbox'
	freetext.focus()

renderTextarea = ->
	textarea = $ '<textarea></textarea>'
		.addClass 'answer area'
		.prop 'name', 'answer'
		.prop 'placeholder', 'Enter your answer here'

	textarea.appendTo $ '.textarea'
	textarea.focus()

hideQuestion = ->
	$('.textbox')
		.addClass 'hidden'
		.empty()
	$('.textarea')
		.addClass 'hidden'
		.empty()
	$('.code').addClass 'hidden'
	$('.choices').empty()

recordAnswer = ->
	console.log 'Answer is being recorded...'
	textAnswer = $('input[name="answer"]')
	checkAnswer =  $('input[name="answer"]:checked')
	textArea = $('textarea.answer')
	#console.log textAnswer
	#console.log checkAnswer
	#console.log textArea
	answer = if textAnswer.length is 1 then textAnswer.val() else if checkAnswer.length is 1 then checkAnswer.val() else textArea.val()
	if not answer
		alert 'Must enter an answer'
		return false
	#console.log answer
	$.post '/submit',
		qid: qid
		answer: answer
		userid: localStorage.getItem 'user id'
	, ->
		if ++qid != questions.length
			hideQuestion()
			renderQuestion qid
		else
			window.location = '/end'

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
	if question.answer is 'textarea'
		$('.textarea').removeClass 'hidden'
		renderTextarea()
	if question.code?
		$('code').html question.code
		$('.code').removeClass 'hidden'

$ ->
	socket.on 'not authenticated', ->
		console.log 'Not authenticated'
		window.location = '/home'

	socket.on 'time left', (time) ->
		$('.timer').html "#{time}"

	socket.on 'end exam', ->
		window.location = '/home'

	$('.button').click ->
		console.log 'Answer is being provided...'
		textAnswer = $('input[name="answer"]')
		checkAnswer =  $('input[name="answer"]:checked')
		textArea = $('textarea.answer')
		#console.log textAnswer
		#console.log checkAnswer
		#console.log textArea
		answer = if textAnswer.length is 1 then textAnswer.val() else if checkAnswer.length is 1 then checkAnswer.val() else textArea.val()
		#console.log answer
		socket.emit 'user answer',
			qid: qid
			answer: answer
		recordAnswer()

	$(document).keypress (event) ->
		$('.button').click() if event.which == 13

	oboe '/question/test'
	.node '!.*', (module) ->
		questions.push module
	.done ->
		userid = localStorage.getItem 'user id'
		$.get '/question/current', {userid: userid}, (id) ->
			qid = id.toNumber()
			if qid == questions.length then window.location = '/end'
			else renderQuestion qid

	$('.number').html ('0000' + localStorage.getItem 'exam id').slice -4