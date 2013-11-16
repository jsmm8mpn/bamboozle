angular.module('bamboozle', ['myDir', 'myServices']).config(['$routeProvider', ($routeProvider) ->
  $routeProvider.when('/rooms',
    templateUrl: 'view/rooms'
    controller: RoomListCtrl
  ).when('/room/:roomId',
    templateUrl: 'view/game'
    controller: RoomCtrl
  ).when('/results',
    templateUrl: 'view/results'
    controller: RoomCtrl
  ).otherwise(

    retObj = {}
    if hangoutId
      retObj.redirectTo = '/room/'+hangoutId
    else
      retObj.redirectTo = '/rooms'

    retObj
  )
])