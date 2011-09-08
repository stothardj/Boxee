!import "box.coffee"
!import "person.coffee"
!import "pallete.coffee"
!import "levels.coffee"

BACKGROUND_COLOR = pallete[1]
BORDER_COLOR = pallete[0]

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
  ctx.strokeStyle = ctx.fillStyle = pallete[0]
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
  ctx.fillStyle = pallete[0]
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

g = Levels[0].createGrid( 0, 0, canvas.width, canvas.height)
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