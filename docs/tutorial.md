---
layout: docs
---

# Tutorial

Here we explain how to make a simple [Reversi] game, from scratch, using PlayN. You may wish to
read the [overview](overview.html) before doing this tutorial, or just jump in and then refer back
to the overview if you run into anything confusing.

*Note*: this tutorial assumes you know how to program in Java. If you've never written Java code
but know some other language pretty well, you'll probably be fine. If you're new to Java *and*
programming, you'll need to work through a proper [Java
tutorial](http://www.google.com/search?q=Java+tutorial) first, because we're not going to spell out
every tiny detail here.

Before we get started, you need to do two important things:

* Set up your [development environment](setup.html)
* Create a [skeleton game](skeleton.html)

For the second step, this tutorial will assume that you used the following configuration when
creating your skeleton game:

* `groupId` - `io.playn.tutorial`
* `artifactId` - `reversi`
* `package` - `reversi`
* `JavaGameClassName` - `Reversi`

You can use whatever you like, but when we talk about particular classes, you'll have to remember
to mentally translate the names.

If you are having trouble getting Maven archetype generation working, or you just don't want to
bother, you can clone the [Reversi tutorial] project from Github. It contains the results of
invoking the Maven archetype generator with our suggested values.

Assuming you have a skeleton project, make sure you can run it and see the default rainbow
background:

```
cd reversi
mvn test -Pjava
```

If you're using an IDE, follow the same procedure outlined in the [development
environment](setup.html) instructions for running the game via your IDE.

You should see a window like this:

![Reversi skeleton screen](hello.png)

If you see the rainbow, then we're off to the races!

## Modeling

The first thing we need to do is come up with a data model for our game. This doesn't have anything
in particular to do with PlayN, but we can't get to any of the PlayN parts until we do it.

Reversi is a pretty simple game. There are two kinds of pieces, black and white. The board is 8x8
but we'll structure things to support arbitrary sizes. Players take turns placing pieces, so we
need to keep track of who's turn it is. That's about it. We'll also need the logic of figuring out
whether a move is legal and which pieces to flip over when a move is made. These are closely
related because a move is only legal if it flips over at least one piece.

To keep things simple, we'll declare an enum to represent the two kinds of pieces, use a player's
respective piece to determine whether it's their turn, and use a reactive map from a board
coordinate to the piece that occupies it. Edit `Reversi.java` thusly:

```java
public class Reversi extends SceneGame {

  public static enum Piece { BLACK, WHITE }

  public static class Coord {
    public final int x, y;

    public Coord (int x, int y) {
      assert x >= 0 && y >= 0;
      this.x = x;
      this.y = y;
    }

    public boolean equals (Coord other) {
      return other.x == x && other.y == y;
    }
    @Override public boolean equals (Object other) {
      return (other instanceof Coord) && equals((Coord)other);
    }
    @Override public int hashCode () { return x ^ y; }
    @Override public String toString () { return "+" + x + "+" + y; }
  }

  public final int boardSize = 8;
  public final RMap<Coord,Piece> pieces = RMap.create();
  public final Value<Piece> turn = Value.create(null);

  // ...
}
```

[Value] and [RMap] are from the [React] reactive programming library. They allow us to build a
model which automatically supports adding listeners which are notified when anything changes. We'll
see how that works below when we start wiring things up.

