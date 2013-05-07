module.exports = ->
  # Project configuration
  @initConfig
    pkg: @file.readJSON 'package.json'

    # CoffeeScript compilation
    coffee:
      src:
        expand: true
        cwd: 'src'
        src: ['**.coffee']
        dest: 'src'
        ext: '.js'

    # Browser version building
    component:
      install:
        options:
          action: 'install'
    component_build:
      draggabilly:
        output: './dist/'
        config: './component.json'
        scripts: true
        styles: false
        plugins: ['coffee']
        configure: (builder) ->
          # Enable Component plugins
          json = require 'component-json'
          builder.use json()


    # Automated recompilation and testing when developing
    watch:
      files: ['test/*.coffee', 'src/**/*.coffee']
      tasks: ['test']

    # Release automation
    bumpup: ['package.json', 'component.json']
    
    tagrelease:
      file: 'package.json'
      prefix: ''
      
    exec:
      npm_publish:
        cmd: 'npm publish'

  # Grunt plugins used for building
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-component'
  @loadNpmTasks 'grunt-component-build'
  @loadNpmTasks 'grunt-contrib-uglify'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-contrib-watch'
  #@loadNpmTasks 'grunt-contrib-nodeunit'
  #@loadNpmTasks 'grunt-cafe-mocha'
  #@loadNpmTasks 'grunt-mocha-phantomjs'
  @loadNpmTasks 'grunt-coffeelint'

  # Grunt plugins used for release automation
  @loadNpmTasks 'grunt-bumpup'
  @loadNpmTasks 'grunt-tagrelease'
  @loadNpmTasks 'grunt-exec'

  # Our local tasks
  @registerTask 'build', 'Build NoFlo for the chosen target platform', (target = 'all') =>
    #@task.run 'coffee'
    if target is 'all' or target is 'browser'
      @task.run 'component'
      @task.run 'component_build'
      #@task.run 'uglify'
    
  @registerTask 'test', 'Build NoFlo and run automated tests', (target = 'all') =>
    #@task.run 'coffeelint'
    #@task.run 'coffee'
    #if target is 'all' or target is 'nodejs'
    #  @task.run 'nodeunit'
    #  @task.run 'cafemocha'
    if target is 'all' or target is 'browser'
      @task.run 'component'
      @task.run 'component_build'
      #@task.run 'mocha_phantomjs'
    
  @registerTask 'default', ['test']

  # Task for releasing new NoFlo versions
  #
  # Builds, runs tests, updates package.json, tags a release, and publishes on NPM
  #
  # Usage: grunt release:patch
  @registerTask 'release', 'Build, test, tag, and release NoFlo', (type = 'patch') =>
    @task.run 'build'
    @task.run 'test'
    @task.run "bumpup:#{type}"
    @task.run 'tagrelease'
    @task.run 'exec:npm_publish'
