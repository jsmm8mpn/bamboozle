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
    @currentGame.score(@players)

module.exports = Room