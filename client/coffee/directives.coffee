myDir = angular.module('myDir', [])

myDir.directive('playerList', ->
  return {
    restrict: 'A'
    template: '<h2>Player List</h2>'
    link: (scope, elem, attrs) ->
      console.log("Recognized the fundoo-rating directive usage")
  }
)

myDir.directive('roomList', ->
  return {
    restrict: 'A'
    templateUrl: 'view/roomList'
    link: (scope, elem, attrs) ->
      #scope.rooms = [{name: 'r1'}, {name: 'r2'}]
  }
)