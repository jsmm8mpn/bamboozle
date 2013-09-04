class Player

  constructor: (@name) ->
    @ready = false
    @restart = false
    @score = 0
    @words = []
    @lastResult = undefined
    @prevResults = []
    @master = false

  setReady: ->
    @ready = true

  voteRestart: ->
    @restart = true

  isReady: ->
    @ready

  didVoteRestart: ->
    @restart

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

  reset: () ->
    @ready = false
    @restart = false
    @words = []

module.exports = Player