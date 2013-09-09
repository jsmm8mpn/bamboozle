assert = require('chai').assert
Room = require '../routes/game-room'

describe 'Game Room', ->

  socket =
    emits: {}
    emit: (name, data) ->
      @emits[name] = data

  room = new Room(socket)

  it 'should have no player', ->
    assert.equal(Object.keys(room.players).length, 0)
    assert.equal(room.numPlayers, 0)
  it 'should register first player and make master', ->
    room.register('u1')
    assert.equal(room.master, 'u1')
    assert(room.players['u1'])
    assert.equal(room.numPlayers, 1)
    assert(!socket.emits['game'])
    assert.deepEqual(socket.emits['players'], [
      name: 'u1'
      ready: false
      restart: false
      score: 0
      master: true
    ])
  it 'should register second player', ->
    room.register('u2')
    assert.equal(room.master, 'u1')
    assert(room.players['u2'])
    assert.equal(room.numPlayers, 2)
    assert(!socket.emits['game'])
    assert.deepEqual(socket.emits['players'], [
      name: 'u1'
      ready: false
      restart: false
      score: 0
      master: true
    ,
      name: 'u2'
      ready: false
      restart: false
      score: 0
      master: false
    ])

  it 'should mark first player as ready', ->
    room.ready('u1')
    assert(room.players.u1.ready)
    assert(!room.currentGame)
  it 'should mark second player as ready and start game', ->
    room.ready('u2')
    assert(room.players.u2.ready, 'player 2 not ready')
    assert(room.currentGame, 'game not started')
  it 'should mark first player as restart', ->
    room.voteRestart('u1')
    assert(room.players.u1.restart, 'player 2 not marked as restart')
    assert(!socket.emits['restart'], 'game restarted prematurely')
  it 'should mark second player as restart and restart game', ->
    room.voteRestart('u2')
    assert(socket.emits['restart'])
    #TODO: More asserts
  it 'should allow the master to leave', ->
    room.leave('u1')

