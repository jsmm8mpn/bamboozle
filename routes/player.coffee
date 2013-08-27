class Player

  @ready = false
  @score = 0
  constructor: (@name) ->

  ready: ->
    @ready = true

  isReady: ->
    @ready

module.exports = Player