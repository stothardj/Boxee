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
