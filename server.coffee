express = require 'express'
app = express()
Room = require './routes/game-room'
rest = require('./routes/simple-rest').init(app)
http = require('http').createServer(app)
io = require('socket.io').listen(http)
path = require 'path'
coffee = require 'coffee-middleware'
fs = require 'fs'
less = require 'less-middleware'

ipaddr  = process.env.OPENSHIFT_NODEJS_IP || process.env.IP || "127.0.0.1"
port    = process.env.OPENSHIFT_NODEJS_PORT || process.env.PORT || 8080

http.listen(port, ipaddr)

module.exports = http

coffeeDir = path.join(__dirname, 'coffee')
jsDir = path.join(__dirname, 'public/javascripts')

app.use(less(
  src: path.join(__dirname, 'public/stylesheets')
  prefix: '/stylesheets'
))

app.use(coffee(
  src: path.join(__dirname, 'public/javascripts')
  prefix: '/javascripts'
))

app.use(express.static(path.join(__dirname, 'public')))
app.set('views', __dirname + '/views')
app.set('view engine', 'jade')

rooms = {}

#app.get '/', (req, res) ->
#  res.render(__dirname+'/view/index.jade', req.query)

app.get '/:room', (req, res) ->
  res.render(__dirname+'/view/index.jade',
    roomId: req.params.room
  )

app.get '/h', (req, res) ->
  res.render(__dirname+'/view/hindex.jade')

io.sockets.on 'connection', (socket) ->
  socket.on 'join', (o, fn) ->
    room = rooms[o.roomId]
    if room
      socket.join o.roomId
      socket.room = o.roomId
    else
      fn(
        success: false
        error: 'roomDoesNotExist'
      )

  socket.on 'register', (o, fn) ->

    try
      room.register o.userId
      socket.username = o.userId
      console.log socket.username + " has registered in " + socket.room
      fn(
        success: true
      )
    catch e
      fn(
        success: false
        error: e.message
      )

  socket.on 'createRoom', (o, fn) ->
    room = rooms[o.roomId]
    if room
      fn(
        success: false
      )
    else
      room = new Room(io.sockets.in(o.roomId))
      rooms[o.roomId] = room
      fn(
        success: true
      )

  socket.on 'ready', ->
    room = rooms[socket.room]
    room.ready(socket.username)

  socket.on 'settings', (settings) ->
    room = rooms[socket.room]
    if room.master == socket.username
      room.changeSettings(settings)

  socket.on 'voteRestart', ->
    room = rooms[socket.room]
    room.voteRestart(socket.username)

  socket.on 'word', (word, fn) ->
    room = rooms[socket.room]
    fn(room.submitWord(socket.username, word))

  socket.on 'disconnect', ->
    console.log(socket.username + ' is leaving: ' + socket.room)
    room = rooms[socket.room]
    room.leave(socket.username) if room

  socket.on 'master', (userId) ->
    room = rooms[socket.room]
    if room.master == socket.username
      room.changeMaster(userId)

  socket.on 'start', ->
    room = rooms[socket.room]
    if room.master == socket.username
      room.startNow()

  socket.on 'end', ->
    room = rooms[socket.room]
    if room.master == socket.username
      room.endNow()

  socket.on 'restart', ->
    room = rooms[socket.room]
    if room.master == socket.username
      room.restart()

  # TODO: Test
  socket.on 'kick', (userId) ->
    room = rooms[socket.room]
    if room.master == socket.username
      room.kickOut(userId)
      room.leave(userId)
