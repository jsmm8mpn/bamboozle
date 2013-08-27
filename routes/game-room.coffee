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
    @players[userId].ready()
    checkReady()

  checkReady = ->
    for id, player of @players
      if not player.isReady()
        return false
    return true

  submitWord: (userId, word) ->
    @currentGame.checkWord(word) if @currentGame

module.exports = Room