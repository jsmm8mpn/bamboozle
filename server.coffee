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

app.get '/', (req, res) ->
  res.render(__dirname+'/view/index.jade')

app.get '/h', (req, res) ->
  res.render(__dirname+'/view/hindex.jade')

io.sockets.on 'connection', (socket) ->
  socket.on 'register', (o) ->
    socket.username = o.userId
    socket.room = o.roomId
    socket.join o.roomId
    room = rooms[socket.room]
    if !room
      room = new Room(io.sockets.in(socket.room))
      rooms[socket.room] = room
    console.log socket.username + " has registered in " + socket.room
    room.register(socket.username)

  socket.on 'ready', ->
    room = rooms[socket.room]
    room.ready(socket.username)

  socket.on 'settings', (settings) ->
    room = rooms[socket.room]
    room.changeSettings(settings)

  socket.on 'voteRestart', ->
    room = rooms[socket.room]
    room.voteRestart(socket.username)

  socket.on 'word', (o, fn) ->
    room = rooms[socket.room]
    fn(room.submitWord(socket.username, o.word))

  socket.on 'disconnect', ->
    console.log(socket.username + ' is leaving: ' + socket.room)
    room = rooms[socket.room]
    room.leave(socket.username) if room