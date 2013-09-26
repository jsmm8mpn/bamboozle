myDir = angular.module('myDir', [])

myDir.directive('playerList', ->
  return {
    restrict: 'A'
    templateUrl: 'view/templates/playerList'
    link: (scope, elem, attrs) ->

  }
)

myDir.directive('roomList', ->
  return {
    restrict: 'A'
    templateUrl: 'view/templates/roomList'
    link: (scope, elem, attrs) ->

  }
)

myDir.directive('board', ->
  return  (scope, elem, attrs) ->
    elem.html('<h2>Board goes here</h2>')
)

myDir.directive('timer', ->
  return {
    templateUrl: 'view/templates/timer'
    link: (scope, elem, attrs) ->
      scope.updateTime = (timeLeft) ->
        scope.timer = timeLeft
        scope.$apply()

      scope.startTimer = (serverTimeLeft, timeLimit) ->
        scope.timer = serverTimeLeft
        show "timer"
        timerId = setInterval(->
          scope.timer = scope.timer - 1
          secondsLeft = scope.timer
          if secondsLeft > timeLimit
            secondsLeft = secondsLeft - timeLimit
          else $("#timer").toggleClass("timer-warn")  if secondsLeft < 15
          #$("#timer").html(secondsLeft)
          scope.timeLeft = secondsLeft
          scope.$apply()
          if secondsLeft is 0
            hide "quitDiv"
            hide "wordInput"
            clearInterval timerId
        , 1000)
  }
)

myDir.directive('wordInput', ->
  return {
    templateUrl: 'view/templates/wordInput'
  }
)

myDir.directive('wordList', ->
  return {
    templateUrl: 'view/templates/wordList'
    link: (scope, elem, attrs) ->
      scope.addWord = (word) ->
        scope.wordList.push(word)
        scope.$apply()
  }
)

myDir.directive('results', ->
  return {
    templateUrl: 'view/templates/results'
  }
)

myDir.directive('playerResult', ->
  return {
    templateUrl: 'view/templates/playerResult'
  }
)

myDir.directive('playerControls', ->
  return {
    restrict: 'A'
    templateUrl: 'view/templates/playerControls'
  }
)