assert = require('chai').assert
Game = require '../routes/game'

describe 'Regular Game', ->

  letters = [['A','B','C','D'],['E','F','G','H'],['I','J','K','S'],['N','M','O','P']]
  game = new Game(
    timeLimit: 99
    startDelay: 100
    letters: letters
  )

  # Make sure game variables aren't static across instances
  game2 = new Game(
    timeLimit: 101
  )

  it 'should have a time limit of 99', ->
    assert.equal(game.timeLimit, 99)
  it 'should have a start delay of 100', ->
    assert.equal(game.startDelay, 100)
  it 'should have a default min word length of 3', ->
    assert.equal(game.minWordLength, 3)
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
  it 'should accept a good word', ->
    result = game.checkWord('MOP')
    assert(result.success, 'word not accepted: ' + result.error)
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
  it 'should not allow plurals', ->
    result = game.checkWord('MOPS')
    assert(!result.success)
  it 'should score words correctly', ->
    assert.equal(game.scoreWord('ABC'), 1)
    assert.equal(game.scoreWord('ABCD'), 2)
    assert.equal(game.scoreWord('ABCDE'), 3)

  it 'should create correct results', ->
    result1 = undefined
    result2 = undefined
    players =
      p1:
        words: ['ONE', 'TWO', 'THREE']
        addResult: (result) ->
          result1 = result
      p2:
        words: ['THREE', 'FOUR', 'FIVE']
        addResult: (result) ->
          result2 = result

    game.score(players)

    assert.equal(result1.score, 2)
    assert.equal(result2.score, 4)

    assert(result1.words['ONE'])
    assert(result1.words['TWO'])
    assert(!result1.words['THREE'])

    assert(!result2.words['THREE'])
    assert(result2.words['FOUR'])
    assert(result2.words['FIVE'])

  it 'should have restarted', ->
    game.restart()
    assert(game.started > new Date(), 'Game should have restarted the timer')
    assert.notDeepEqual(game.letters, letters, 'Game did not repopulate the letters')

describe 'Game with min word length = 4', ->
  game = new Game(
    minWordLength: 4
    startDelay: -1
    letters: [['E','B','C','D'],['E','F','G','H'],['I','J','K','L'],['N','M','O','P']]
  )

  it 'should not accept a word of 3 letters', ->
    result = game.checkWord('MOP')
    assert(!result.success)
  it 'should accept a word with 4 letters', ->
    result = game.checkWord('BEEF')
    assert(result.success, 'word not accepted: ' + result.error)
  it 'should score a word correctly', ->
    assert.equal(game.scoreWord('BEEF'), 1)
    assert.equal(game.scoreWord('BEEFS'), 2)

describe 'Game allowing plurals', ->
  game = new Game(
    startDelay: -1
    letters: [['C','A','R','S'],['E','F','G','H'],['I','J','K','L'],['N','M','O','P']]
    allowPlural: true
  )

  it 'should allow plurals', ->
    result = game.checkWord('CARS')
    assert(result.success, 'word not accepted: ' + result.error)
