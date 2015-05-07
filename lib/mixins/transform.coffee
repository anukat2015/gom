module.exports = ($) ->

  $.transform = transform = (nodes, transforms, args...) ->
    transforms = [transforms] unless transforms instanceof Array
    return _transform nodes, transforms, args

  _transform = (nodes, transforms, args) ->
    # return if falsy child
    return nodes unless nodes?

    return _transformNodes(nodes, transforms, args) if nodes instanceof Array

    # if child is function, evaluate it
    return _transform(node(), transforms, args) if typeof node is 'function'

    return _transformNode nodes, transforms, args

  _transformNodes = (nodes, transforms, args) ->
    newNodes = []
    for node in nodes
      newNode = _transform node, transforms, args
      # removes falsy children
      newNodes.push(newNode) if newNode
    newNodes

  _transformNode = (node, transforms, args) ->

    # Pass transforms & parent element to callback
    args = args?.slice() || [args]
    args.push(null) unless args.length
    args.unshift node
    args.push(transforms)
    # recurse children first
    # otherwise wrapping transforms = infinite loop
    if node.children?
      node.children = transform node.children, transforms, node

    for t in transforms

      if typeof t is 'function'
        node = t.apply $, args

      else if typeof t is 'object'
        for selector, callback of t
          node = callback.apply $, args if node.tag is selector

    node

  $