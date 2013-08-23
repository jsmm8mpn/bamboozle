updateLocalParticipantsData = (participants) ->
  participants_ = participants
stateChanged = (event) ->
  console.log "state changed. updating..."
  state_ = event.state
  metadata_ = event.metadata
  addedKeys = event.addedKeys
  i = 0

  while i < addedKeys.length
    added = addedKeys[i]
    console.log "added to state: " + added.key
    if added.key is "game"
      game = JSON.parse(added.value)
      startTimer game.start, game.timeLimit
    else if added.key is "letters"
      letters = JSON.parse(added.value)
      populateBoard letters
      displayBoard()
    i++
submitDelta = (delta) ->
  for key of delta
    delta[key] = JSON.stringify(delta[key])  if typeof delta[key] is "object"
  gapi.hangout.data.submitDelta delta
init = ->
  if gapi and gapi.hangout
    console.log "app is loading"
    initHangout = (apiInitEvent) ->
      if apiInitEvent.isApiReady
        console.log "initializing"
        gapi.hangout.data.onStateChanged.add stateChanged
        gapi.hangout.onParticipantsChanged.add (partChangeEvent) ->
          updateLocalParticipantsData partChangeEvent.participants

        unless state_
          state = gapi.hangout.data.getState()
          metadata = gapi.hangout.data.getStateMetadata()
          if state and metadata
            state_ = state
            metadata_ = metadata
        unless participants_
          initParticipants = gapi.hangout.getParticipants()
          updateLocalParticipantsData initParticipants  if initParticipants
          document.getElementById("startDiv").style.display = "block"
        hangoutId = gapi.hangout.getHangoutId()
        userId = gapi.hangout.getLocalParticipantId()
        socket = io.connect("https://bamboozle-zarala.rhcloud.com:8443")
        socket.on "game", setupGame
        register()
        gapi.hangout.onApiReady.remove initHangout

    
    #document.addEventListener('timerExpired', gameEnd);
    gapi.hangout.onApiReady.add initHangout
state_ = undefined
metadata_ = undefined
participants_ = undefined
hangoutId = undefined
userId = undefined
socket = undefined
firstPlayer = false