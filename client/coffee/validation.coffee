@commonValidation = ->

  validateNewRoomForm = (room) ->
    if room.length < 3
      return 'Room name must be at least 3 characters'
    else if not /^[a-z][a-z0-9]+$/.test(room)
      return 'Room name can only contain letters and numbers'