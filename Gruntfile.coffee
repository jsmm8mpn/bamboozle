#global module:false
module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

    concurrent:
      dev:
        tasks: ['nodemon:dev', 'watch']
        options:
          logConcurrentOutput: true

    nodemon:
      dev:
        options:
          file: 'server.coffee'
          nodeArgs: []
          watchedExtensions: ['coffee']
          watchedFolders: ['routes', './']
      debug:
        options:
          file: 'server.coffee'
          nodeArgs: ['--debug-brk']
          watchedExtensions: ['coffee']
          watchedFolders: ['routes']

    watch:
      options:
        livereload: true
      #server:
      #  files: ["server.coffee", "routes/*.coffee"]
      javascript:
        files: ["client/coffee/*.coffee"]
        tasks: "coffee"
      less:
        files: ['client/stylesheets/*.less']
        tasks: "less"

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
  grunt.loadNpmTasks 'grunt-concurrent'


  grunt.registerTask 'test', ['mochacli']
  grunt.registerTask "compile", ["coffee", 'less']
  grunt.registerTask "prod", ['test', "compile", "uglify"]

  grunt.registerTask "server", ->
    server = require('./server')
    done = this.async();
    server.on('end', ->
      done()
    )

  grunt.registerTask 'serverDev', ['compile', 'concurrent:dev']

  grunt.registerTask 'start', ->
    require('./server')

  grunt.registerTask 'default', ['serverDev']

  grunt.registerTask 'debug', ['compile', 'nodemon:debug', 'watch']