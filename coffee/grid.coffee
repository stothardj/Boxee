# A 2x2 grid in which you can have multiple items in each cell

class Grid
  constructor: (@rows, @cols, @x, @y, @width, @height) ->
    @gr = new Array(@rows)
    for i in [0..@rows-1]
      @gr[i] = new Array(@cols)
      for j in [0..@cols-1]
        @gr[i][j] = []

  validCoord: (r, c) ->
    r >= 0 and c >= 0 and r < @rows and c < @cols

  get: (r, c) ->
    @gr[r][c]

  add: (item, r, c) ->
    console.log "Adding item:"
    console.log item
    @gr[r][c].push(item)

  remove: (item, r, c) ->
    console.log "Removing item:"
    console.log item
    @gr[r][c].splice(@gr[r][c].indexOf(item), 1)

  forAllItems: (f) ->
    # Cannot simply call f on item in the deep loop in case f removes the item and readds it somewhere else
    # this is not just theoretical
    a = []
    for row in @gr
      for cell in row
        for item in cell
          a.push item
    for item in a
      f(item)

  draw: (ctx) ->
    f = (item) -> item.draw(ctx)
    @forAllItems(f)

  update: ->
    f = (item) -> item.update()
    @forAllItems(f)
