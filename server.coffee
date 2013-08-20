express = require 'express'
app = express()
game = require './routes/game'
http = require('http').createServer(app)
io = require('socket.io').listen(http)
path = require 'path'

ipaddr  = process.env.OPENSHIFT_NODEJS_IP || "127.0.0.1"
port    = process.env.OPENSHIFT_NODEJS_PORT || 8080

http.listen(port, ipaddr)

app.get('/', (req, res) ->
  res.end('blah3')
)