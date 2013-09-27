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
    scope.$on('letters', (event, letters) ->
      table = "<table>"
      y = 0

      while y < letters.length
        table += "<tr>"
        x = 0

        while x < letters[y].length
          table += "<td>" + letters[y][x] + "</td>"
          x++
        table += "</tr>"
        y++
      table += "</table>"
      elem.html(table)
    )
)

myDir.directive('timer', ->
  return (scope, elem, attrs) ->

    scope.$on('updateTime', (event, timeLeft) ->
      scope.timer = timeLeft
    )

    scope.$on('game', (event, game) ->
      serverTimeLeft = game.timeLeft
      timeLimit = game.timeLimit
      scope.timer = serverTimeLeft
      show "timer"
      timerId = setInterval(->
        scope.timer = scope.timer - 1
        secondsLeft = scope.timer
        if secondsLeft > timeLimit
          secondsLeft = secondsLeft - timeLimit
        else $("#timer").toggleClass("timer-warn")  if secondsLeft < 15
        elem.html(secondsLeft)
        if secondsLeft <= 0
          clearInterval timerId
          scope.$emit('timerExpired')
      , 1000)
    )
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
        #scope.$apply()
  }
)

myDir.directive('results', ->
  return {
    templateUrl: 'view/templates/results'
    link: (scope, elem, attrs) ->
      html = ""
      for userId,result of results
        playerWords = result.words
        #playerWords.sort()
        html += "<div class=\"playerResult\">"
        html += "<h1>" + userId + "</h1>"

        for word,scored of playerWords
          if scored
            html += "<li class=\"scored\">" + word + "</li>"
          else
            html += "<li class=\"unscored\">" + word + "</li>"
        html += "<div class=\"score\">" + result.score + "</div>"
        html += "</div>"
      elem.html(html)
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