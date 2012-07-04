!import "box.coffee"

#TODO

class LightBox extends Box
  color: pallete[7]

  canMoveTo: (r, c) ->
    return false unless @grid.validCoord(r, c)
    movedAll = true
    dr = r - @r
    dc = c - @c
    nr = r + dr
    nc = c + dc
    # Attempt to push everything next to it, if that works then move into that spot
    for item in @grid.get(r, c)
      movedAll = item.moveTo(nr, nc) and movedAll
    return movedAll