class Game
  constructor: (timeLimit) ->
    @started = new Date().getTime() + 5000
    @letters = populateLetters()
    @timeLimit = timeLimit || 90

  serialize: ->
    res =
      started: @started
      letters: @letters if (new Date() > @started)
      timeLimit: @timeLimit
      timeLeft: @getTimeRemaining()

  getTimeRemaining: ->
    time = new Date() - @started
    secondsLeft = @timeLimit - Math.floor(time / 1000)
    (if (secondsLeft < 0) then 0 else secondsLeft)

module.exports = Game

populateLetters = ->
  letters = []
  y = 0

  while y < CUBES.length
    row = []
    x = 0

    while x < CUBES[y].length
      cube = CUBES[y][x]
      letter = cube.charAt(Math.floor(Math.random() * cube.length))
      row.push letter
      x++
    letters.push row
    y++
  letters



CUBES = [["AAEEGN", "ELRTTY", "AOOTTW", "ABBJOO"], ["EHRTVW", "CIMOTU", "DISTTY", "EIOSST"], ["DELRVY", "ACHOPS", "HIMNQU", "EEINSU"], ["EEGHNW", "AFFKPS", "HLNNRZ", "DEILRX"]]
