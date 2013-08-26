assert = require('chai').assert
Game = require '../routes/game'

describe 'Regular Game', ->
  game = new Game(99, 100)
  console.log(JSON.stringify(game))
  game2 = new Game(101, 5000)
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