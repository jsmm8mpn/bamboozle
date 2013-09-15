class Player

  constructor: (@name, @displayName) ->
    @ready = false
    @restart = false
    @score = 0
    @words = []
    @lastResult = undefined
    @prevResults = []

  serialize: ->
    res =
      name: @displayName
      ready: @ready
      restart: @restart
      score: @score

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