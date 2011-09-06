!import "box.coffee"
!import "person.coffee"
!import "pallete.coffee"
!import "levels.coffee"

BACKGROUND_COLOR = pallete[5]
BORDER_COLOR = pallete[4]

every = (ms, cb) -> setInterval(cb, ms)

canvas = document.getElementById("can")
ctx = canvas.getContext("2d")

clearScreen = ->
        ctx.fillStyle = BACKGROUND_COLOR
        ctx.fillRect(0,0,canvas.width,canvas.height)
        ctx.strokeStyle = BORDER_COLOR
        ctx.strokeRect(0,0,canvas.width,canvas.height)

g = Level1.createGrid( 0, 0, canvas.width, canvas.height)
p = g.person

game = undefined
timeHandle = undefined

gameState =
        title: "Title"
        gameover: "Game Over"
        editing: "Editing"
        playing: "Playing"
        crashed: "Crashed"

currentState = gameState.playing

initGame = ->
        game =
                crashed: false

upkey = ->
downkey = ->
leftkey = ->
rightkey = ->

bindKeys = ->
        switch currentState
                when gameState.playing
                        upkey = -> p.moveTo( p.r - 1, p.c )
                        downkey = -> p.moveTo( p.r + 1, p.c )
                        leftkey = -> p.moveTo( p.r, p.c - 1 )
                        rightkey = -> p.moveTo( p.r, p.c + 1 )

$(document)
        .keydown( (e) ->
                console.log e.which
                switch e.which
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
                initGame()
                bindKeys()
                timeHandle = every 32, gameLoop
