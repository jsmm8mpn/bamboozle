function getParameterByName(name) {
  name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
  var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
    results = regex.exec(location.search);
  return results == null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}

var hangoutId = getParameterByName('hangoutId');
hangoutId = (hangoutId) ? hangoutId : 'h1';
var userId = getParameterByName('userId');
userId = (userId) ? userId : 'u1';
var timeLimit = 10;

document.addEventListener('timerExpired', function() {
  testResults();
});

// TODO: Add dynamic URL
//var socket = io.connect('http://bamboozle-zarala.rhcloud.com:8000');
var socket = io.connect('http://localhost:8080');

socket.on('game', setupGame);

register();

document.getElementById('startDiv').style.display = 'block';