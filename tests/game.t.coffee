assert = require('chai').assert
Game = require '../routes/game'

describe 'Regular Game', ->

  options =
    timeLimit: 99
    startDelay: 100
    letters: [['A','B','C','D'],['E','F','G','H'],['I','J','K','L'],['N','M','O','P']]

  game = new Game(options)
  game2 = new Game(
    timeLimit: 101
  )
  it 'should have a time limit of 99', ->
    assert.equal(game.timeLimit, 99)
  it 'should not have letters yet', ->
    assert.isUndefined(game.serialize().letters)
  it 'should have time left greater than 99', ->
    assert(game.getTimeRemaining() > 99)
  it 'should have letters now', (done) ->
    setTimeout( ->
      assert.isNotNull(game.serialize().letters)
      done()
    , 100)
  it 'should have time left less than 99', ->
    assert(game.getTimeRemaining() <= 99)
  it 'should be active', ->
    assert(game.isActive())

  letters = game.getLetters()
  it 'should accept a good word', ->
    result = game.checkWord('MOP')
    assert(result.success)
  it 'should not accept a word not in dictionary', ->
    result = game.checkWord('ABCD')
    assert(!result.success)
    assert.equal(result.error, 'word not in dictionary')
  it 'should not accept a word not on board', ->
    result = game.checkWord('TOOL')
    assert(!result.success)
    assert.equal(result.error, 'word not on board')
  it 'should not accept a word too short', ->
    result = game.checkWord('BA')
    assert(!result.success)
    assert.equal(result.error, 'word too short')