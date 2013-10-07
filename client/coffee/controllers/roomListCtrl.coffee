@RoomListCtrl = ($scope, $routeParams, $location, socket) ->

  $scope.createRoom = ->
    if $scope.newRoomSubmitDisabled
      return

    room = $scope.newRoom
    socket.emit 'createRoom',
      roomId: room
    , (data) ->
      if data.success
        $location.path(/room/+room)

  socket.on 'rooms', (rooms) ->
    $scope.rooms = rooms