#global module:false
module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    watch:
      grunt:
        files: ["Gruntfile.coffee", "package.json"]
        tasks: "default"

      view:
        files: ["view/*.*"]
        tasks: "default"

      ###
      stylesheets:
        files: "client/stylesheets/*.*"
        tasks: "stylesheets"
      ###

      javascript:
        files: ["client/coffee/*.coffee", "tests/*.t.coffee"]
        tasks: "coffeescript"

    coffee:
      compile:
        files:
          "public/javascripts/client.js": ["client/coffee/app.coffee", "client/coffee/helper.coffee", "client/coffee/index.coffee"]

    uglify:
      prod:
        files:
          "public/javascripts/client.min.js": ["public/javascripts/client.js"]

    mochacli:
      options:
        reporter: 'nyan'
        bail: true
        compilers: ['coffee:coffee-script']
        ui: "tdd"
      all: ["tests/*.t.coffee"]

    ###
    copy:
      coffee:
        files: [
          expand: true
          cwd: "src/client"
          src: ["coffee/*.*"]
          dest: "public"
        ]
    ###

    clean:
      stylesheets: "public/javascripts/*"
      javascript: "public/stylesheets/*"


  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  #grunt.loadNpmTasks "grunt-contrib-compass"
  grunt.loadNpmTasks "grunt-contrib-clean"
  #grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  #grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-mocha-cli"
  #grunt.loadNpmTasks "grunt-plato"

  # Clean, compile and concatenate JS
  grunt.registerTask "coffeescript", [ "coffee", "mochacli" ]
  grunt.registerTask 'test', ['mochacli']

  # Clean and compile stylesheets
  #grunt.registerTask "stylesheets", [  ]

  # Production build
  #grunt.registerTask "production", [ "default", "clean:sourcemaps" ]

  # Default task
  grunt.registerTask "default", [ "coffeescript"]
  grunt.registerTask "prod", ["default", "uglify"]

  grunt.registerTask 'start', ['server', 'watch']

  grunt.registerTask "server", ->
    require('./server')

  #grunt.registerTask "heroku", [ "default" ]