(function() {
  var BACKGROUND_COLOR, BORDER_COLOR, Box, Grid, Level, Level1, Person, bindKeys, canvas, clearScreen, ctx, currentState, downkey, every, g, game, gameIteration, gameLoop, gameState, initGame, leftkey, p, pallete, rightkey, timeHandle, upkey;
  Grid = (function() {
    function Grid(rows, cols, x, y, width, height) {
      var i, j, _ref, _ref2;
      this.rows = rows;
      this.cols = cols;
      this.x = x;
      this.y = y;
      this.width = width;
      this.height = height;
      this.gr = new Array(this.rows);
      for (i = 0, _ref = this.rows - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        this.gr[i] = new Array(this.cols);
        for (j = 0, _ref2 = this.cols - 1; 0 <= _ref2 ? j <= _ref2 : j >= _ref2; 0 <= _ref2 ? j++ : j--) {
          this.gr[i][j] = [];
        }
      }
    }
    Grid.prototype.validCoord = function(r, c) {
      return r >= 0 && c >= 0 && r < this.rows && c < this.cols;
    };
    Grid.prototype.get = function(r, c) {
      return this.gr[r][c];
    };
    Grid.prototype.add = function(item, r, c) {
      return this.gr[r][c].push(item);
    };
    Grid.prototype.remove = function(item, r, c) {
      return this.gr[r][c].splice(this.gr[r][c].indexOf(item), 1);
    };
    Grid.prototype.forAllItems = function(f) {
      var cell, item, row, _i, _len, _ref, _results;
      _ref = this.gr;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        row = _ref[_i];
        _results.push((function() {
          var _j, _len2, _results2;
          _results2 = [];
          for (_j = 0, _len2 = row.length; _j < _len2; _j++) {
            cell = row[_j];
            _results2.push((function() {
              var _k, _len3, _results3;
              _results3 = [];
              for (_k = 0, _len3 = cell.length; _k < _len3; _k++) {
                item = cell[_k];
                _results3.push(f(item));
              }
              return _results3;
            })());
          }
          return _results2;
        })());
      }
      return _results;
    };
    Grid.prototype.draw = function(ctx) {
      var f;
      f = function(item) {
        return item.draw(ctx);
      };
      return this.forAllItems(f);
    };
    Grid.prototype.update = function() {
      var f;
      f = function(item) {
        return item.update();
      };
      return this.forAllItems(f);
    };
    return Grid;
  })();
  pallete = ["#98BC80", "#5B704C", "#BDB980", "#706E4C", "#424242", "#BDBDBD"];
  Box = (function() {
    function Box(grid, r, c) {
      this.grid = grid;
      this.r = r;
      this.c = c;
      grid.add(this, this.r, this.c);
      this.anim = 0;
      this.destr = this.r;
      this.destc = this.c;
    }
    Box.prototype.canMoveTo = function(r, c) {
      return this.grid.validCoord(r, c) && this.grid.get(r, c).length === 0;
    };
    Box.prototype.moveTo = function(r, c) {
      if (this.canMoveTo(r, c) && this.destr === this.r && this.destc === this.c) {
        this.destr = r;
        this.destc = c;
        return this.anim = 0;
      }
    };
    Box.prototype.draw = function(ctx) {
      var cellHeight, cellWidth, col, row;
      row = this.r * (1 - this.anim) + this.destr * this.anim;
      col = this.c * (1 - this.anim) + this.destc * this.anim;
      cellWidth = this.grid.width / this.grid.cols;
      cellHeight = this.grid.height / this.grid.rows;
      ctx.fillStyle = pallete[3];
      ctx.fillRect(this.grid.x + cellWidth * col, this.grid.y + cellHeight * row, cellWidth, cellHeight);
      ctx.strokeStyle = pallete[4];
      return ctx.strokeRect(this.grid.x + cellWidth * col, this.grid.y + cellHeight * row, cellWidth, cellHeight);
    };
    Box.prototype.update = function() {
      if (this.anim < 1) {
        return this.anim += 0.2;
      } else {
        this.grid.remove(this, this.r, this.c);
        this.r = this.destr;
        this.c = this.destc;
        return this.grid.add(this, this.r, this.c);
      }
    };
    return Box;
  })();
  Person = (function() {
    function Person(grid, r, c) {
      this.grid = grid;
      this.r = r;
      this.c = c;
      grid.add(this, this.r, this.c);
      this.anim = 0;
      this.destr = this.r;
      this.destc = this.c;
    }
    Person.prototype.moveTo = function(r, c) {
      var awayc, awayr, cell, item, _i, _len, _results;
      if (this.grid.validCoord(r, c) && this.destr === this.r && this.destc === this.c) {
        cell = this.grid.get(r, c);
        if (cell.length === 0) {
          this.destr = r;
          this.destc = c;
          return this.anim = 0;
        } else {
          awayr = r;
          awayc = c;
          if (r > this.r) {
            awayr = r + 1;
          } else if (r < this.r) {
            awayr = r - 1;
          }
          if (c > this.c) {
            awayc = c + 1;
          } else if (c < this.c) {
            awayc = c - 1;
          }
          _results = [];
          for (_i = 0, _len = cell.length; _i < _len; _i++) {
            item = cell[_i];
            _results.push(item.moveTo(awayr, awayc));
          }
          return _results;
        }
      }
    };
    Person.prototype.draw = function(ctx) {
      var cellHeight, cellWidth, centerX, centerY, col, radius, row;
      row = this.r * (1 - this.anim) + this.destr * this.anim;
      col = this.c * (1 - this.anim) + this.destc * this.anim;
      cellWidth = this.grid.width / this.grid.cols;
      cellHeight = this.grid.height / this.grid.rows;
      centerX = this.grid.x + this.grid.x + cellWidth * (col + 0.5);
      centerY = this.grid.y + this.grid.y + cellHeight * (row + 0.5);
      radius = Math.min(cellWidth, cellHeight) / 2 - 1;
      ctx.fillStyle = pallete[0];
      ctx.strokeStyle = pallete[4];
      ctx.beginPath();
      ctx.arc(centerX, centerY, radius, 0, Math.PI * 2, false);
      ctx.fill();
      ctx.stroke();
      return ctx.closePath();
    };
    Person.prototype.update = function() {
      if (this.anim < 1) {
        return this.anim += 0.2;
      } else {
        this.grid.remove(this, this.r, this.c);
        this.r = this.destr;
        this.c = this.destc;
        return this.grid.add(this, this.r, this.c);
      }
    };
    return Person;
  })();
  Level = (function() {
    function Level(rows, cols, inst) {
      this.rows = rows;
      this.cols = cols;
      this.inst = inst;
    }
    Level.prototype.createGrid = function(x, y, width, height) {
      var g, ls;
      g = new Grid(this.rows, this.cols, x, y, width, height);
      ls = this.inst(g);
      g.person = ls[0];
      return g;
    };
    return Level;
  })();
  Level1 = new Level(6, 10, function(g) {
    return [new Person(g, 5, 3), new Box(g, 4, 3), new Box(g, 4, 4)];
  });
  BACKGROUND_COLOR = pallete[5];
  BORDER_COLOR = pallete[4];
  every = function(ms, cb) {
    return setInterval(cb, ms);
  };
  canvas = document.getElementById("can");
  ctx = canvas.getContext("2d");
  clearScreen = function() {
    ctx.fillStyle = BACKGROUND_COLOR;
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.strokeStyle = BORDER_COLOR;
    return ctx.strokeRect(0, 0, canvas.width, canvas.height);
  };
  g = Level1.createGrid(0, 0, canvas.width, canvas.height);
  p = g.person;
  game = void 0;
  timeHandle = void 0;
  gameState = {
    title: "Title",
    gameover: "Game Over",
    editing: "Editing",
    playing: "Playing",
    crashed: "Crashed"
  };
  currentState = gameState.playing;
  initGame = function() {
    return game = {
      crashed: false
    };
  };
  upkey = function() {};
  downkey = function() {};
  leftkey = function() {};
  rightkey = function() {};
  bindKeys = function() {
    switch (currentState) {
      case gameState.playing:
        upkey = function() {
          return p.moveTo(p.r - 1, p.c);
        };
        downkey = function() {
          return p.moveTo(p.r + 1, p.c);
        };
        leftkey = function() {
          return p.moveTo(p.r, p.c - 1);
        };
        return rightkey = function() {
          return p.moveTo(p.r, p.c + 1);
        };
    }
  };
  $(document).keydown(function(e) {
    console.log(e.which);
    switch (e.which) {
      case 68:
      case 39:
        return rightkey();
      case 83:
      case 40:
        return downkey();
      case 65:
      case 37:
        return leftkey();
      case 87:
      case 38:
        return upkey();
    }
  });
  gameIteration = function() {
    clearScreen();
    g.draw(ctx);
    return g.update();
  };
  gameLoop = function() {
    if (game.crashed) {
      currentState = gameState.crashed;
      clearInterval(timeHandle);
      return;
    }
    game.crashed = true;
    gameIteration();
    return game.crashed = false;
  };
  switch (currentState) {
    case gameState.playing:
      initGame();
      bindKeys();
      timeHandle = every(32, gameLoop);
  }
}).call(this);
