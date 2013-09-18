#global module:false
module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    nodemon:
      dev:
        options:
          file: 'server.coffee'
          #args: ['production']
          nodeArgs: ['--debug']
          #ignoredFiles: ['README.md', 'node_modules/**']
          watchedExtensions: ['coffee']
          watchedFolders: ['routes']
          #cwd: __dirname

    watch:
      options:
        livereload: true
      javascript:
        files: ["client/coffee/*.coffee"]
        tasks: "coffee"
      less:
        files: ['client/stylesheets/*.less']
        tasks: "less"
      server:
        files: ['routes/*.coffee', 'server.coffee']

    coffee:
      compile:
        files:
          "public/javascripts/client.js": ["client/coffee/app.coffee", "client/coffee/helper.coffee"]

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
  grunt.loadNpmTasks 'grunt-nodemon'


  grunt.registerTask 'test', ['mochacli']
  grunt.registerTask "compile", ["coffee", 'less']
  grunt.registerTask "prod", ['test', "compile", "uglify"]

  grunt.registerTask "server", ->
    server = require('./server')
    done = this.async();
    server.on('end', ->
      done()
    )

  grunt.registerTask 'serverDev', ['compile', 'nodemon', 'watch']

  grunt.registerTask 'start', ->
    require('./server')

  grunt.registerTask 'default', ['serverDev']