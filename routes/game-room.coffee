Game = require './game'
Player = require './player'

class Room

  constructor: (@name, @socket) ->
    @created = new Date()
    @currentGame = undefined
    @players = {}
    @results = []
    @numPlayers = 0
    @timerId = undefined
    @master = undefined
    @public = false

    # TODO: Do we have default settings here?
    @settings =
      timeLimit: 90
      minWordLength: 3
      allowPlural: false
      negativePoints: false
      restartAllowed: true

  serialize: ->
    return {
      name: @name
      settings: @settings
      numPlayers: @numPlayers
      active: (@currentGame != undefined)
    }

  register: (player) ->
    #if @players[userId]
    #  throw new Error 'username is already taken'
    userId = player.name
    @players[userId] = player #new Player(userId)
    if not @master
      @setMaster(userId)
    @numPlayers++

    #FIXME: This wont' work because it will emit to everyone
    @socket.emit('game', @currentGame.serialize()) if @currentGame
    @sendPlayerUpdate()

  setMaster: (userId) ->
    console.log('changing master to: ' + userId)
    if @master
      @players[@master].master = false
    @master = userId
    @players[userId].master = true

  leave: (userId) ->
    delete @players[userId]
    @numPlayers--
    if @master == userId and @numPlayers > 0
      @setMaster(Object.keys(@players)[0])
    else
      @master = undefined
    @sendPlayerUpdate()

  restart: ->
    oldGame = @currentGame
    @resetGame()
    oldGame.restart()
    @currentGame = oldGame
    @socket.emit('restart', @currentGame.serialize())
    @startGame()

  createGame: ->
    #@resetGame()
    @currentGame = new Game(@settings)
    @socket.emit('game', @currentGame.serialize())
    @startGame()

  startGame: ->
    setTimeout( =>
      @socket.emit('letters', @currentGame.getLetters())
      @timerId = setInterval( =>
        if @currentGame.getTimeRemaining() > 0
          @socket.emit('time', @currentGame.getTimeRemaining())
        else
          @socket.emit('results', @populateResults())
          @resetGame()
      , 5000)
    , @currentGame.startDelay)

  getGame: ->
    @currentGame

  ready: (userId) ->
    @players[userId].setReady()
    @sendPlayerUpdate()
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
    playerResults

  resetGame: ->
    clearInterval(@timerId)
    @currentGame = undefined
    for id, player of @players
      player.reset()
    @sendPlayerUpdate()

  voteRestart: (userId, value) ->
    @players[userId].voteRestart(value)
    @sendPlayerUpdate()
    @checkRestart()

  checkRestart: ->
    neededVotes = @numPlayers / 2
    numVotes = 0
    for id, player of @players
      if player.didVoteRestart()
        numVotes++

    if numVotes > neededVotes
      @restart()

  # Go through one by one in case not all settings were supplied
  changeSettings: (settings) ->
    console.log('changing settings: ' + JSON.stringify(settings))
    for name,value of settings
      @settings[name] = value
    @socket.emit('settings', settings)

  changeMaster: (userId) ->
    @setMaster(userId)
    @sendPlayerUpdate()

  startNow: ->
    @createGame()

  endNow: ->
    @resetGame()

  kickOut: (userId) ->
    leave(userId)

  sendPlayerUpdate: ->
    players = {}
    for id, player of @players
      players[id] = player.serialize()
    @socket.emit('players', players)

module.exports = Room

class Result
  constructor: (@game, @results) ->