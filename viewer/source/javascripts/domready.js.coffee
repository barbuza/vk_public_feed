window.ready ?= (fn) ->

  fire = ->
    unless window.ready.fired
      window.ready.fired = true
      fn()

  return fire() if document.readyState is "complete"

  document.addEventListener "DOMContentLoaded", fire, false
  window.addEventListener "load", fire, false
