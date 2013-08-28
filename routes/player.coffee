class Player

  constructor: (@name) ->
    @ready = false
    @score = 0
    @words = []
    @lastResult = undefined
    @prevResults = []

  setReady: ->
    @ready = true

  isReady: ->
    @ready

  addWord: (word) ->
    @words.push(word)

  addResult: (result) ->
    if @lastResult
      @prevResults.push(@lastResult)
    @lastResult = result

module.exports = Player