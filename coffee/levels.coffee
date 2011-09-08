!import "level.coffee"
!import "box.coffee"
!import "heavybox.coffee"
!import "person.coffee"

Level1 = new Level( 6, 10,
  (g) -> [ new Person(g, 5, 3), new Box(g, 4, 3), new Box(g, 4, 4), new HeavyBox(g, 1, 2) ]
  )
