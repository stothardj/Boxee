!import "pallete.coffee"

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
