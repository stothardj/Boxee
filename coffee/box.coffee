!import "grid.coffee"
!import "griditem.coffee"
!import "pallete.coffee"

class Box extends GridItem
  constructor: (@grid, @r, @c) ->
    grid.add( this, @r, @c )
    @anim = 0
    @destr = @r
    @destc = @c

  canMoveTo: (r, c) ->
    @grid.validCoord(r, c) and @grid.get(r, c).length is 0

  moving: ->
    @destr isnt @r or @destc isnt @c

  # Return true if sucessfully moved, otherwise return false and do nothing
  moveTo: (r, c) ->
    if @canMoveTo(r, c) and not @moving()
      @destr = r
      @destc = c
      @anim = 0
      return true
    return false

  color: pallete[2]

  draw: (ctx) ->
    row = @r * (1 - @anim) + @destr * @anim
    col = @c * (1 - @anim) + @destc * @anim
    cellWidth = @grid.width / @grid.cols
    cellHeight = @grid.height / @grid.rows
    ctx.fillStyle = @color
    ctx.fillRect(@grid.x + cellWidth * col, @grid.y + cellHeight * row, cellWidth, cellHeight)
    ctx.strokeStyle = pallete[0]
    ctx.strokeRect(@grid.x + cellWidth * col, @grid.y + cellHeight * row, cellWidth, cellHeight)

  update: ->
    if @anim < 1
      @anim += 0.2
    else if @moving()
      # Good thing this isn't multithreaded
      @grid.remove( this, @r, @c )
      @r = @destr
      @c = @destc
      @grid.add( this, @r, @c )
