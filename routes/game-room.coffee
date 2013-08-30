Game = require './game'
Player = require './player'

class Room

  constructor: (@roomId) ->
    @created = new Date()
    @currentGame = undefined
    @players = {}
    @results = []
    @numPlayers = 0

  register: (userId) ->
    @players[userId] = new Player(userId)
    @numPlayers++

  leave: (userId) ->
    delete @players[userId]
    @numPlayers--

  createGame: ->
    @currentGame = new Game()

  getGame: ->
    @currentGame

  ready: (userId) ->
    @players[userId].setReady()
    @checkReady()

  checkReady: ->
    for id, player of @players
      if not player.isReady()
        return false
    return true

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
      true
    else
      false


module.exports = Room

class Result
  constructor: (@game, @results) ->