#!/bin/env node

var express = require('express'),
    app = express(),
	game = require('./routes/game'),
    http = require('http').createServer(app),
    io = require('socket.io').listen(http),
	path = require('path');


//Get the environment variables we need.
var ipaddr  = process.env.OPENSHIFT_NODEJS_IP || "127.0.0.1";
var port    = process.env.OPENSHIFT_NODEJS_PORT || 8080;

http.listen(port, ipaddr);

app.use(express.static(path.join(__dirname, 'public')));

app.get('/', function(req, res) {
    res.end("blah2");
});

app.get('/letters', game.getLetters);
app.get('/games', game.printGames);
app.get('/words', game.printWords);
app.get('/time', game.getTimeRemaining);
app.get('/results', game.getResults);
app.get('/game', game.getGame);

io.sockets.on('connection', function (socket) {
	socket.on('register', function(o) {
        socket.username = o.userId;
        socket.room = o.hangoutId;
        socket.join(o.hangoutId);
        var result = game.register(o.hangoutId, o.userId);
        if (result) {
            socket.emit('game', result);
        }
    });

    socket.on('ready', function() {
        var result = game.ready(socket.room, socket.username);
        if (result) {
            io.sockets.in(socket.room).emit('game', result);
        }
    });
    socket.on('newGame', game.newGame);
    socket.on('word', game.submitWord);
    socket.on('quit', game.quit);
    //socket.on('ping', game.ping);
});


