class Room
  created: new Date()
  roomId = undefined
  currentGame = undefined
  participants = {}
  results = []

  constructor: (newRoomId) ->
     roomId = newRoomId