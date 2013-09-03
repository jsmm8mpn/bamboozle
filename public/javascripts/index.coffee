getParameterByName = (name) ->
  name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
  regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
  results = regex.exec(location.search)
  (if not results? then "" else decodeURIComponent(results[1].replace(/\+/g, " ")))

$('.toggler').on('click', ->
  $(this).parent().find('.toggled').slideToggle()
)

$('#settingsDiv').on('click', '.button', changeSettings)
$('#startDiv').on('click', '.button', ready)
$('#quitDiv').on('click', '.button', voteQuit)


hangoutId = getParameterByName("hangoutId")
@hangoutId = (if (hangoutId) then hangoutId else "h1")
userId = getParameterByName("userId")
@userId = (if (userId) then userId else "u1")

# TODO: Add dynamic URL
#var socket = io.connect('http://bamboozle-zarala.rhcloud.com:8000');
@socket = io.connect("http://localhost:8080")
@socket.on "game", setupGame
@socket.on "letters", onLetters
@socket.on 'time', updateTime
@socket.on 'results', writeResults
register()
$("#startDiv").show()