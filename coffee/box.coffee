!import "grid.coffee"
!import "pallete.coffee"

class Box
  constructor: (@grid, @r, @c) ->
    grid.add( this, @r, @c )
    @anim = 0
    @destr = @r
    @destc = @c

  canMoveTo: (r, c) ->
    @grid.validCoord(r, c) and @grid.get(r, c).length is 0

  moveTo: (r, c) ->
    if @canMoveTo(r, c) and @destr is @r and @destc is @c
      @destr = r
      @destc = c
      @anim = 0

  color: pallete[2]

  draw: (ctx) ->
    row = @r * (1 - @anim) + @destr * @anim
    col = @c * (1 - @anim) + @destc * @anim
    cellWidth = @grid.width / @grid.cols
    cellHeight = @grid.height / @grid.rows
    ctx.fillStyle = @color
    ctx.fillRect(@grid.x + cellWidth * col, @grid.y + cellHeight * row, cellWidth, cellHeight)
    ctx.strokeStyle = pallete[4]
    ctx.strokeRect(@grid.x + cellWidth * col, @grid.y + cellHeight * row, cellWidth, cellHeight)

  update: ->
    if @anim < 1
      @anim += 0.2
    else
      # Good thing this isn't multithreaded
      @grid.remove( this, @r, @c )
      @r = @destr
      @c = @destc
      @grid.add( this, @r, @c )
