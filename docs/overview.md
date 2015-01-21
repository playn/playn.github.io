---
layout: docs
---

# Overview

Here we describe the major components of the PlayN library and how they fit together. This is a
conceptual introduction, so we don't show a lot of code. For code, see the [tutorial](tutoria.html)
and the [cookbook](cookbook.html).

Overview of the overview:

* [Graphics](#graphics)
* [Game loop](#game-loop)
* [Audio](#audio)
* [Assets](#assets)
* [Network](#network)
* [Platforms](#platforms)

## Graphics

PlayN is a library for making games and graphics are pretty important to games, so we'll start
there. PlayN builds all of its graphics services on top of [OpenGL ES 2.0]. This is a low-level GPU
accelerated graphics library which is supported across all the desktop and mobile platforms
supported by PlayN.

### OpenGL

OpenGL is basically a big pile of functions, some of which manipulate invisible driver/GPU state,
and others of which build up buffers and commands to be sent to the GPU. PlayN exposes the OpenGL
ES 2.0 API pretty much unadulterated, with some minor bits of Java-fication, as the [GL20] class.
Games do not have to use the GL API directly, but it's useful to know that it's there if you need
it, and how the rest of PlayN is built atop GL so that if you do need to use GL directly, you know
where to plug in.

Useful classes:

* [GL20] - exposes the OpenGL ES 2.0 API directly
* [GL20.Buffers] - makes it easy to allocate and reuse byte, short, int, and float buffers; many
  GL calls either take or fill in a buffer
* [GLProgram] - somewhat simplifies the process of compiling and using GLSL shaders

### Disposable

When doing GPU programming, one often obtains handles to resources that are allocated on the GPU.
This includes things like [Texture] which contains a texture handle, [GLProgram] which contains a
shader program handle (and references a bunch of shader state). These things must be cleaned up
when you're done with them, in order to free up the GPU resources they consume. PlayN uses the
[Disposable] class to denote anything that should be cleaned up after.

Note that in every case, we also automatically dispose anything if it is garbage collected without
first having been disposed, but by manually disposing things when you're done with them, you ensure
that the resources are freed up sooner. This can be important when working with resource
constrained devices like mobile phones.

### RenderTarget

OpenGL can be used to render into the main frame buffer, or you can tell it to render into a
texture, which you can later draw into the frame buffer (presumably more than once). The
[RenderTarget] class takes care of the necessary OpenGL calls to bind the correct frame buffer and
it keeps track of the size of the surface into which you're rendering. Like [GLBatch] you don't
have to use `RenderTarget` if you're programming directly to the [GL20] API, but it can help to
simplify your code.

[Graphics] provides an instance of the `RenderTarget` that represents the main frame buffer, and
you can `create` a `RenderTarget` for any `Texture` that you like. Just be sure to dispose it when
you're done!

### QuadBatch

PlayN is first and foremost a 2D library. The standard approach for doing 2D using accelerated 3D
graphics is to draw a bunch of textured quads to the screen, and PlayN is no exception. The
[QuadBatch] class is the root of this process. One design choice made by PlayN is to assume that
every quad should have a full affine transformation accompanying it. This allows every quad to be
scaled, rotated and sheared in addition to simply having a location on the screen, without
requiring a batch flush. This means that we send more data per quad than an approach that only
allows translation and scaling, but if you need that kind of performance, you probably want to
write your own shader anyway.

Another choice PlayN makes for you is that all quads include a tint which is combined with the
texture color during rendering. Most of the time that tint will be `0xFFFFFF` and the texture color
will be unchanged. But this allows one to draw filled regions of color using the same shader used
for textured regions (we just tint a blank white texture), and it also allows you to cheaply
recolor your art assets if you want, say, a red team and a blue team. By bundling tint with every
quad, changing tint does not force a batch flush, which generally means better performance.

When doing OpenGL programming, one basically goes through the same set of steps over and over
again: configure GPU/driver state, put a bunch of data into a buffer, send that data to the GPU
along with instructions on how to draw it, repeat. The [GLBatch] class, which [QuadBatch] extends,
embodies that process. You `begin` a batch, do your drawing, potentially `flush` your batch along
the way, and then you `end` your batch when you're done. If you're programming directly to [GL20],
you don't have to use the [GLBatch] class, but it does help to organize your code.

Pretty much all QuadBatch implementations go through the following steps to do their rendering:

* at construct time, they compile their GLSL shader, get handles on the GLSL variables, and create
  any (GPU memory) buffers that they need
* `begin` - binds the GLSL shader program used by that batch, and binds associated GPU state
  (binds uniform variables which are valid for the entire batch, binds buffers, etc.)
* `addQuad` - adds geometry data to a big buffer which accumulates all the quads in the batch
* `flush` - is called automatically if you add a quad which uses a new texture, or if the geometry
  buffer fills up, or if you `end` the batch; this sends the buffer to the GPU with instructions
  on how to draw it
* `end` - flushes any remaining geometry, and then unbinds things that need not to be left in a
  weird state (disable vertex attrib array, for example)

Because we need to know when a batch starts and ends, you'll see this `begin/end` pairing show up
again in the [Surface] API.

Other useful classes:

* [UniformQuadBatch] - a `QuadBatch` implementation that only handles quads and sends data via GLSL
  uniform variables (can be more efficient than `TriangleBatch`)
* [TriangleBatch] - a `QuadBatch` implementation that sends quads a a pair of triangles; this
  means `TriangleBatch` also supports sending arbitrary triangle meshes to the GPU as well, so
  you'll want to use this if you want to send textured or outlined polygons

### Surface

Sending batches of textured quads to the GPU is great when you need high performance, but it's not
the most user friendly API. PlayN provides [Surface] for when you want to think about drawing in
the more traditional 2D sense. A `Surface` does a few useful things for you:

* it maintains a current affine transform and allows you do things like `rotate`, `scale`,
  and `translate` in between your other drawing commands
* it allows you to push the current affine transform onto a stack, mess with a copy of the
  transform while drawing some things, then pop that messed up transform off and go back to the old
  transform
* it allows you to treat textures as patterns and fill rectangles and lines with them in addition
  to just rendering images directly (under the hood, it's all the same to GL; just textured quads
  all the way down)
* it exposes a simplfied API for doing clipping; clip rectangles are intersected for you and
  maintained in a stack

Because `Surface` is rendering to a `QuadBatch` under the hood, you have to bracket all of your
drawing commands with calls to `begin` and `end`. This allows the `Surface` to tell the `QuadBatch`
when to send remaining rendering commands to the GPU.

`Surface` also has methods `pushBatch` and `popBatch` which allow you to switch batches during your
drawing. You might want a custom batch to include a triangle mesh via a [TriangleBatch] or maybe to
use a custom shader that specially tints or rotates things. Whatever you like!

`Surface` also works with a [RenderTarget], so you can use a `Surface` to render to the main frame
buffer or into a texture. The [TextureSurface] class extends [Surface] and packages in a [Texture]
and a [QuadBatch] to make it easy to create a texture, render into it, and then use that texture
later in your normal drawing.

### Texture and Tile

In addition to [Texture], which represents an actual OpenGL resource that can be used to texture a
quad, PlayN provides [Tile] which represents a sub-region of a texture. Both [Texture] and [Tile]
have `addToBatch` methods which do the necessary math to add the right geometry to a `QuadBatch` to
for either the whole texture or just the sub-region represented by a `Tile`.

Because texture atlasing is an extremely common approach to improving performance in game
rendering, `Tile` is a very useful abstraction. In addition to using them directly with
`QuadBatch`es, all of the high-level APIs accept `Tile` arguments: a `Texture` is just a `Tile`
which renders the whole texture.

Other useful classes:

* [TileSource] - handles the complications of delaying texture generation until asynchronous image
  loading has completed; used by the high-level APIs to accept either [Texture], [Tile], [Image] or
  [Image.Region] for display

### Canvas

In addition to GPU accelerated rendering, PlayN supports CPU rendering of more complex geometric
forms. This is accomplished via the [Canvas] API. This API is quite substantial, so you'll just
want to read through the Javadocs. Here's a quick list of some of the things you can do with
canvas:

* draw antialiased points and lines with caps and joins
* stroke and fill antialiased paths, rectangles, rounded rectangles, circles, and ellipses
* stroke and fill antialiased text using the platform's native text rendering services
* use Porter Duff blending modes
* clip to rectangles and arbitrary paths
* fill with solid colors and image patterns

`Canvas` uses the platform's native 2D drawing routines to render into CPU memory bitmaps. Those
bitmaps can then be uploaded to GPU memory to create textures for eventual drawing to the
framebuffer. Though there is no guarantee that every platform will create the same bit-for-bit
result from the same set of drawing commands, our experience has been that all the platforms
supported by PlayN are constistent enough to make this functionality very useful.

### Text rendering

Because text rendering is a complex and expensive procedure, one does not simply set the font on a
canvas and then call something like `drawString("Hello World.")`. Instead one passes the font and
antialiasing information (in the form of a [TextFormat] instance) along with the text to be laid
out to `Graphics.layoutText` and one gets back a [TextLayout] instance which contains information
on the bounding rectangle that contains the rendered text, as well as the ascent, descent and
leading information for the font. The `TextLayout` can then be passed to `Canvas.strokeText` or
`Canvas.fillText` for rendering.

One can also pass a [TextWrap] instance to have the text wrapped at a particular width. In that
case, one gets back an array of `TextLayout` instances which represent each line of the wrapped
text. The [TextBlock] class is provided to simplify the process of laying out and rendering
multiline text that is left, right and center justified, and which handles inter-line text spacing
according to the font's metrics.

It should be noted that the text layout and rendering capabilities of the HTML5 Canvas API (which
is what's used by the HTML backend) are //severely// limited. As a result, text rendering on that
platform is not as consistent and high quality as it is on the other platform backends.

### Scene graph

In addition to all of the above [immediate mode] rendering APIs, PlayN also provides a retained
mode API in the form of a 2D scene graph. This is a separate [playn-scene] library, which is
included as part of the core distribtion.

## Game loop

Most games have the same high-level architecture, which is dictated by the need to poll for user
input, use that input to update the state of the game, and render the current state of the game to
both visual and audio output buffers, all 30 to 60 times per second.

PlayN follows that same structure. With some frequency (each platform has its own restrictions and
requirements for configuring the game loop frequency), PlayN polls for user input, generates events
for that input (see [Input](#input) below for details), and then emits a frame signal to tell the
game to generate the next frame of graphics and audio output.

A game can do whatever it wants to generate its frame, but we also provide a [Game] class which
implements a common approach to game architecture that separates the frame into two parts:
simulation update and painting (rendering). A game often needs to update its simulation on a fixed
time step, and usually less frequently than the game is rendered. `Game` takes care of this by
splitting the `frame` signal into two signals: `update` and `paint`, along with [Clock] objects
which contain timing information appropriate to each.

The `update` signal always advances at a fixed time step, and thus may or may not fire during a
given frame. For example, if a game updated its simulation 30 times per second but rendered at 60
frames per second, the `update` signal would fire every other frame. Usually things are messier
than this, but that's what `Game` takes care of for you. You just specify your simulation update
rate, and you will get a series of signals with monotonically and consistently increasing `tick`
stamps which you use to drive your simulation.

You also get `paint` signals which you use to visualize your simulation. The `paint` signals have
their own `tick` which represents the actual amount of time that has elapsed up to that frame as
well as a `dt` which is how much time actually elapsed since the last frame. Those are useful for
animating things that are not tied to simulation state, but just need to vary over time.

For things that are tied to simulation state, `Clock` provides an `alpha` value which represents
the fraction of a simulation update interval that has elapsed since the simulation state was
updated. This `alpha` can be used to interpolate between the last simulation state and the
hypothetical next simulation state (which is usually dead reckoned). This allows the visualization
of simulation state to be drawn as smoothly and accurately as possible, even though the simulation
does not update as often as frames are drawn. More details on this approach can be found in [this
article](http://gafferongames.com/game-physics/fix-your-timestep/).

## Audio

PlayN supports both transient sound effects and streamed music. The API for sound effects and music
are the same ([Sound]), but under the hood different APIs are used to play and manage them. Sound
effects are expected to be short and there may be a lot of them playing at the same time. Music is
expected to play for a long time, and usually only one music instance will be playing at a time
(though this is not a requirement).

To give a concrete example of the behind the scenes difference: if your game is paused (the user
goes back to the home screen in the middle of your game), sound effects will either be allowed to
finish or will just be canceled, whereas music will be paused and automatically resumed when your
game is resumed.

Most backends use OpenAL for sound effects and whatever the platform provides for music streaming.
Once again the HTML5 backend is the redheaded stepchild and uses a hodge-podge of different
technologies to handle sound effect and music playback. The web seems to be [moving slowly toward
WebAudio](http://caniuse.com/#feat=audio-api) but it's not widely enough deployed for PlayN to rely
solely upon it for audio playback.

## Assets

The [Assets] class allows one to load [Image]s, [Sound]s, text and binary data. APIs are provided
for both synchronous (blocking) asset loading as well as asynchronous (non-blocking) asset loading.
The HTML5 platform only supports asynchronous loading, which means games that wish to support that
backend have to subject themselves to the vicissitudes of asynchrony whether they like it or not.

Fortunately, PlayN does a lot of work to make asynchronous asset loading as simple as possible. It
makes use of the [React] reactive programming library to model asynchrony via [RFuture]. One can
simply register a callback on a future to be notified when it completes or fails, but they can also
be composed in powerful ways: transforming the results when they arrive, chaining multiple futures
together and consolidating failure handling, sequencing multiple futures into a single future and
reacting to the completion or failure of all the sub-futures at once.

As mentioned above, the high-level 

## Network

TBD

## Platforms

TBD

[Assets]: http://playn.github.io/docs/core/api/playn/core/Assets.html
[Canvas]: http://playn.github.io/docs/core/api/playn/core/Canvas.html
[Clock]: http://playn.github.io/docs/core/api/playn/core/Clock.html
[Disposable]: http://playn.github.io/docs/core/api/playn/core/Disposable.html
[GL20.Buffers]: http://playn.github.io/docs/core/api/playn/core/GL20.Buffers.html
[GL20]: http://playn.github.io/docs/core/api/playn/core/GL20.html
[GLBatch]: http://playn.github.io/docs/core/api/playn/core/GLBatch.html
[GLBatch]: http://playn.github.io/docs/core/api/playn/core/GLBatch.html
[GLProgram]: http://playn.github.io/docs/core/api/playn/core/GLProgram.html
[Game]: http://playn.github.io/docs/core/api/playn/core/Game.html
[Graphics]: http://playn.github.io/docs/core/api/playn/core/Graphics.html
[Image.Region]: http://playn.github.io/docs/core/api/playn/core/Image.Region.html
[Image]: http://playn.github.io/docs/core/api/playn/core/Image.html
[Image]: http://playn.github.io/docs/core/api/playn/core/Image.html
[OpenGL ES 2.0]: https://www.khronos.org/opengles/2_X/
[QuadBatch]: http://playn.github.io/docs/core/api/playn/core/QuadBatch.html
[RFuture]: http://threerings.github.io/react/apidocs/react/RFuture.html
[React]: https://github.com/threerings/react
[RenderTarget]: http://playn.github.io/docs/core/api/playn/core/RenderTarget.html
[Sound]: http://playn.github.io/docs/core/api/playn/core/Sound.html
[Surface]: http://playn.github.io/docs/core/api/playn/core/Surface.html
[TextBlock]: http://playn.github.io/docs/core/api/playn/core/TextBlock.html
[TextFormat]: http://playn.github.io/docs/core/api/playn/core/TextFormat.html
[TextLayout]: http://playn.github.io/docs/core/api/playn/core/TextLayout.html
[TextWrap]: http://playn.github.io/docs/core/api/playn/core/TextWrap.html
[Texture]: http://playn.github.io/docs/core/api/playn/core/Texture.html
[TileSource]: http://playn.github.io/docs/core/api/playn/core/TileSource.html
[Tile]: http://playn.github.io/docs/core/api/playn/core/Tile.html
[TriangleBatch]: http://playn.github.io/docs/core/api/playn/core/TriangleBatch.html
[UniformQuadBatch]: http://playn.github.io/docs/core/api/playn/core/UniformQuadBatch.html
[immediate mode]: http://en.wikipedia.org/wiki/Immediate_mode_%28computer_graphics%29
[playn-scene]: http://playn.github.io/docs/scene/api/
