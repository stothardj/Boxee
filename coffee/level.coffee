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