@RoomCtrl = ($scope, $routeParams, $location, socket, Results) ->

  $scope.isHangout = (hangoutId != undefined)

  $scope.ready = ->
    clearResults()
    socket.emit "ready"
  #$scope.$broadcast('ready')

  $scope.startNow = ->
    socket.emit 'start'

#  $scope.quit = ->
#    hide "voteRestart"
#    socket.emit "voteRestart"

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

  $scope.$watch('voteRestart', (voteRestart) ->
    if voteRestart is true or voteRestart is false
      socket.emit('voteRestart', voteRestart)
  )

  ###
$scope.submitWord = ->
  word = $scope.word
  socket.emit "word", word, (result) ->
    if result.success
      $scope.$broadcast('wordValid', word, result)
    else
      $scope.$broadcast('wordError', word, result)
  $scope.word = ''


###

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
    $scope.game = game
    $scope.$broadcast 'game', game
    hide "startDiv"
    if game.letters
      onLetters(game.letters)
    else
      $scope.letters = undefined

  onLetters = (letters) ->
    $scope.letters = letters
    $scope.$broadcast('letters', letters)
    displayBoard()
    show "voteRestart"

  updatePlayers = (players) ->
    $scope.players = players
    if $scope.player
      $scope.player = players[$scope.player.id]

  displayBoard = ->
    show "mainDiv"
    show "wordInput"
    $("#wordInput").focus()

  clearResults = ->
    #clear "board"
    #clear "wordList"
    #clear "wordResult"
    #clear "timer"

    hide "results"
    show "mainDiv"

  $scope.$on('timerExpired', (event, timerExpired)->
    hide "voteRestart"
    hide "wordInput"
  )

  updateTime = (time) ->
    $scope.$broadcast('updateTime', time)

  writeResults = (results) ->
    $scope.game = undefined
    $scope.results = results
    #Results.setResults(results)
    #Results.setLetters($scope.letters)

    #$scope.$broadcast('results', results)
    #hide "mainDiv"
    show "results"
    #show "startDiv"
    #$('#resultsModal').modal()
    #$('#resultsModal').modal('show')
    #$location.path('/results')

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

  joinSuccess = (data) ->
    $scope.player = data.player
    show 'game'

  socket.emit 'join',
    roomId: roomId
  , (data) ->
    if data.success
      joinSuccess(data)
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
                joinSuccess(data)


#  runMock = () ->
#    updatePlayers(
#      p1:
#        id: 'p1'
#        name: 'player one'
#        score: 25
#        master: true
#      p2:
#        id: 'p2'
#        name: 'player two'
#        score: 106
#        master: false
#    )
#
#    writeResults(
#      p1:
#        score: 15
#        words:
#          dude: true
#          some: false
#          crazy: true
#          dad: false
#      p2:
#        score: 25
#        words:
#          some: false
#          dad: false
#          people: true
#          bad: true
#          ate: true
#          rate: true
#    )