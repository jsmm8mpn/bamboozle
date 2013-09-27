myServices = angular.module('myServices', [])

myServices.factory "socket", ($rootScope) ->
  socket = io.connect("http://localhost:8080")
  on: (eventName, callback) ->
    socket.on eventName, ->
      args = arguments
      $rootScope.$apply ->
        callback.apply socket, args

  emit: (eventName, data, callback) ->
    socket.emit eventName, data, ->
      args = arguments
      $rootScope.$apply ->
        callback.apply socket, args  if callback

