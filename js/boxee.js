(function() {
  var BACKGROUND_COLOR, BORDER_COLOR, Box, Grid, HeavyBox, Level, Level1, Person, bindKeys, canvas, clearKeys, clearScreen, ctx, currentState, doNothing, downkey, drawAboutScreen, drawTitleScreen, enterkey, every, g, game, gameIteration, gameLoop, gameState, initGame, initTitle, leftkey, p, pallete, rightkey, startAbout, startGame, startTitle, timeHandle, title, upkey;
  var __hasProp = Object.prototype.hasOwnProperty, __extends = function(child, parent) {
    for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; }
    function ctor() { this.constructor = child; }
    ctor.prototype = parent.prototype;
    child.prototype = new ctor;
    child.__super__ = parent.prototype;
    return child;
  };
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
    Box.prototype.color = pallete[2];
    Box.prototype.draw = function(ctx) {
      var cellHeight, cellWidth, col, row;
      row = this.r * (1 - this.anim) + this.destr * this.anim;
      col = this.c * (1 - this.anim) + this.destc * this.anim;
      cellWidth = this.grid.width / this.grid.cols;
      cellHeight = this.grid.height / this.grid.rows;
      ctx.fillStyle = this.color;
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
  HeavyBox = (function() {
    __extends(HeavyBox, Box);
    function HeavyBox() {
      HeavyBox.__super__.constructor.apply(this, arguments);
    }
    HeavyBox.prototype.canMoveTo = function(r, c) {
      return false;
    };
    HeavyBox.prototype.color = pallete[3];
    return HeavyBox;
  })();
  Level1 = new Level(6, 10, function(g) {
    return [new Person(g, 5, 3), new Box(g, 4, 3), new Box(g, 4, 4), new HeavyBox(g, 1, 2)];
  });
  BACKGROUND_COLOR = pallete[5];
  BORDER_COLOR = pallete[4];
  every = function(ms, cb) {
    return setInterval(cb, ms);
  };
  doNothing = function() {};
  canvas = document.getElementById("can");
  ctx = canvas.getContext("2d");
  clearScreen = function() {
    ctx.fillStyle = BACKGROUND_COLOR;
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.strokeStyle = BORDER_COLOR;
    return ctx.strokeRect(0, 0, canvas.width, canvas.height);
  };
  drawTitleScreen = function() {
    var i, txt, _i, _len, _ref, _results;
    clearScreen();
    ctx.strokeStyle = ctx.fillStyle = pallete[4];
    ctx.font = "bold 50px sans-serif";
    ctx.textAlign = "center";
    ctx.fillText("Boxee", canvas.width / 2, 60);
    ctx.font = "bold 24px sans-serif";
    i = 0;
    _ref = title.options;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      txt = _ref[_i];
      if (i === title.hovered) {
        ctx.fillText(txt, canvas.width / 2, 140 + i * 40);
      } else {
        ctx.strokeText(txt, canvas.width / 2, 140 + i * 40);
      }
      _results.push(i = i + 1);
    }
    return _results;
  };
  drawAboutScreen = function() {
    clearScreen();
    ctx.fillStyle = pallete[4];
    ctx.font = "bold 50px sans-serif";
    ctx.textAlign = "center";
    ctx.fillText("About", canvas.width / 2, 60);
    ctx.font = "bold 14px san-serif";
    ctx.textAlign = "left";
    ctx.fillText("Boxee is a simple puzzle game revolving", 120, 100);
    ctx.fillText("around pushing boxes out of the way to ", 120, 125);
    ctx.fillText("reach the goal. Various other obstacles", 120, 150);
    ctx.fillText("may also appear.", 120, 175);
    ctx.fillText("The game is written in Coffeescript by ", 120, 225);
    ctx.fillText("Jake Stothard. Contributions, including", 120, 250);
    ctx.fillText("puzzles, are welcome. Visit the Github ", 120, 275);
    ctx.fillText("page for details.", 120, 300);
    return ctx.fillText("Press enter to return to the title screen", 120, 350);
  };
  g = Level1.createGrid(0, 0, canvas.width, canvas.height);
  p = g.person;
  game = void 0;
  title = void 0;
  timeHandle = void 0;
  gameState = {
    title: "Title",
    about: "About",
    gameover: "Game Over",
    editing: "Editing",
    playing: "Playing",
    crashed: "Crashed"
  };
  currentState = gameState.title;
  initGame = function() {
    return game = {
      crashed: false
    };
  };
  upkey = function() {};
  downkey = function() {};
  leftkey = function() {};
  rightkey = function() {};
  enterkey = function() {};
  clearKeys = function() {
    upkey = function() {};
    downkey = function() {};
    leftkey = function() {};
    rightkey = function() {};
    return enterkey = function() {};
  };
  bindKeys = function() {
    clearKeys();
    switch (currentState) {
      case gameState.title:
        upkey = function() {
          if (title.hovered === 0) {
            title.hovered = title.options.length - 1;
          } else {
            title.hovered -= 1;
          }
          return drawTitleScreen();
        };
        downkey = function() {
          if (title.hovered === title.options.length - 1) {
            title.hovered = 0;
          } else {
            title.hovered += 1;
          }
          return drawTitleScreen();
        };
        return enterkey = function() {
          return title.actions[title.hovered]();
        };
      case gameState.about:
        return enterkey = function() {
          return startTitle();
        };
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
  startGame = function() {
    currentState = gameState.playing;
    initGame();
    bindKeys();
    return timeHandle = every(32, gameLoop);
  };
  startAbout = function() {
    currentState = gameState.about;
    bindKeys();
    return drawAboutScreen();
  };
  initTitle = function() {
    return title = {
      hovered: 0,
      options: ["Play puzzles", "Level editor", "About"],
      actions: [startGame, doNothing, startAbout]
    };
  };
  startTitle = function() {
    currentState = gameState.title;
    initTitle();
    bindKeys();
    return drawTitleScreen();
  };
  $(document).keydown(function(e) {
    console.log(e.which);
    switch (e.which) {
      case 13:
        return enterkey();
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
      startGame();
      break;
    case gameState.title:
      startTitle();
  }
}).call(this);
