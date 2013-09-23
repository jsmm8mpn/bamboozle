angular.module('bamboozle', []).config(['$routeProvider', ($routeProvider) ->
  $routeProvider.when('/rooms',
    templateUrl: 'rooms'
    controller: ($scope) ->
      $scope.rooms = [{name: 'r1'}]
  ).otherwise(
    redirectTo: '/rooms'
  )
])