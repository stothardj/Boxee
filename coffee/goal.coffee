!import "pallete.coffee"
!import "grid.coffee"
!import "griditem.coffee"

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
