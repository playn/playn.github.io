---
layout: docs
---

# Tutorial

Here we explain how to make a simple [Reversi] game, from scratch, using PlayN. You may wish to
read the [overview](overview.html) before doing this tutorial, or just jump in and then refer back
to the overview if you run into anything confusing.

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
bother, you can clone the [Reversi tutorial] project from Github, which contains the results of
invoking the Maven archetype generator with our suggested values.

Assuming you have a skeleton project, make sure you can run it and see the default rainbow
background:

```
cd reversi
mvn test -Pjava
```

Or right click on `ReversiJava.java` in Eclipse and choose 'Run as -> Java application'.

You should see a window like this:

![Reversi skeleton screen](hello.png)

If you see the rainbow, then we're off to the races!

## Modeling

The first thing we need to do is come up with a data model for our game. This doesn't have anything
in particular to do with PlayN, but we can't get to any of the PlayN parts until we do it.

Reversi is a pretty simple game. There are two kinds of pieces, black and white. The board is 8x8
though we could easily support other sizes. Players take turns placing pieces, so we'll need to
keep track of who's turn it is. That's about it. We'll also need the logic of figuring out whether
a move is legal and which pieces to flip over when a move is made. These are closely related
because a move is only legal if it flips over at least one piece.

To keep things simple, we'll declare an enum to represent the two kinds of pieces, use a player's
respective piece to determine whether it's their turn, and use a 2D array of pieces to represent
the board.

## Drawing

## Input

## Audio



[Reversi]: http://en.wikipedia.org/wiki/Reversi
[Reversi tutorial]: https://github.com/playn/reversi-tutorial
