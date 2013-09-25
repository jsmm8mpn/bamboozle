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