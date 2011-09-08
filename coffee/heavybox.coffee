!import "box.coffee"

class HeavyBox extends Box
  canMoveTo: (r, c) ->
    false

  color: pallete[9]