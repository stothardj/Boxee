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
#Pallete of colors to be used by game
pallete = [ "#98BC80"
  , "#5B704C"
  , "#BDB980"
  , "#706E4C"
  , "#424242"
  , "#BDBDBD"
  ]

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
    ctx.fillStyle = pallete[0]
    ctx.strokeStyle = pallete[4]
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

  color: pallete[3]
Level1 = new Level( 6, 10,
  (g) -> [ new Person(g, 5, 3), new Box(g, 4, 3), new Box(g, 4, 4), new HeavyBox(g, 1, 2) ]
  )

BACKGROUND_COLOR = pallete[5]
BORDER_COLOR = pallete[4]

every = (ms, cb) -> setInterval(cb, ms)
doNothing = ->

canvas = document.getElementById("can")
ctx = canvas.getContext("2d")

clearScreen = ->
  ctx.fillStyle = BACKGROUND_COLOR
  ctx.fillRect(0,0,canvas.width,canvas.height)
  ctx.strokeStyle = BORDER_COLOR
  ctx.strokeRect(0,0,canvas.width,canvas.height)

drawTitleScreen = ->
  clearScreen()
  ctx.strokeStyle = ctx.fillStyle = pallete[4]
  ctx.font = "bold 50px sans-serif"
  ctx.textAlign = "center"
  ctx.fillText( "Boxee", canvas.width / 2, 60 )
  ctx.font = "bold 24px sans-serif"
  i = 0
  for txt in title.options
    if i is title.hovered
      ctx.fillText( txt, canvas.width / 2, 140 + i * 40 )
    else
      ctx.strokeText( txt, canvas.width / 2, 140 + i * 40 )
    i = i + 1

drawAboutScreen = ->
  clearScreen()
  ctx.fillStyle = pallete[4]
  ctx.font = "bold 50px sans-serif"
  ctx.textAlign = "center"
  ctx.fillText( "About", canvas.width / 2, 60 )
  ctx.font = "bold 14px san-serif"
  ctx.textAlign = "left"
  ctx.fillText( "Boxee is a simple puzzle game revolving", 120, 100 )
  ctx.fillText( "around pushing boxes out of the way to ", 120, 125 )
  ctx.fillText( "reach the goal. Various other obstacles", 120, 150 )
  ctx.fillText( "may also appear.", 120, 175 )
  ctx.fillText( "The game is written in Coffeescript by ", 120, 225 )
  ctx.fillText( "Jake Stothard. Contributions, including", 120, 250 )
  ctx.fillText( "puzzles, are welcome. Visit the Github ", 120, 275 )
  ctx.fillText( "page for details.", 120, 300 )
  ctx.fillText( "Press enter to return to the title screen", 120, 350 )

g = Level1.createGrid( 0, 0, canvas.width, canvas.height)
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


startGame = ->
  currentState = gameState.playing
  initGame()
  bindKeys()
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
  clearScreen()
  g.draw(ctx)
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