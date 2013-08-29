@timerId = undefined

@register = (callback) ->
  socket.emit "register",
    roomId: hangoutId
    userId: userId
  , (data) ->
    if data
      setupGame data
    else

    
    # startGameChecker();
    #callback result  if callback

@ready = ->
  clearResults()
  socket.emit "ready",
    roomId: hangoutId
    userId: userId


#startGameChecker();
@newGame = ->
  timeLimit = 90
  timeLimitField = document.getElementById("timeLimit")
  timeLimit = timeLimitField.value if timeLimitField
  game =
    hangoutId: hangoutId
    userId: userId
    timeLimit: timeLimit
    minWordLength: 3

  socket.emit "newGame", game

#
#function startGameChecker() {
#    var startGameChecker = setInterval(function() {
#        get('game?hangoutId='+hangoutId, function(result) {
#            if (result && result.start) {
#                clearInterval(startGameChecker);
#                setupGame(result);
#            }
#        });
#    }, 1000);
#}
#
@setupGame = (game) ->
  startTimer game.timeLeft, game.timeLimit
  hide "startDiv"
  if game.letters
    onLetters(game.letters)

  ###
  setTimeout (->
    get "letters?roomId=" + hangoutId, (letters) ->
      populateBoard letters
      displayBoard()
      show "quitDiv"

  ), (game.timeLeft - game.timeLimit) * 1000
  ###

@onLetters = (letters) ->
  populateBoard letters
  displayBoard()
  show "quitDiv"

@voteQuit = ->
  hide "quitDiv"
  socket.emit "quit",
    hangoutId: hangoutId
    userId: userId

populateBoard = (letters) ->
  board = document.getElementById("board")
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
  board.innerHTML = table

displayBoard = ->
  show "mainDiv"
  show "wordInput"
  document.getElementById("wordInput").focus()

clearResults = ->
  clear "board"
  clear "wordList"
  clear "wordResult"
  clear "results"
  clear "timer"

  hide "results"
  show "mainDiv"

startTimer = (timeLeft, timeLimit) ->
  console.log(timeLeft + ', ' + timeLimit)
  show "timer"
  @timerId = setInterval(->
    timeLeft = timeLeft - 1
    secondsLeft = timeLeft
    if secondsLeft > timeLimit
      secondsLeft = secondsLeft - timeLimit
    else document.getElementById("timer").className = "timer-warn"  if secondsLeft < 15
    document.getElementById("timer").innerHTML = secondsLeft
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
    word = document.getElementById("wordInput").value
    body =
      hangoutId: hangoutId
      userId: userId
      word: word

    socket.emit "word", body, (result) ->
      if result.success
        document.getElementById("wordList").innerHTML += "<li>" + word + "</li>"
        document.getElementById("wordResult").innerHTML = "word is valid"
      else
        document.getElementById("wordResult").innerHTML = result.error

    document.getElementById("wordInput").value = ""

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
  document.getElementById("results").innerHTML = html
  hide "mainDiv"
  show "results"
  show "startDiv"
