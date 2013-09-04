Game = require './game'
Player = require './player'

class Room

  constructor: (@socket) ->
    @created = new Date()
    @currentGame = undefined
    @players = {}
    @results = []
    @numPlayers = 0
    @timerId = undefined

    # TODO: Do we have default settings here?
    @settings =
      timeLimit: 90
      minWordLength: 3
      allowPlural: false
      negativePoints: false
      restartAllowed: true

  register: (userId) ->
    @players[userId] = new Player(userId)
    @numPlayers++
    @socket.emit('game', @currentGame.serialize()) if @currentGame

  leave: (userId) ->
    delete @players[userId]
    @numPlayers--

  createGame: (isRestart)->
    if isRestart
      oldGame = @currentGame
      @resetGame()
      oldGame.restart()
      @currentGame = oldGame
      @socket.emit('restart', @currentGame.serialize())
    else
      @resetGame()
      @currentGame = new Game(@settings)
      @socket.emit('game', @currentGame.serialize())

    setTimeout( =>
      @socket.emit('letters', @currentGame.getLetters())
      @timerId = setInterval( =>
        if @currentGame.getTimeRemaining() > 0
          @socket.emit('time', @currentGame.getTimeRemaining())
        else
          clearInterval(timerId)
          @socket.emit('results', @populateResults())
      , 1000)
    , @currentGame.startDelay)

  getGame: ->
    @currentGame

  ready: (userId) ->
    @players[userId].setReady()
    @checkReady()

  checkReady: ->
    for id, player of @players
      if not player.isReady()
        return
    @createGame()

  submitWord: (userId, word) ->
    result = @currentGame.checkWord(word) if @currentGame
    if result.success
      unless @players[userId].addWord(word)
        result.success = false
        result.error = 'duplicate word'
    result

  populateResults: ->
    playerResults = @currentGame.score(@players)
    result = new Result(@currentGame, playerResults)
    @results.push(result)
    @resetGame()
    playerResults

  resetGame: ->
    clearInterval(@timerId)
    @currentGame = undefined
    for id, player of @players
      player.reset()

  voteRestart: (userId) ->
    @players[userId].voteRestart()
    @checkRestart()

  checkRestart: ->
    console.log(@numPlayers)
    neededVotes = @numPlayers / 2
    numVotes = 0
    for id, player of @players
      if player.didVoteRestart()
        numVotes++

    console.log(neededVotes + '==' + numVotes)
    if numVotes >= neededVotes
      @createGame(true)

  # Go through one by one in case not all settings were supplied
  changeSettings: (settings) ->
    for name,value of settings
      @settings[name] = value


module.exports = Room

class Result
  constructor: (@game, @results) ->