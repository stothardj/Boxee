
# TODO: Stub to replace class I apparently forgot to commit
# Backwards engineered from javascript I thankfully did commit
class GridItem
  constructor: (@grid, @r, @c) ->
    grid.add( this, @r, @c )

  draw: (ctx) ->
  update: ->
  moveTo: (r, c) ->
    false
