riot = require 'riot'
objectAssign = require 'object-assign'
setPrototypeOf = require 'setprototypeof'
isFunction = require 'is-function'

collapsePrototype = (collapse, proto)->
  if proto == View.prototype
    return

  parentProto = Object.getPrototypeOf proto
  collapsePrototype collapse, parentProto
  objectAssign collapse, parentProto

class View
  @register: ->
    new @

  tag:    ''
  html:   ''
  css:    ''
  attrs:  ''
  events: null

  constructor: ()->
    newProto = collapsePrototype {}, @

    @beforeInit()

    riot.tag @tag, @html, @css, @attrs, (opts)->
      if newProto?
        for k, v of newProto
          if isFunction(v)
            do (v) =>
              if @[k]?
                oldFn = @[k]
                @[k] = ()=>
                  oldFn.apply @, arguments
                  return v.apply @, arguments
              else
                @[k] = ()=>
                  return v.apply @, arguments
          else
            @[k] = v

      # Loop up the parents setting parent as the prototype so you have access to vars on it
      # Might be terrible, might be great, who knows?
      self = @
      parent = self.parent
      proto = Object.getPrototypeOf self
      while parent? && parent != proto
        setPrototypeOf self, parent
        self = parent
        parent = self.parent
        proto = Object.getPrototypeOf self

      if opts?
        for k, v of opts
          @[k] = v

      if @events?
        for name, handler of view.events
          do (name, handler) =>
            if typeof handler == 'string'
              @on name, ()=> @[handler].apply @, arguments
            else
              @on name, ()=> handler.apply @, arguments

      @init opts

  beforeInit: ()->
  init: ()->

module.exports = View
