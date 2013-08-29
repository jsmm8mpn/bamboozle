Game = require './game'
Player = require './player'

class Room

  constructor: (@roomId) ->
    @created = new Date()
    @currentGame = undefined
    @players = {}
    @results = []

  register: (userId) ->
    @players[userId] = new Player(userId)

  leave: (userId) ->
    delete @players[userId]

  createGame: ->
    @currentGame = new Game()

  getGame: ->
    @currentGame

  ready: (userId) ->
    @players[userId].setReady()
    checkReady()

  checkReady = ->
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
    @currentGame = undefined
    for id, player of @players
      player.reset()
    playerResults

module.exports = Room

class Result
  constructor: (@game, @results) ->