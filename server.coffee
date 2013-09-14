express = require 'express'
app = express()
Room = require './routes/game-room'
rest = require('./routes/simple-rest').init(app)
http = require('http').createServer(app)
io = require('socket.io').listen(http)
path = require 'path'
coffee = require 'coffee-middleware'
fs = require 'fs'
less = require 'less-middleware',
passport = require 'passport',
GoogleStrategy = require('passport-google').Strategy

passport.serializeUser( (user, done) ->
  done(null, user)
)

passport.deserializeUser( (obj, done) ->
  done(null, obj)
)

myStrategy = new GoogleStrategy(
  returnURL: 'http://localhost:8080/auth/google/return',
  realm: 'http://localhost:8080'
, (identifier, profile, done) ->
  profile.identifier = identifier
  console.log('user logged in: ' + JSON.stringify(profile))
  done(null,profile)
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
app.use(express.session(
  secret: 'keyboard cat'
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
    res.redirect('selectRoom')
)

ensureAuthenticated = (req, res, next) ->
  if req.isAuthenticated()
    next()
  else
    req.session.redirect_to = '/room/' + req.params.room
    res.redirect('/auth/google')

app.get('/logout', (req, res) ->
  req.logout()
  res.redirect('done')
)

app.get '/room/:room', ensureAuthenticated, (req, res) ->
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
      fn(
        success: true
      )
    else
      fn(
        success: false
        error: 'roomDoesNotExist'
      )

  socket.on 'register', (o, fn) ->

    try
      room = rooms[socket.room]
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
