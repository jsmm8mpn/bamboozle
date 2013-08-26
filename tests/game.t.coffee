assert = require 'assert'
Game = require '../routes/game'

describe 'Game', ->
  it 'should get created with no arguments', ->
     game = new Game().serialize()
     console.log(JSON.stringify(game))
     assert.equal(game.timeLimit, 90)