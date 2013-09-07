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

      javascript:
        files: ["client/coffee/*.coffee", "tests/*.t.coffee"]
        tasks: "coffeescript"

    coffee:
      compile:
        files:
          "public/javascripts/client.js": ["client/coffee/app.coffee", "client/coffee/helper.coffee", "client/coffee/index.coffee"]

    less:
      development:
        files:
          "public/stylesheets/client.css": "client/stylesheets/*.less"

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

    clean:
      stylesheets: "public/javascripts/*"
      javascript: "public/stylesheets/*"


  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-less"
  grunt.loadNpmTasks "grunt-contrib-clean"
  #grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  #grunt.loadNpmTasks "grunt-contrib-copy"
  grunt.loadNpmTasks "grunt-mocha-cli"
  #grunt.loadNpmTasks "grunt-plato"


  grunt.registerTask "coffeescript", [ "coffee", "mochacli" ]
  grunt.registerTask 'test', ['mochacli']
  grunt.registerTask "default", [ "coffeescript", 'less']
  grunt.registerTask "prod", ["default", "uglify"]

  grunt.registerTask "server", ->
    server = require('./server')
    done = this.async();
    server.on('end', ->
      done()
    )

  grunt.registerTask 'serverDev', ['start', 'watch']

  grunt.registerTask 'start', ->
    require('./server')