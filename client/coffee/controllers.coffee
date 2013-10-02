#socket = io.connect("http://localhost:8080")

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
    console.log('setting rooms: ' + rooms.length)
    $scope.rooms = rooms

@RoomCtrl = ($scope, $routeParams, socket) ->

  $scope.ready = ->
    console.log('i ready')
    clearResults()
    socket.emit "ready"

  $scope.quit = ->
    hide "quitDiv"
    socket.emit "voteRestart"

  $scope.changeSettings = ->
    values = {}
    settings = $('.setting').each ->
      name = $(this).attr('name')
      if (name)
        settingValue = $(this).find('input')[0].value
        values[name] = settingValue
    socket.emit 'settings', values

  $scope.changePublic = ->
    socket.emit 'public', $(this).prop('checked')

  $scope.submitWord = ->
    word = $scope.word
    socket.emit "word", word, (result) ->
      if result.success
        $scope.$broadcast('wordValid', word, result)
      else
        $scope.$broadcast('wordError', word, result)
    $scope.word = ''

  $scope.toggleSettings = ->
    $('.toggled').slideToggle()

  roomId = $routeParams.roomId

  restartGame = (game) ->
    console.log('restarting game...')
    $scope.$broadcast('restart')
    clearResults()
    setupGame(game)

  setupGame = (game) ->
    console.log('setting up game')
    $scope.$broadcast 'game', game
    hide "startDiv"
    if game.letters
      onLetters(game.letters)

  onLetters = (letters) ->
    $scope.$broadcast('letters', letters)
    displayBoard()
    show "quitDiv"

  updatePlayers = (players) ->
    playerObj = {}
    for player in players
      playerObj[player.id] = player
    $scope.players = playerObj

  displayBoard = ->
    show "mainDiv"
    show "wordInput"
    $("#wordInput").focus()

  clearResults = ->
    #clear "board"
    #clear "wordList"
    #clear "wordResult"
    clear "results"
    #clear "timer"

    hide "results"
    show "mainDiv"

  $scope.$on('timerExpired', (event, timerExpired)->
    hide "quitDiv"
    hide "wordInput"
  )

  updateTime = (time) ->
    $scope.$broadcast('updateTime', time)

  writeResults = (results) ->
    $scope.results = results
    #$scope.$broadcast('results', results)
    hide "mainDiv"
    show "results"
    show "startDiv"

  socket.on "game", setupGame
  socket.on "letters", onLetters
  socket.on 'time', updateTime
  socket.on 'results', writeResults
  socket.on 'restart', restartGame
  socket.on 'players', updatePlayers

  # TODO: disable settings for non-master
  #$('#settingsDiv input').prop('disabled', true)

  #$('.toggler').on('click', ->
  #  $(this).parent().find('.toggled').slideToggle()
  #)

  socket.emit 'join',
    roomId: roomId
  , (data) ->
    if data.success
      show 'game'
    else
      console.log('could not register: ' + data.error)
      if data.error is 'roomDoesNotExist'
        #if confirm('Room does not exist. Do you want to create it?')
        socket.emit 'createRoom',
          roomId: roomId
        , (data) ->
          if data.success
            socket.emit 'join',
              roomId: roomId
            , (data) ->
              if data.success
                show 'game'


