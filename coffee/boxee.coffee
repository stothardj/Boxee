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
    @gr[r][c].push(item)

  remove: (item, r, c) ->
    @gr[r][c].splice(@gr[r][c].indexOf(item), 1)

  forAllItems: (f) ->
    for row in @gr
      for cell in row
        for item in cell
          f(item)
  draw: (ctx) ->
    f = (item) -> item.draw(ctx)
    @forAllItems(f)

  update: ->
    f = (item) -> item.update()
    @forAllItems(f)
# Contains base functionality which can be assumed for all items added to a grid

class GridItem
  # Any constructed GridItem adds itself to the grid
  constructor: (@grid, @r, @c) ->
    grid.add( this, @r, @c )

  # You can call draw to redraw
  draw: (ctx) ->

  # You can call update for animation
  update: ->

  # You can call move to in order to ATTEMPT, to move an item. It may refuse to move based on rules
  # if you want to move an item ignoring rules and animations, just change the @r and @c
  moveTo: (r, c) ->#Pallete of colors to be used by game
pallete = [
    "#777777" # Border and Text
  , "#FFFFFF" # Background
  , "#CAEAC3"
  , "#C3EACF"
  , "#C3EAE3"
  , "#C3DDEA"
  , "#C3CAEA"
  , "#CFC3EA"
  , "#E3C3EA"
  , "#EAC3DD"
  , "#EAC3CA"
  , "#EACFC3"
  , "#EAE3C3"
  , "#DDEAC3"
  , "#A2DA95"
  , "#7ACA68"
  , "#CD95DA"
  , "#B868CA"
  ]

class Box extends GridItem
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
    ctx.strokeStyle = pallete[0]
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

class Person
  constructor: (@grid, @r, @c) ->
    grid.add( this, @r, @c )
    @anim = 0
    @destr = @r
    @destc = @c

  moveTo: (r, c) ->
    if @grid.validCoord(r, c) and @destr is @r and @destc is @c
      cell = @grid.get( r, c )
      if cell.length is 0
        @destr = r
        @destc = c
        @anim = 0
      else # Attempt to push all objects in that cell
        awayr = r
        awayc = c
        if r > @r
          awayr = r + 1
        else if r < @r
          awayr = r - 1
        if c > @c
          awayc = c + 1
        else if c < @c
          awayc = c - 1
        for item in cell
          item.moveTo( awayr, awayc )

  draw: (ctx) ->
    row = @r * (1 - @anim) + @destr * @anim
    col = @c * (1 - @anim) + @destc * @anim
    cellWidth = @grid.width / @grid.cols
    cellHeight = @grid.height / @grid.rows
    centerX = @grid.x + @grid.x + cellWidth * ( col + 0.5 )
    centerY = @grid.y + @grid.y + cellHeight * ( row + 0.5 )
    radius = Math.min( cellWidth, cellHeight ) / 2 - 1
    ctx.fillStyle = pallete[1]
    ctx.strokeStyle = pallete[0]
    ctx.beginPath()
    ctx.arc(centerX, centerY, radius, 0, Math.PI * 2, false)
    ctx.fill()
    ctx.stroke()
    ctx.closePath()

  update: ->
    if @anim < 1
      @anim += 0.2
    else
      @grid.remove( this, @r, @c )
      @r = @destr
      @c = @destc
      @grid.add( this, @r, @c )
# The definition of a level which can be saved
# in a text file
# Check out levels.coffee for some examples

class Level
  constructor: (@rows, @cols, @inst) ->

  createGrid: (x, y, width, height) ->
    g = new Grid( @rows, @cols, x, y, width, height )
    ls = @inst(g)
    g.person = ls[0]
    return g
class HeavyBox extends Box
  canMoveTo: (r, c) ->
    false

  color: pallete[9]
class Goal extends GridItem

  draw: (ctx) ->
    cellWidth = @grid.width / @grid.cols
    cellHeight = @grid.height / @grid.rows
    ctx.fillStyle = pallete[6]
    ctx.strokeStyle = pallete[0]
    centerX = @grid.x + cellWidth * (@c + 0.5)
    centerY = @grid.y + cellHeight * (@r + 0.5)
    # ctx.fillRect(@grid.x + cellWidth * @c, @grid.y + cellHeight * @r, cellWidth, cellHeight)
    ctx.beginPath()
    ctx.moveTo( centerX, centerY - cellHeight * 0.4 )
    ctx.lineTo( centerX + cellWidth * 0.12, centerY - cellHeight * 0.1 )
    ctx.lineTo( centerX + cellWidth * 0.4, centerY - cellHeight * 0.1 )
    ctx.lineTo( centerX + cellWidth * 0.2, centerY + cellHeight * 0.1 )
    ctx.lineTo( centerX + cellWidth * 0.3, centerY + cellHeight * 0.4 )
    ctx.lineTo( centerX, centerY + cellHeight * 0.2 )
    ctx.lineTo( centerX - cellWidth * 0.3, centerY + cellHeight * 0.4 )
    ctx.lineTo( centerX - cellWidth * 0.2, centerY + cellHeight * 0.1 )
    ctx.lineTo( centerX - cellWidth * 0.4, centerY - cellHeight * 0.1 )
    ctx.lineTo( centerX - cellWidth * 0.12, centerY - cellHeight * 0.1 )
    ctx.closePath()
    ctx.fill()
    ctx.stroke()

Levels = []

Levels.push new Level( 6, 10,
  (g) -> [ new Person(g, 5, 3), new Box(g, 4, 3), new Box(g, 4, 4), new HeavyBox(g, 1, 2), new Goal(g, 2, 2) ]
  )

