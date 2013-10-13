@ResultsCtrl = ($scope, $routeParams, $location, socket, Results) ->

  console.log(Results.getResults())
  $scope.results = Results.getResults()
  $scope.letters = Results.getLetters()
