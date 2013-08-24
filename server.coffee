express = require 'express'
app = express()
game = require './routes/game'
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

app.get '/letters', game.getLetters
app.get '/games', game.printGames
app.get '/words', game.printWords
app.get '/time', game.getTimeRemaining
app.get '/results', game.getResults
app.get '/game', game.getGame

app.get '/', (req, res) ->
  res.render(__dirname+'/view/index.jade')

app.get '/h', (req, res) ->
  res.render(__dirname+'/view/hindex.jade')

io.sockets.on 'connection', (socket) ->
  socket.on 'register', (o) ->
    socket.username = o.userId
    socket.room = o.hangoutId
    socket.join o.hangoutId
    result = game.register(o.hangoutId, o.userId)
    if (result)
      socket.emit('game', result)

  socket.on 'ready', ->
    result = game.ready(socket.room, socket.username)
    if (result)
      io.sockets.in(socket.room).emit('game', result)

  socket.on('newGame', game.newGame)
  socket.on('word', game.submitWord)
  socket.on('quit', game.quit)

  #socket.on('ping', game.ping)