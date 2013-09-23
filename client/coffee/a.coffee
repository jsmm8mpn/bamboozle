angular.module('bamboozle', []).config(['$routeProvider', ($routeProvider) ->
  $routeProvider.when('/rooms',
    templateUrl: 'view/rooms'
    controller: RoomListCtrl
  ).when('/room/:roomId',
    templateUrl: 'view/game'
    controller: RoomCtrl
  ).otherwise(
    redirectTo: '/rooms'
  )
])