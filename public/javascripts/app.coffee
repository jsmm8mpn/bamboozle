@timerId = undefined

@register = ->
  @socket.emit "register",
    roomId: @hangoutId
    userId: @userId
  , (data) ->
    if data
      setupGame data

@ready = ->
  clearResults()
  @socket.emit "ready"

@changeSettings = ->
  values = {}
  settings = $('.setting').each ->
    name = $(this).attr('name')
    if (name)
      settingValue = $(this).find('input')[0].value
      values[name] = settingValue

  @socket.emit 'settings', values

@setupGame = (game) ->
  startTimer game.timeLeft, game.timeLimit
  hide "startDiv"
  if game.letters
    onLetters(game.letters)

@onLetters = (letters) ->
  populateBoard letters
  displayBoard()
  show "quitDiv"

@voteQuit = ->
  hide "quitDiv"
  @socket.emit "voteRestart"

populateBoard = (letters) ->
  table = "<table>"
  y = 0

  while y < letters.length
    table += "<tr>"
    x = 0

    while x < letters[y].length
      table += "<td>" + letters[y][x] + "</td>"
      x++
    table += "</tr>"
    y++
  table += "</table>"
  $('#board').html(table)

displayBoard = ->
  show "mainDiv"
  show "wordInput"
  $("#wordInput").focus()

clearResults = ->
  clear "board"
  clear "wordList"
  clear "wordResult"
  clear "results"
  clear "timer"

  hide "results"
  show "mainDiv"

startTimer = (timeLeft, timeLimit) ->
  #console.log(timeLeft + ', ' + timeLimit)
  show "timer"
  @timerId = setInterval(->
    timeLeft = timeLeft - 1
    secondsLeft = timeLeft
    if secondsLeft > timeLimit
      secondsLeft = secondsLeft - timeLimit
    else $("#timer").toggleClass("timer-warn")  if secondsLeft < 15
    $("#timer").html(secondsLeft)
    timerExpired()  if secondsLeft is 0
  , 1000)

timerExpired = ->
  hide "quitDiv"
  hide "wordInput"
  #hide "results"
  clearInterval @timerId
  #getResults()

@updateTime = (time) ->
  console.log('time left: ' + time)

@submitWord = (e) ->
  if e and e.keyCode is 13
    word = $("#wordInput").val()

    @socket.emit "word", word, (result) ->
      if result.success
        $("#wordList").append("<li>" + word + "</li>")
        $("#wordResult").html("word is valid")
      else
        $("#wordResult").html(result.error)

    $("#wordInput").val("")

@writeResults = (results) ->
  html = ""
  for userId,result of results
    playerWords = result.words
    #playerWords.sort()
    html += "<div class=\"playerResult\">"
    html += "<h1>" + userId + "</h1>"

    for word,scored of playerWords
      if scored
        html += "<li class=\"scored\">" + word + "</li>"
      else
        html += "<li class=\"unscored\">" + word + "</li>"
    html += "<div class=\"score\">" + result.score + "</div>"
    html += "</div>"
  $("#results").html(html)
  hide "mainDiv"
  show "results"
  show "startDiv"
