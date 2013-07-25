noflo = require 'noflo'
###
if typeof process is 'object' and process.title is 'node'
  noflo = require "../../lib/NoFlo"
else
  noflo = require '../lib/NoFlo'
###

class NoFloDraggabilly extends noflo.Component
  
  description: 'Make shiz draggable'
  
  constructor: ->
    @options = {}
      
    @inPorts =      
      container: new noflo.Port 'object'
      options: new noflo.Port
      element: new noflo.Port 'object'
      #enable
      
    @outPorts =
      start: new noflo.ArrayPort 'object'
      moveX: new noflo.ArrayPort 'number'
      moveY: new noflo.ArrayPort 'number' 
      end: new noflo.ArrayPort 'object'        
      
    @inPorts.container.on "data", (data) =>
      @setOptions {containment:data}
    
    @inPorts.options.on "data", (data) =>
      @setOptions data
    
    @inPorts.element.on 'data', (element) =>
      @subscribe element
    
    
  subscribe: (element) => 
    console.log @options   
    draggie = @draggie = new Draggabilly element, @options 
    draggie.on 'dragStart', @dragstart
    draggie.on 'dragMove', @dragmove
    draggie.on 'dragEnd', @dragend
  
  setOptions: (options) ->
    console.log options
    throw new Error "Options is not an object" unless typeof options is "object"
    for own key, value of options
      @options[key] = value
  
  dragstart: (draggie, event, pointer) =>
    @outPorts.start.send event
    @outPorts.start.disconnect()
    # 
    @outPorts.moveX.send draggie.position.x
    @outPorts.moveY.send draggie.position.y
    
  dragmove: (draggie, event, pointer) =>
    @outPorts.moveX.send draggie.position.x #pointer.pageX
    @outPorts.moveY.send draggie.position.y #pointer.pageY

  dragend: (draggie, event, pointer) =>
    @outPorts.moveX.disconnect() if @outPorts.moveX.isConnected()
    @outPorts.moveY.disconnect() if @outPorts.moveY.isConnected()

    @outPorts.end.send event
    @outPorts.end.disconnect()

exports.getComponent = -> new NoFloDraggabilly
