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
    if word in @words
      false
    else
      @words.push(word)
      true

  addResult: (result) ->
    if @lastResult
      @prevResults.push(@lastResult)
    @lastResult = result

module.exports = Player