BACKGROUND_COLOR = pallete[1]
BORDER_COLOR = pallete[0]

every = (ms, cb) -> setInterval(cb, ms)
doNothing = ->

canvas_l = document.getElementById("left_panel")
canvas_c = document.getElementById("center_panel")
canvas_r = document.getElementById("right_panel")
ctx_l = canvas_l.getContext("2d")
ctx_c = canvas_c.getContext("2d")
ctx_r = canvas_r.getContext("2d")

clearScreen = ( canvas, ctx ) ->
  ctx.fillStyle = BACKGROUND_COLOR
  ctx.fillRect(0,0,canvas.width,canvas.height)
  ctx.strokeStyle = BORDER_COLOR
  ctx.strokeRect(0,0,canvas.width,canvas.height)

drawTitleScreen = ->
  clearScreen( canvas_c, ctx_c )
  ctx_c.strokeStyle = ctx_c.fillStyle = pallete[0]
  ctx_c.font = "bold 50px sans-serif"
  ctx_c.textAlign = "center"
  ctx_c.fillText( "Boxee", canvas_c.width / 2, 60 )
  ctx_c.font = "bold 24px sans-serif"
  i = 0
  for txt in title.options
    if i is title.hovered
      ctx_c.fillText( txt, canvas_c.width / 2, 140 + i * 40 )
    else
      ctx_c.strokeText( txt, canvas_c.width / 2, 140 + i * 40 )
    i = i + 1

drawAboutScreen = ->
  clearScreen( canvas_c, ctx_c )
  ctx_c.fillStyle = pallete[0]
  ctx_c.font = "bold 50px sans-serif"
  ctx_c.textAlign = "center"
  ctx_c.fillText( "About", canvas_c.width / 2, 60 )
  ctx_c.font = "bold 14px san-serif"
  ctx_c.textAlign = "left"
  ctx_c.fillText( "Boxee is a simple puzzle game revolving", 120, 100 )
  ctx_c.fillText( "around pushing boxes out of the way to ", 120, 125 )
  ctx_c.fillText( "reach the goal. Various other obstacles", 120, 150 )
  ctx_c.fillText( "may also appear.", 120, 175 )
  ctx_c.fillText( "The game is written in Coffeescript by ", 120, 225 )
  ctx_c.fillText( "Jake Stothard. Contributions, including", 120, 250 )
  ctx_c.fillText( "puzzles, are welcome. Visit the Github ", 120, 275 )
  ctx_c.fillText( "page for details.", 120, 300 )
  ctx_c.fillText( "Press enter to return to the title screen", 120, 350 )

g = Levels[0].createGrid( 0, 0, canvas_c.width, canvas_c.height)
p = g.person

game = undefined
title = undefined
timeHandle = undefined

gameState =
  title: "Title"
  about: "About"
  gameover: "Game Over"
  editing: "Editing"
  playing: "Playing"
  crashed: "Crashed"

currentState = gameState.title

initGame = ->
  game =
    crashed: false


upkey = ->
downkey = ->
leftkey = ->
rightkey = ->
enterkey = ->

clearKeys = ->
  upkey = ->
  downkey = ->
  leftkey = ->
  rightkey = ->
  enterkey = ->

bindKeys = ->
  clearKeys()
  switch currentState
    when gameState.title
      upkey = ->
        if title.hovered is 0
          title.hovered = title.options.length - 1
        else
          title.hovered -= 1
        drawTitleScreen()
      downkey = ->
        if title.hovered is title.options.length - 1
          title.hovered = 0
        else
          title.hovered += 1
        drawTitleScreen()
      enterkey = ->
        title.actions[title.hovered]()

    when gameState.about
      enterkey = ->
        startTitle()

    when gameState.playing
      upkey = -> p.moveTo( p.r - 1, p.c )
      downkey = -> p.moveTo( p.r + 1, p.c )
      leftkey = -> p.moveTo( p.r, p.c - 1 )
      rightkey = -> p.moveTo( p.r, p.c + 1 )


drawKey = ->
  clearScreen( canvas_r, ctx_r )
  ctx_r.fillStyle = pallete[0]
  ctx_r.font = "bold 14px san-serif"
  ctx_r.textAlign = "center"
  ctx_r.fillText( "Key", canvas_r.width / 2, 20 )

startGame = ->
  currentState = gameState.playing
  initGame()
  bindKeys()
  drawKey()
  timeHandle = every 32, gameLoop

startAbout = ->
  currentState = gameState.about
  bindKeys()
  drawAboutScreen()

initTitle = ->
  title =
    hovered: 0
    options: [ "Play puzzles", "Level editor", "About" ]
    actions: [ startGame , doNothing , startAbout ]

startTitle = ->
  currentState = gameState.title
  initTitle()
  bindKeys()
  drawTitleScreen()

$(document)
  .keydown( (e) ->
    console.log e.which
    # This method only makes sense since I am planning on using very few keys
    switch e.which
      when 13
        enterkey()
      when 68, 39
        rightkey()
      when 83, 40
        downkey()
      when 65, 37
        leftkey()
      when 87, 38
        upkey()
  )

gameIteration = ->
  clearScreen( canvas_c, ctx_c )
  g.draw(ctx_c)
  g.update()

gameLoop = ->
  if game.crashed
    currentState = gameState.crashed
    clearInterval( timeHandle )
    return

  game.crashed = true

  gameIteration()

  game.crashed = false

switch currentState
  when gameState.playing
    startGame()
  when gameState.title
    startTitle()