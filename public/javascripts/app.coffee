@register = (callback) ->
  socket.emit "register",
    hangoutId: hangoutId
    userId: userId
  , (data) ->
    if result and result.start
      setupGame result
    else

    
    # startGameChecker();
    callback result  if callback

  setInterval (->
    socket.emit "ping",
      hangoutId: hangoutId
      userId: userId

  ), 10000

@ready = ->
  clearResults()
  socket.emit "ready",
    hangoutId: hangoutId
    userId: userId


#startGameChecker();
@newGame = ->
  timeLimit = 90
  timeLimitField = document.getElementById("timeLimit")
  timeLimit = timeLimitField.value  if timeLimitField
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
setupGame = (game) ->
  startTimer game.timeLeft, game.timeLimit
  hide "startDiv"
  setTimeout (->
    get "letters?hangoutId=" + hangoutId, (letters) ->
      populateBoard letters
      displayBoard()
      show "quitDiv"

  ), (game.timeLeft - game.timeLimit) * 1000
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
  hide "results"
  show "mainDiv"
  show "wordInput"
  document.getElementById("wordInput").focus()
clearResults = ->
  clear "board"
  clear "wordList"
  clear "wordResult"
  clear "results"
  clear "timer"
startTimer = (timeLeft, timeLimit) ->
  show "timer"
  timerId = setInterval(->
    timeLeft = timeLeft - 1
    if timeLeft % 5 is 0
      get "time?hangoutId=" + hangoutId, (result) ->
        if result
          timeLeft = result
        else
          timerExpired()

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
  clearInterval timerId
  getResults()
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
@getResults = ->
  get "results?hangoutId=" + hangoutId, (result) ->
    writeResults result

writeResults = (results) ->
  html = ""
  for userId of results
    result = results[userId]
    playerWords = result.words
    playerWords.sort()
    html += "<div class=\"playerResult\">"
    html += "<h1>" + userId + "</h1>"
    wNum = 0

    while wNum < playerWords.length
      word = playerWords[wNum]
      if result.scoredWords[word]
        html += "<li class=\"scored\">" + word + "</li>"
      else
        html += "<li class=\"unscored\">" + word + "</li>"
      wNum++
    html += "<div class=\"score\">" + result.score + "</div>"
    html += "</div>"
  document.getElementById("results").innerHTML = html
  hide "mainDiv"
  show "results"
  show "startDiv"
@timerId = undefined