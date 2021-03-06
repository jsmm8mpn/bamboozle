myDir = angular.module('myDir', [])

myDir.directive('playerList', ['$timeout', 'socket', ($timeout, socket) ->
  return {
    restrict: 'A'
    templateUrl: 'view/templates/playerList'
    link: (scope, elem, attrs) ->
      scope.invite = ->
        email = scope.invite
        if email.length > 0
          socket.emit 'invite', email, (result) ->
            if result.success
              scope.invite = ''
              scope.inviteStatus = 'Invite sent to: ' + email
              $timeout(->
                scope.inviteStatus = ''
              , 3000)
            else
              scope.inviteStatus = result.error
  }
])

myDir.directive('createNewRoom', ['$timeout', 'socket', ($timeout, socket) ->
  return {
    restrict: 'A'
    templateUrl: 'view/templates/createNewRoom'
    link: (scope, elem, attrs) ->

      scope.newRoomSubmitDisabled = true

      setRoomStatus = (error) ->
        if error
          scope.newRoomStatus = 'has-error'
          scope.newRoomError = error
          scope.newRoomSubmitDisabled = true
        else
          scope.newRoomStatus = 'has-success'
          scope.newRoomError = ''
          scope.newRoomSubmitDisabled = false

      clearRoomStatus = ->
        scope.newRoomStatus = ''
        scope.newRoomError = ''
        scope.newRoomSubmitDisabled = true

      timer = false
      scope.$watch('newRoom', (room) ->
        clearRoomStatus()
        if room and room.length > 0
          if room.length < 3
            setRoomStatus('Room name must be at least 3 characters')
          else if room.length > 16
            setRoomStatus('Room name must be no more than 16 characters')
          else if not /^[a-z][a-z0-9]+$/.test(room)
            setRoomStatus('Room name can only contain letters and numbers')
          else
            if timer
              $timeout.cancel(timer)
            timer = $timeout( ->
              socket.emit('checkRoomName', room, (valid) ->
                if valid == true
                  setRoomStatus()
                else
                  setRoomStatus('Room name is already taken')
              )
            , 250)
      )
  }
])

myDir.directive('roomList', ->
  return {
    restrict: 'A'
    templateUrl: 'view/templates/roomList'
  }
)

myDir.directive('board', ->
  return  {
    templateUrl: 'view/templates/board'
    link: (scope, elem, attrs) ->
      scope.showBoard = true

      #elem.html("<div><button ng-click='ready()' class='btn btn-success'>Ready</button></div>");

      #scope.$on('ready', (event) ->
        #elem.html('<div>Waiting for other players</div>')
      #)

      scope.$on('game', (event, game) ->
        scope.preStartTimeLeft = game.timeLeft - game.timeLimit
        timerId = setInterval(->
          scope.$apply(->

            scope.preStartTimeLeft = scope.preStartTimeLeft - 1
          )

          if scope.preStartTimeLeft <= 0
            clearInterval timerId
        , 1000
        )
      )

      scope.$on('letters', (event, letters) ->
#        table = "<table>"
#        y = 0
#
#        while y < letters.length
#          table += "<tr>"
#          x = 0
#
#          while x < letters[y].length
#            table += "<td>" + letters[y][x] + "</td>"
#            x++
#          table += "</tr>"
#          y++
#        table += "</table>"
#        elem.html(table)

        $('#wordInputField').focus()

        #scope.showBoard = true
      )

      scope.$on('results', ->
        #scope.showBoard = false
      )
  }
)

myDir.directive('timer', ['$timeout', 'socket', ($timeout, socket) ->
  return {
  templateUrl: 'view/templates/timer'
  link: (scope, elem, attrs) ->
    scope.$on('updateTime', (event, timeLeft) ->
      scope.timer = timeLeft
    )

    scope.$on('game', (event, game) ->
      $("#timer").removeClass("timer-warn")
      serverTimeLeft = game.timeLeft
      timeLimit = game.timeLimit
      scope.timer = serverTimeLeft
      show "timer"

      timerFn = () ->
        scope.timer = scope.timer - 1
        secondsLeft = scope.timer
        if secondsLeft > timeLimit
          secondsLeft = secondsLeft - timeLimit
          scope.preStartTimeLeft = secondsLeft
          $timeout(timerFn, 1000)
        else
          $("#timer").addClass("timer-warn")  if secondsLeft < 15
          #elem.html('<h3>' + secondsLeft + '</h3>')
          scope.timeLeft = secondsLeft
          if secondsLeft <= 0
            scope.timeLeft = undefined
            #clearInterval timerId
            scope.$emit('timerExpired')
          else
            $timeout(timerFn, 1000)

      $timeout(timerFn, 1000)

    )
  }
])

myDir.directive('wordInput', ['socket', (socket) ->
  return {
    templateUrl: 'view/templates/wordInput'
    link: (scope, elem, attrs) ->

      scope.wordList = []

      scope.submitWord = ->
        if (scope.wordForm.$invalid)
          return

        word = scope.word
        socket.emit "word", word, (result) ->
          if result.success
            scope.wordResult = 'word is valid'
            scope.wordStatus = 'has-success'
            scope.wordList.push(word)
          else
            scope.wordResult = result.error
            scope.wordStatus = 'has-error'
        scope.word = ''

      scope.$on('results', ->
        scope.wordResult = ''
        scope.wordStatus = ''
      )
      scope.$on('game', ->
        scope.wordResult = ''
        scope.wordStatus = ''
      )
  }
])

myDir.directive('wordList', ->
  return {
    templateUrl: 'view/templates/wordList'
    link: (scope, elem, attrs) ->
      scope.wordList = []
      scope.$on('wordValid', (event, word) ->
        scope.wordList.push(word)
      )
      scope.$on('game', ->
        scope.wordList = []
      )
  }
)

myDir.directive('results', ->
  return {
    restrict: 'A'
    templateUrl: 'view/templates/results'
  }
)

myDir.directive('playerResult', ->
  return {
    templateUrl: 'view/templates/playerResult'
  }
)

myDir.directive('gameControls', ->
  return {
    restrict: 'A'
    templateUrl: 'view/templates/gameControls'
  }
)

myDir.directive('roomSettings', ['$timeout', 'socket', ($timeout, socket) ->
  return {
    restrict: 'A'
    templateUrl: 'view/templates/roomSettings'
    link: (scope, elem, attrs) ->

      scope.minWordLengthValues = ['2', '3', '4', '5']
      scope.timeLimitValues = ['30', '60', '90', '120', '150', '180']

      settings =
        allowPlural: false
        negativePoints: false
        restartAllowed: true
        minWordLength: 3
        timeLimit: 90

      settings['public'] = false

      scope.settings = settings
      initialSettings = true

      scope.$watchCollection('settings', (settings) ->
        if initialSettings
          initialSettings = false
        else
          socket.emit('settings', settings)

      )
  }
])

myDir.directive('settingB', ->
  return {
    restrict: 'EA'
    scope:
      master: '=?'
      settingName: '='
      iconCls: '@'
      text: '@'
    templateUrl: 'view/templates/setting-b'
    link: (scope, element) ->
      scope.master = true if not scope.master
      scope.text = '' if not scope.text
  }
)

myDir.directive('settingC', ->
  return {
    restrict: 'EA'
    scope:
      master: '='
      settingName: '='
      values: '='
      text: '@'
    templateUrl: 'view/templates/setting-c'
  }
)

