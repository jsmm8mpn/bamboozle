express = require 'express'
app = express()
Room = require './routes/game-room'
Player = require './routes/player'
rest = require('./routes/simple-rest').init(app)
http = require('http').createServer(app)
io = require('socket.io').listen(http)
path = require 'path'
coffee = require 'coffee-middleware'
fs = require 'fs'
less = require 'less-middleware',
passport = require 'passport',
GoogleStrategy = require('passport-google').Strategy

passport.serializeUser( (player, done) ->
  user =
    userId: player.name
    displayName: player.displayName
  done(null, user)
)

deserializeUser = (user, done) ->
  player = new Player(user.userId, user.displayName)
  done(null, player)

passport.deserializeUser(deserializeUser)

myStrategy = new GoogleStrategy(
  returnURL: 'http://localhost:8080/auth/google/return',
  realm: 'http://localhost:8080'
, (identifier, profile, done) ->
  player = new Player(identifier, profile.displayName)
  console.log('user logged in: ' + JSON.stringify(player))
  done(null,player)
)
passport.use(myStrategy)

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
app.use(express.cookieParser())

MemoryStore = express.session.MemoryStore
sessionStore = new MemoryStore
app.use(express.session(
  store: sessionStore
  secret: 'secret'
  key:'express.sid'
))
app.use(passport.initialize())
app.use(passport.session())

app.use(express.static(path.join(__dirname, 'public')))
app.set('views', __dirname + '/views')
app.set('view engine', 'jade')

rooms = {}
players = {}

#app.get '/', (req, res) ->
#  res.render(__dirname+'/view/index.jade', req.query)

app.get('/auth/google', passport.authenticate('google'))

app.get('/auth/google/return', passport.authenticate('google',
  failureRedirect: '/horrible'
), (req, res) ->
  #console.log('logged in successfully')
  if req.session.redirect_to
    res.redirect(req.session.redirect_to);
  else
    res.redirect('/')
)

ensureAuthenticated = (req, res, next) ->
  if req.isAuthenticated()
    next()
  else
    req.session.redirect_to = req.originalUrl #'/room/' + req.params.room
    res.redirect('/auth/google')

app.get('/logout', (req, res) ->
  req.logout()
  res.redirect('done')
)

app.get '/room/:room', ensureAuthenticated, (req, res) ->
  res.render(__dirname+'/view/index.jade',
    roomId: req.params.room
  )

app.get '/', ensureAuthenticated, (req, res) ->
  roomList = []
  for id,room of rooms
    if room.public
      roomList.push room
  res.render(__dirname+'/view/selectRoom.jade',
    rooms: roomList #TODO: filter to only public rooms
  )

app.get '/h', (req, res) ->
  res.render(__dirname+'/view/hindex.jade')

io.configure( ->
  io.set("authorization", (data, accept) ->
    myCookieParser = express.cookieParser('secret')
    res =
      headers:
        cookie: data.headers.cookie
    myCookieParser(res, null, (err) ->
      sessionStore.get(res.signedCookies['express.sid'], (err, session) ->
        deserializeUser(session.passport.user, (err, player) ->
          data.player = player
          accept(null, true)
        )
      )
    )
  )
)

io.sockets.on 'connection', (socket) ->
  console.log('socket user: ' + JSON.stringify(socket.handshake.player))

  player = socket.handshake.player
  player.socket = socket

  socket.on 'join', (o, fn) ->
    room = rooms[o.roomId]
    if room
      socket.join o.roomId
      socket.room = o.roomId
      #user = socket.handshake.user
      #player = new Player(user.userId, user.displayName)
      room.register player
      socket.username = player.name
      console.log socket.username + " has registered in " + socket.room
      fn(
        success: true
      )
    else
      fn(
        success: false
        error: 'roomDoesNotExist'
      )

  socket.on 'createRoom', (o, fn) ->
    room = rooms[o.roomId]
    if room
      fn(
        success: false
      )
    else
      room = new Room(o.roomId, io.sockets.in(o.roomId), o.public)
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

  socket.on 'public', (value) ->
    room = rooms[socket.room]
    if room.master == socket.username
      room.public = value

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
