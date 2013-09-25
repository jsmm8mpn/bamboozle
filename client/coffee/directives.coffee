myDir = angular.module('myDir', [])

myDir.directive('playerList', ->
  return {
    restrict: 'A'
    templateUrl: 'view/playerList'
    link: (scope, elem, attrs) ->

  }
)

myDir.directive('roomList', ->
  return {
    restrict: 'A'
    templateUrl: 'view/roomList'
    link: (scope, elem, attrs) ->

  }
)

myDir.directive('board', ->
  return  (scope, elem, attrs) ->
    elem.html('<h2>Board goes here</h2>')
)

myDir.directive('timer', ->
  return {
    templateUrl: 'view/timer'
    link: (scope, elem, attrs) ->

  }
)

myDir.directive('wordInput', ->
  return {
    templateUrl: 'view/wordInput'
  }
)