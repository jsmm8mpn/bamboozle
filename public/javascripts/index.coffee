getParameterByName = (name) ->
  name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
  regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
  results = regex.exec(location.search)
  (if not results? then "" else decodeURIComponent(results[1].replace(/\+/g, " ")))
hangoutId = getParameterByName("hangoutId")
hangoutId = (if (hangoutId) then hangoutId else "h1")
userId = getParameterByName("userId")
userId = (if (userId) then userId else "u1")
timeLimit = 10
document.addEventListener "timerExpired", ->
  testResults()


# TODO: Add dynamic URL
#var socket = io.connect('http://bamboozle-zarala.rhcloud.com:8000');
socket = io.connect("http://localhost:8080")
socket.on "game", setupGame
register()
document.getElementById("startDiv").style.display = "block"