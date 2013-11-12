myServices = angular.module('myServices', [])

myServices.factory "socket", ($rootScope) ->
  socket = io.connect(window.location.hostname)
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


myServices.factory 'validationService', () ->
  validateNewRoomName: (roomName) ->

myServices.factory 'Results', () ->
  results = {}
  letters = {}

  return {
    setResults: (newResults) ->
      results = newResults

    getResults: () ->
      return results

    setLetters: (newLetters) ->
      letters = newLetters

    getLetters: () ->
      return letters
  }