If you cloned the [Reversi tutorial] project, you can see the code up to this point by looking at
the [modeling](https://github.com/playn/reversi-tutorial#TODO) branch.

## Drawing

Now that we have a basic model for our game, we can jump right into drawing it. We'll get to game
logic and the general flow of the game later. We want to get something on the screen first because
we love pretty pictures.

### Drawing the board

We're going to create a [Layer] which draws the game board, so let's call it `BoardView`. We'll
start by just drawing the board grid and then work our way up to the pieces.

```java
public class BoardView extends Layer {
  private static final float LINE_WIDTH = 2;
  private final Reversi game;

  public final float cellSize;

  public BoardView (Reversi game, IDimension viewSize) {
    this.game = game;
    float maxBoardSize = Math.min(viewSize.width(), viewSize.height()) - 20;
    this.cellSize = (float)Math.floor(maxBoardSize / game.boardSize);
  }

  // we want two extra pixels in width/height to account for the grid lines
  @Override public float width () { return cellSize * game.boardSize + LINE_WIDTH; }
  @Override public float height () { return width(); } // width == height

  @Override protected void paintImpl (Surface surf) {
    surf.setFillColor(0xFF000000); // black with full alpha
    float top = 0, bot = height(), left = 0, right = width();

    // draw lines from top to bottom for each vertical grid line
    for (int yy = 0; yy <= game.boardSize; yy++) {
      float ypos = yy*cellSize+1;
      surf.drawLine(left, ypos, right, ypos, LINE_WIDTH);
    }

    // draw lines from left to right for each horizontal grid line
    for (int xx = 0; xx <= game.boardSize; xx++) {
      float xpos = xx*cellSize+1;
      surf.drawLine(xpos, top, xpos, bot, LINE_WIDTH);
    }
  }
}
```

We override `width` and `height`, which is not strictly necessary, but it will be convenient later
when we're doing the math to decide where to position the board view in the main game view.

The method that does all the work is `paintImpl`. Every [Layer] draws itself to a [Surface]. This
is an accelerated drawing API where every drawing command results in a quad getting added to a
[Quadbatch] for eventual rendering by the GPU. In this case, we're drawing some lines. Lines are
just really skinny quads which are filled, in this case, by a solid color. We could also use
[Surface].`setFillPattern` to fill them with a texture, if we wanted to be fancy.

We choose a line thickness of two because that ensures that the board remains an even number of
pixels in size. If the board is an odd size, then when we center it in the display it's drawn on a
half-pixel boundary which can result in blurriness or pixels in unexpected places. So that's
something to keep in mind when you're laying things out.

Now let's wire up our `Model` and `BoardView` so that we can actually see something show up on the
screen. We'll also get rid of that rainbow background. Change the `Reversi` constructor thusly:

```java
  public Reversi (Platform plat) {
    super(plat, 33); // update our "simulation" 33ms (30 times per second)

    // figure out how big the game view is
    final IDimension size = plat.graphics().viewSize;

    // create a layer that just draws a grey background
    rootLayer.add(new Layer() {
      protected void paintImpl (Surface surf) {
        surf.setFillColor(0xFFCCCCCC).fillRect(0, 0, size.width(), size.height());
      }
    });

    // create and add a board view
    rootLayer.addCenterAt(new BoardView(this, size), size.width()/2, size.height()/2);
  }
```

Note that by having the `BoardView` know its size, we can use the `addCenterAt` method, which
positions a layer's center at a specified position. In our case we want the center of the board at
the center of the whole game view.

When you run the game, you should now see a nice grid on a grey background:

![Reversi board with grid](reversi-drawing-grid.png)

You can see the code up to this point by looking at the
[drawing-board](https://github.com/playn/reversi-tutorial#TODO) branch.

### Drawing the pieces

That's a nice grid, now let's draw some pieces. We could just modify `BoardView` to draw piece
textures directly after it is done drawing the grid, but for a variety of reasons, it will turn out
to be easier to have each piece placed into its own [ImageLayer], so we'll do it that way.

The `BoardView` is just for drawing the grid, so let's introduce a `GameView` class which will
contain the board as well as the pieces on top of it. The game view will be a [GroupLayer], which
is a layer that contains children. It will contain the `BoardView` layer, as well as [ImageLayer]s
for all the pieces. We'll start by just putting the `BoardView` in it:

```
public class GameView extends GroupLayer {
  private final Reversi game;
  private final BoardView bview;

  public GameView (Reversi game, IDimension viewSize) {
    this.game = game;
    this.bview = new BoardView(game, viewSize);
    addCenterAt(bview, viewSize.width()/2, viewSize.height()/2);
  }
}
```

and change `Reversi.java` thusly:

```
-    // create and add a board view
-    rootLayer.addCenterAt(new BoardView(this, size), size.width()/2, size.height()/2);
+    // create and add a game view
+    rootLayer.add(new GameView(this, size));
```

Now we can get down to work on drawing some pieces. First we need to create some piece textures,
which we'll do using the [Canvas] API. Change `GameView` like so:

```java
  private final Tile[] ptiles = new Tile[Piece.values().length];

  public GameView (Reversi game, IDimension size) {
    // ...

    // draw a black piece and white piece into a single canvas image
    float size = bview.cellSize-2, hsize = size/2;
    Canvas canvas = game.plat.graphics().createCanvas(2*size, size);
    canvas.setFillColor(0xFF000000).fillCircle(hsize, hsize, hsize).
      setStrokeColor(0xFFFFFFFF).setStrokeWidth(2).strokeCircle(hsize, hsize, hsize-1);
    canvas.setFillColor(0xFFFFFFFF).fillCircle(size+hsize, hsize, hsize).
      setStrokeColor(0xFF000000).setStrokeWidth(2).strokeCircle(size+hsize, hsize, hsize-1);
    // convert the image to a texture and extract a texture region (tile) for each piece
    Texture ptex = canvas.toTexture();
    ptiles[Piece.BLACK.ordinal()] = ptex.tile(0, 0, size, size);
    ptiles[Piece.WHITE.ordinal()] = ptex.tile(size, 0, size, size);
  }
```

We create a `ptiles` array to hold the [Tile] for each piece image. A [Tile] is just a sub-region
of a [Texture]. Though it is not particularly relevant in a game as simple as this, it's good
practice to combine things into a single texture whenever possible to improve rendering
performance. In this case, both of our piece images are in a single [Texture], but the [Tile] API
makes it simple to treat the region for each piece separately.

We do the actual piece drawing using the [Canvas] API. A piece is just a filled circle with a
stroked outline. Then we turn the canvas's [Image] \(which is a CPU memory bitmap) into a [Texture]
\(which is a GPU memory bitmap) via `toTexture`. Note that `toTexture` also disposes the [Canvas]
which is what we want because we don't need the canvas any longer. Then we obtain our [Tile]s.

Note that we make our piece images a bit smaller than the cell size, so that they don't overlap the
grid lines or bump right up next to them. It looks a bit nicer. To avoid having to do a bunch of
fiddly math, we position our pieces based on the center of a cell, as we'll see in a moment. We
align the center of the piece to the center of the cell, so it doesn't matter if the piece is the
same size as the cell, or smaller, or bigger, it will always line up properly.

We could have made the texture the full size of the cell and just drawn a smaller circle inside it,
but rendering blank pixels is just as expensive as rendering filled pixels, so it would lower
rendering performance. That doesn't matter in this simple game, but we're trying to set a good
example.

Now we can create an [ImageLayer] for each piece using our piece tiles. Create two new methods in
`GameView`:

```java
  private void setPiece (Coord at, Piece piece) {
    ImageLayer pview = pviews.get(at);
    if (pview == null) {
      pview = new ImageLayer(ptiles[piece.ordinal()]);
      pview.setOrigin(pview.width()/2, pview.height()/2);
      addAt(pview, bview.cell(at.x) + bview.tx(), bview.cell(at.y) + bview.ty());
      pviews.put(at, pview);
    } else {
      pview.setTile(ptiles[piece.ordinal()]);
    }
  }

  private void clearPiece (Coord at) {
    ImageLayer pview = pviews.remove(at);
    if (pview != null) pview.close();
  }
```

`setPiece` will add a new piece to the board, or update an existing piece. In Reversi, we flip
pieces over, so this will handle changing a piece from black to white or vice versa. `clearPiece`
will remove a piece from the board. Pieces are never removed in a Reversi game, but this method
will be used when we restart the game and remove all the pieces from the previous game.

In `setPiece` we use `setOrigin` on the `ImageLayer` to indicate that we want to position the layer
based on its center rather than its upper left (which is the default). We then ask the `BoardView`
for the center of the desired grid cell (`bview.cell`), which is a method we'll need to add to
`BoardView`:

```java
  /** Returns the offset to the center of cell {@code cc} (in x or y). */
  public float cell (int cc) {
    // cc*cellSize is upper left corner, then cellSize/2 to center,
    // then 1 to account for our 2 pixel line width
    return cc*cellSize + cellSize/2 + 1;
  }
```

Note that we adjust the cell position by the current translation of `bview` (i.e. `bview.cell(at.x)
+ bview.tx()`). The `BoardView` returns its local coordinates, but we are adding the piece layer
directly to the `GameView`, so we need the coordinates to be in its coordinate system. We could
instead put `BoardView` and the piece layers into another `GroupLayer` which was positioned where
`BoardView` is now, then the pieces would share the same coordinate system as the board view, but
we won't really need to do this coordinate system fiddling anywhere else, so this is simpler.

The last bit of wiring we need is to react to the addition of pieces to the `Reversi.pieces` map
and create or update views for those pieces. Add the following to the end of the `GameView`
constructor:

```java
    game.pieces.connect(new RMap.Listener<Coord,Piece>() {
      @Override public void onPut (Coord coord, Piece piece) { setPiece(coord, piece); }
      @Override public void onRemove (Coord coord) { clearPiece(coord); }
    });
```

This adds a listener to the `pieces` reactive map which is notified whenever a map entry is `put`
or `remove`d. We make the appropriate changes to our views in response to those events.

You can try running the game, but you won't see pieces yet, because we haven't initialized the
game state. We need to add a method to `Reversi` to do that and then call it.

```java
  public Reversi (Platform plat) {
    // ...

    // create and add a game view
    rootLayer.add(new GameView(this, size));

    // start the game
    reset();
  }

  /** Clears the board and sets the 2x2 set of starting pieces in the middle. */
  public void reset () {
    pieces.clear();
    int half = boardSize/2;
    pieces.put(new Coord(half-1, half-1), Piece.WHITE);
    pieces.put(new Coord(half  , half-1), Piece.BLACK);
    pieces.put(new Coord(half-1, half  ), Piece.BLACK);
    pieces.put(new Coord(half  , half  ), Piece.WHITE);
    turn.update(Piece.BLACK);
  }
```

Because we call `reset` *after* we create our `GameView`, the game view will already be listening
to the `pieces` map and be ready to hear about the pieces as they're added to the reactive map.
With that call in place, we can run the game and we should see pieces:

![Reversi board with pieces](reversi-drawing-pieces.png)

Now we're ready to start working on game logic and user input.

You can see the code up to this point by looking at the
[drawing-pieces](https://github.com/playn/reversi-tutorial#TODO) branch.

## Input

## Logic

## Game flow

## Audio



[Canvas]: http://playn.github.io/docs/api/scene/playn/scene/Canvas.html
[GroupLayer]: http://playn.github.io/docs/api/scene/playn/scene/GroupLayer.html
[ImageLayer]: http://playn.github.io/docs/api/scene/playn/scene/ImageLayer.html
[Image]: http://playn.github.io/docs/api/core/playn/core/Image.html
[Layer]: http://playn.github.io/docs/api/scene/playn/scene/Layer.html
[RMap]: http://threerings.github.io/react/apidocs/react/RMap.html
[React]: https://github.com/threerings/react
[Reversi tutorial]: https://github.com/playn/reversi-tutorial
[Reversi]: http://en.wikipedia.org/wiki/Reversi
[Surface]: http://playn.github.io/docs/api/core/playn/core/Surface.html
[Texture]: http://playn.github.io/docs/api/core/playn/core/Texture.html
[Tile]: http://playn.github.io/docs/api/core/playn/core/Tile.html
[Value]: http://threerings.github.io/react/apidocs/react/Value.html
