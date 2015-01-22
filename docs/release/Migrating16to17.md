---
layout: docs
---

# 1.6 to 1.7 migration

A few changes to basic project structures were made with the PlayN 1.7 release. This document
describes those changes and how to update your PlayN project to accommodate them.

## Game.Default

Previously your game implemented the `Game` interface and provided implementations of a few
methods:

```
public class MyGame implements Game {
  public void init () {}
  public void update (float delta) {}
  public void paint (float alpha) {}
  public int updateRate () { return N; }
}
```

Now your game should extend `Game.Default`, and pass its update rate into the `Game.Default`
constructor:

```
public class MyGame extends Game.Default {
  public MyGame () {
    super(N);
  }
  public void init () {}
  public void update (int delta) {}
  public void paint (float alpha) {}
}
```

Note also that `update` takes `int delta` instead of `float delta`. The delta value is a number of
milliseconds and was never non-integral.

This release also improves the smoothness of `update` and `paint` calls. As long as you are
properly using `alpha` to interpolate between simulation updates, you should simply see your game
run smoother.

If you wish to implement your own custom approach to `update` and `paint` you can implement `Game`
directly instead of using `Game.Default`. In that case, you implement the `tick` method (instead of
`update` and `paint`) and decide how to handle simulation updates and paints yourself:

```
public class MyGame implements Game {
  public void init () {}
  public void tick (int elapsed) {}
}
```

You can look at the [source
code](https://github.com/threerings/playn/blob/master/core/src/playn/core/Game.java) for
`Game.Default` to see how it handles simulation and painting updates, and tweak or replace the
default algorithm.

## Upstream JBox2D now supports GWT

Previously, PlayN maintained a fork of the JBox2D code base with small tweaks to make it work with
GWT (so that it would work with the HTML backend). Those tweaks have been merged upstream, and now
it is possible to use the latest release of JBox2D (2.2.1.1) directly with PlayN.

PlayN still provides a `playn-jbox2d` artifact, which provides a `DebugDraw2D` implementation that
allows one to render debug information for JBox2D games, but that artifact no longer provides
JBox2D itself. If your game does not use the HTML backend, you don't need to make any changes to
your project configuration. If your game does use JBox2D and the HTML backend, there are two
changes that are needed.

1. Add a dependency to the JBox2D source artifact to your `html/pom.xml`:

```
     <dependency>
      <groupId>org.jbox2d</groupId>
      <artifactId>jbox2d-library</artifactId>
      <version>${jbox2d.version}</version>
      <classifier>sources</classifier>
    </dependency>
```

Note that the `PlayN` project POM defines `jbox2d.version`, so you don't need to define that in
your top-level POM.

2. Change `GwtBox2D` to `JBox2D` in your GWT module file:

```
-  <inherits name="org.jbox2d.GwtBox2D" />
+  <inherits name="org.jbox2d.JBox2D" />
```

Using the latest version of JBox2D will require that you update your game to use the latest JBox2D
APIs. You can view the Box2D manual for information on the latest API: http://box2d.org/manual.pdf

## SurfaceLayer replaced with SurfaceImage + ImageLayer

A `Surface` provides a hardware accelerated bitmap into which a game can render, and which can then
be displayed in the scene graph. Previously surfaces were tightly bound a special layer,
`SurfaceLayer`, which was the only way to create and render to such a bitmap.

Now surfaces have been decoupled from layers and are just another kind of `Image`. `CanvasImage`
provides a non-hardware accelerated bitmap into which a game can render, and now `SurfaceImage`
provides a hardware accelerated bitmap into which a game can render. A `SurfaceImage` can then be
placed into one or more `ImageLayer` instances to be included in a scene graph, or a `SurfaceImage`
can be drawn via the immediate-mode rendering mechanism provided by `ImmediateLayer`.

If you had code like:

```
SurfaceLayer layer = graphics().createSurfaceLayer(width, height);
layer.surface().draw(...);
graphics().rootLayer().addAt(layer, 10, 10);
```

You can change that code to:

```
SurfaceImage image = graphics().createSurface(width, height);
image.surface().draw(...);
ImageLayer layer = graphics().createImageLayer(image);
graphics().rootLayer().addAt(layer, 10, 10);
```

Everything that was possible with `SurfaceLayer` is still possible with `SurfaceImage` and many
other previously impossible things are now possible. That said, there are some limitations in the
current implementation, some of which will be remedied in the future and some of which are simply
limitations due to the nature of surface images being GPU-managed bitmaps:

  * It is currently not possible to draw a `SurfaceImage` into a `Canvas`. This will throw an exception. It may be possible in the future to download the bitmap data from the GPU and draw it into the CPU image.
  * It is not possible to repeat a `SurfaceImage` in the x or y directions unless its size is a power of two on the to-be-repeated axes.
  * The `Pattern` returned by calling `Image.toPattern` on a `SurfaceImage` cannot currently be used when drawing to a `Canvas`. It can be used to draw to a `Surface`.
  * It is not possible to use `Image.BitmapTransformer` on a `SurfaceImage`.

I would have preferred to restructure the class hierarchy of `Image`, `CanvasImage` and
`SurfaceImage` to make it impossible to call methods on `SurfaceImage` which can never be made to
work, but it would have required `Image` to be changed to a new type, which would have been a
massive disruption to the codebase of every PlayN game in existence. So I decided that this
slightly sloppier API which admits impossible requests was a better approach.
