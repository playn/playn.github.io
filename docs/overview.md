---
layout: docs
---

# Overview

Here we describe the major components of the PlayN library and how they fit together. This is a
conceptual introduction, so we don't show a lot of code. For code, see the
[tutorials](index.html#tutorials) and the [cookbook](/cookbook/).

Overview of the overview:

* [Graphics](#graphics)
* [Game loop](#game-loop)
* [Audio](#audio)
* [Assets](#assets)
* [Input](#input)
* [Network](#network)
* [Scene graph](#scene-graph)
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
  GL calls either read from, or write to, a buffer
* [GLProgram] - somewhat simplifies the process of compiling and using GLSL shaders

### Disposable

When doing GPU programming, one often obtains handles to resources that are allocated on the GPU.
This includes things like [Texture] which contains a texture handle, [GLProgram] which contains a
shader program handle (and references a bunch of shader state). These things must be cleaned up
when you're done with them, in order to free up the GPU resources they consume. PlayN uses the
[Disposable] class to denote anything that should be disposed.

Note that in every case, we also automatically dispose anything if it is garbage collected without
first having been disposed, but by manually disposing things when you're done with them, you ensure
that the resources are freed up sooner. This can be important when working with resource
constrained devices like mobile phones.

### RenderTarget

OpenGL can be used to render into the main frame buffer, or you can tell it to render into a
texture for later reuse. The [RenderTarget] class takes care of the necessary OpenGL calls to bind
the correct frame buffer and it keeps track of the size of the surface into which you're rendering.
Like [GLBatch] you don't have to use `RenderTarget` if you're programming directly to the [GL20]
API, but it can help to simplify your code.

[Graphics] provides an instance of the `RenderTarget` that represents the main frame buffer, and
you can `create` a `RenderTarget` for any `Texture` that you like. Just be sure to dispose it when
you're done!

### QuadBatch

PlayN is first and foremost a 2D library. The standard approach for doing 2D using accelerated 3D
graphics is to draw a bunch of textured quads to the screen; PlayN is no exception. The [QuadBatch]
class does this job.

One design choice made by PlayN is to assume that every quad should have a full affine
transformation accompanying it. This allows a bunch of arbitrarily transformed quads to be drawn in
a single batch (assuming they reference the same texture). This requires six floats per quad, where
a "scale and translation"-only approach might only need three, but we think this is better for the
general case. If you need maximum performance and are drawing a zillion unrotated, unsheared quads,
then you can pretty easily write your own QuadBatch to do it.

Another choice PlayN makes for you is that all quads include a tint, which is combined with the
texture color during rendering. Most of the time that tint will be `0xFFFFFFFF` (AARRGGBB) and the
texture color will be unchanged. This allows one to draw filled regions of color using the same
shader used for textured regions (we just tint a blank white texture). It also allows you to
cheaply recolor your art assets if you want, say, a red team and a blue team. By bundling tint with
every quad, changing tint does not force a batch flush.

When doing OpenGL programming, one goes through the same set of steps over and over again:
configure GPU/driver state, put a bunch of data into a buffer, send that data to the GPU along with
instructions on how to draw it, repeat. The [GLBatch] class, which [QuadBatch] extends, manages
that process. You `begin` a batch, do your drawing, which might trigger `flush`es along the way,
and then you `end` your batch when you're done. If you're programming directly to [GL20], you don't
have to use the [GLBatch] class, but it does help to organize your code.

Pretty much all QuadBatch implementations work something like this:

* `constructor` - compile a GLSL shader, get handles on the GLSL variables, create any (GPU memory)
  buffers that are needed
* `begin` - bind the GLSL shader program and associated GPU state (uniform variables, buffers, etc.)
* `addQuad` - add geometry data to a big buffer which accumulates all the quads in the batch
* `flush` - is called automatically if you add a quad which uses a new texture, or if the geometry
  buffer fills up, or if you `end` the batch; this sends the buffer to the GPU with instructions
  on how to draw it
* `end` - flush any remaining geometry, and then unbind things that need not to be left in a
  weird state (disable vertex attrib array, for example)

Because we need to know when a batch starts and ends, you'll see this `begin/end` pairing show up
again in the [Surface] API.

Other useful classes:

* [UniformQuadBatch] - a `QuadBatch` implementation that only handles quads and sends data via GLSL
  uniforms (sends a lot less data per quad than `TriangleBatch`)
* [TriangleBatch] - a `QuadBatch` implementation that sends quads as a four vertices and six indices
  (a pair of triangles); this means `TriangleBatch` also supports sending arbitrary triangle meshes
  to the GPU as well, so you'll want to use this if you want to draw (GPU accelerated) arbitrary
  polygons

### Surface

Sending batches of textured quads to the GPU is great when you need high performance, but it's not
the most user friendly API. PlayN provides [Surface] for when you want to think about drawing in
the more traditional 2D sense. A `Surface` does a few useful things for you:

* it maintains a current affine transform and allows you do things like `rotate`, `scale`,
  and `translate` in between your other drawing commands
* it allows you to push the current affine transform onto a stack, mess with a copy of the
  transform while drawing some things, then pop that messed up transform off and go back to the old
  transform
* it allows you to treat textures as patterns and fill rectangles and lines with them (under the
  hood, it's all the same to GL: textured quads all the way down)
* it exposes a simplified API for doing clipping; clip rectangles are intersected for you and
  maintained in a stack

Because `Surface` is rendering to a `QuadBatch` under the hood, you have to bracket all of your
drawing commands with calls to `begin` and `end`. This allows the `Surface` to tell the `QuadBatch`
when to flush rendering commands to the GPU.

`Surface` also has methods `pushBatch` and `popBatch` which allow you to switch batches during your
drawing. You might want a custom batch to include a triangle mesh via a [TriangleBatch] or maybe to
use a custom shader to sepia tone everything. Whatever you like!

`Surface` also works with a [RenderTarget], so you can use a `Surface` to render to the main frame
buffer or into a texture. The [TextureSurface] class packages up a [Texture] and a [QuadBatch] to
make it easy to create a texture, render into it, and then use it later in your normal drawing.

### Texture and Tile

In addition to [Texture], which represents an actual OpenGL resource that can be used to texture a
quad, PlayN provides [Tile] which represents a sub-region of a texture. Both [Texture] and [Tile]
have `addToBatch` methods which do the necessary math to add the right geometry to a `QuadBatch` to
for either the whole texture or just the sub-region represented by a `Tile`.

Because texture atlasing is an extremely common approach to improving performance in game
rendering, `Tile` is a very useful abstraction. In addition to using them directly with
`QuadBatch`es, all of the high-level APIs accept `Tile` arguments: a `Texture` is just a `Tile`
which renders the whole texture.

*Managed textures*: often times you don't want to think about manually creating and disposing
textures, particularly when using the scene graph API described below. For those circumstances,
PlayN supports reference counted textures. You note a texture as managed when you create it, and
when that texture is added to, for example, an `ImageLayer`, its reference count will be
incremented. When that `ImageLayer` is destroyed, its reference count is decremented, and when the
reference count goes to zero, the texture is automatically destroyed.

This allows you to "fire and forget" a texture into one or more layers and know that as long as you
dispose your scene graph when you're done, all the textures inside it will be properly disposed as
well.

If you're drawing textures directly to a `Surface`, you probably don't want to use reference
counting, and instead will want to manage textures manually.

Other useful classes:

* [TileSource] - handles the complications of delaying texture generation until asynchronous image
  loading has completed; used by the high-level APIs to accept either [Texture], [Tile], [Image] or
  [Image.Region] for display

### Canvas

In addition to GPU accelerated rendering, PlayN supports CPU rendering of more complex geometric
forms. This is accomplished via the [Canvas] API. This API is quite substantial, so you'll likely
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
supported by PlayN are consistent enough to make this functionality very useful.

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
multiline text. It also handles left, right and center justification, and inter-line text spacing
according to the font's metrics.

It should be noted that the text layout and rendering capabilities of the HTML5 Canvas2d API (which
is what's used by the HTML backend) are _severely_ limited. As a result, text rendering on that
platform is not as consistent and high quality as it is on the other platform backends.

### Retained mode

In addition to all of the above [immediate mode] rendering APIs, PlayN also provides a retained
mode API in the form of a 2D scene graph. This is a separate [playn-scene] library, which is
included as part of the core distribution and described below in the [Scene graph](#scene-graph)
section.

## Game loop

Most games have the same high-level architecture, which is dictated by the need to poll for user
input, use that input to update the state of the game, and render the current state of the game to
both visual and audio output buffers, all 30 to 60 times per second.

PlayN follows that same structure. With some frequency (each platform has its own restrictions and
requirements for configuring the game loop frequency), PlayN polls for user input, generates events
for that input (see [Input](#input) below for details), and then emits the [Platform].`frame`
signal to tell the game to generate the next frame of graphics and audio output.

A game can do whatever it wants to generate its frame, but we also provide a [Game] class that
implements a common approach to game architecture which separates the frame into two parts:
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

In addition to the `frame` signal and the game loop, PlayN reports certain lifecycle events via the
[Platform].`lifecycle` signal. This is mainly useful on mobile where a game can be put into the
background, but the desktop Java platform also reports the game as paused when its window loses
focus, and resumed when the window regains focus.

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

Due to the widely varying platform sound APIs, PlayN is not able to provide great latency
guarantees on sound effect playback. It does provide [Sound].`prepare` to allow a game to indicate
that it plans to play one or more sounds soon, and backends that can will use that hint to pre-load
those sounds' data in order to reduce latency on the first `play` call.

## Assets

The [Assets] class allows one to load [Image]s, [Sound]s, text and binary data. APIs are provided
for both synchronous (blocking) asset loading as well as asynchronous (non-blocking) asset loading.
The HTML5 platform only supports asynchronous loading, which means games that wish to support that
backend have to subject themselves to the vicissitudes of asynchrony whether they like it or not.

Fortunately, PlayN does a lot of work to make asynchronous asset loading as simple as possible. It
uses the [React] reactive programming library to model asynchrony via [RFuture]. For simple cases a
callback can be registered on a future to be invoked when it completes or fails, but futures can
also be composed in powerful ways: transforming the results when they arrive, chaining multiple
futures together and consolidating failure handling, sequencing multiple futures into a single
future and reacting to the completion or failure of all the sub-futures at once.

As mentioned above, the high-level graphics APIs use [TileSource] to simplify the handling of
asynchronously loaded images. You can load an [Image] asynchronously and stuff it into an
[ImageLayer] and it will simply display nothing until the image is done loading. Similarly, you can
extract an [Image.Region] from a still-loading image, pass that to an [ImageLayer] and everything
will just work.

That said, sometimes you just have to generate a `Texture` from an `Image` and that can't happen
until the image is loaded. You can use [Image].`textureAsync` to obtain an [RFuture] which
completes with the image's texture or you can wait directly on [Image].`state`.

Sounds are also loaded asynchronously, but the developer is almost entirely shielded from that
because all of the sound APIs simply attempt to "do the right thing" if the sound is not yet
loaded. If you load a [Sound] and call `play`, but the sound is not yet loaded, the sound will
start playing once it is loaded.

Naturally this is only appropriate for music, not sound effects, which are almost always
coordinated with some visual counterpart. You can either check [Sound].`isLoaded` and skip the
sound effect this time, or use the same [RFuture] tools to wait for sound loading to complete.
Listen individually to [Sound].`state` or aggregate sounds into a `List` and use
[RFuture].`sequence` to wait for them all to load.

Text and binary loading are fairly straightforward, with the caveat that binary loading is not
supported on the HTML5 backend. Perhaps someday browsers support for the APIs needed to implement
this will be widely available and PlayN will leverage them.

## Input

PlayN provides APIs for [Mouse], [Touch] and [Keyboard] input. Input is delivered in the form of
events which are emitted from the [Input].`mouseEvents`, `touchEvents` and `keyboardEvents`
signals. The mobile backends (iOS and Android) support Touch, the desktop Java backend supports
[Mouse] and the HTML backend supports [Mouse] or [Touch] (or both) depending on where the browser
is running.

[Keyboard] is supported on Android, desktop Java and HTML, also depending on where the browser is
running. [Input] also provides an API for requesting a single line of text from the user, which
works on all platforms (using the virtual keyboard on mobile platforms).

A helper class is also provided which abstracts over mouse and touch events, providing a single API
which works for both modalities, called [Pointer].

## Network

PlayN supports two forms of network communication: HTTP requests and WebSocket connections.

HTTP connections provide all of the functionality you would expect via [Net.Builder] and
[Net.Response]: setting and reading HTTP headers, `https` support, `GET` and `POST`, etc. HTTP
requests are always executed asynchronously with their results delivered via an [RFuture].

Note that streaming of HTTP response data is not supported. The entire response is read into a
buffer and delivered all at once to the game. Platform limitations (HTML5, as usual) constrain us
there, though support for downloading data to local storage is probably a good idea and worth
implementing even if it's not supported by the HTML backend. TODO!

[Net.WebSocket] connections allow for the exchange of text or binary messages with a server over a
persistent socket connection. Binary messages are not currently supported by the HMTL5 backend.

## Scene graph

A scene graph is a way of arranging graphical elements hierarchically, such that the geometry
transforms and other graphics state of the parent nodes in the graph are automatically applied to
the children of those nodes. This can be very convenient, though it comes at a cost in memory use
and rendering efficiency. Fortunately it is not an all or nothing proposition, and PlayN makes it
easy to mix and match a scene graph with other direct rendering techniques in the same game.

### Layers

The two fundamental components of the scene graph are [Layer] and [GroupLayer]. Every node of the
scene graph is a `Layer`, and nodes which have children are `GroupLayer`s. A layer maintains a
bunch of rendering state:

**Affine transform**: A layer's transform is used when drawing the layer, and is concatenated with
the transforms of all of its children. When any given layer is rendered, the affine transform used
will be the concatenation of all of the transforms from that layer up to the root of the scene
graph.

**Translation/scale/rotation**: Because the process of turning a translation, scale and rotation
into an affine transform is not reversible, layers maintain translation, scale and rotation
separately. This means you can read back the current translation, scale or rotation of a layer and
manipulate it without running into issues like rotation wrapping around at `PI` or other
mathematical oddities.

**Origin**: One often wants the origin of a layer's coordinates to be somewhere other than the
upper left (so that you can rotate it, or because it's a character and it makes sense to think
about where the center of its feet are, etc.).

**Tint and alpha**: Tint (which is `AARRGGBB` and thus includes alpha) is applied to all quads
rendered by a layer, and is also combined with the tint of a layer's children. Thus one can set a
tint or alpha value on a `GroupLayer` and all of its children will be rendered with that tint and
alpha.

**QuadBatch**: The root of a scene graph defines the `QuadBatch` used by default to render all
layers, but any layer can configure a custom `QuadBatch` which will be used to render that layer
and its children.

**Visibility**: A layer can be made invisible and it and all of its children are skipped during
rendering (and hit testing, described below).

**Depth**: The immediate children of a `GroupLayer` are sorted by depth. Layers are rendered from
lowest to highest depth; they are hit tested from highest to lowest depth. Layers with higher depth
are drawn "on top of" (after) layers with lower depth, so this matches a viewer's expectations.

The actual rendering of a `Layer` (and its children) takes place on a `Surface`. One simply calls
`Layer.paint` on the root layer and supplies the surface to which they want to render the scene
graph.

This means that a layer can be inserted into the scene graph which does a bunch of immediate mode
drawing, using whatever approach is most efficient for the game in question, while still cooperating
with the rest of the scene graph (which may contain a UI or other things that are well suited to a
scene graph and for which performance isn't a big issue). Or a game could handle its own drawing
for the main game view and then paint a scene graph on top of that, for a HUD or UI.

### SceneGame

Games that wish to use a scene graph as their main display can use the [SceneGame] helper class. It
takes care of creating a default `QuadBatch` and a `Surface` which is configured to render to the
main frame buffer, and it takes care of `paint`ing the main scene graph every time the `paint`
signal is emitted. The game simply adds things to the `SceneGame.rootLayer` and they are drawn.

### Layer menagerie

Though a game can do everything it needs with `Layer` and `GroupLayer`, there are a number of
other specialized `Layer` classes which are provided to handle common tasks.

**[ImageLayer]**: this displays an `Image`, `Image.Region`, `Texture`, or `Tile`. As mentioned
previously, it takes care of generating a [Texture] even for asynchronously loaded images, and it
does [Texture] reference counting to ensure the texture is properly disposed when the layer is
destroyed.

**[CanvasLayer]**: if you're going to draw into a [Canvas] once and then display the resulting
image in the scene graph, use [ImageLayer]. If you plan to repeatedly change the contents of the
[Canvas] and wants those changes to show up, use `CanvasLayer`, because it handles all of the
necessary plumbing. `CanvasLayer` provides `begin` and `end` methods which take care of reuploading
the CPU memory bitmap data to the GPU into the appropriate texture so that the new contents of the
`Canvas` are displayed by the layer.

**[ClippedLayer]**: this takes care of managing a clipping region associated with a layer. Drawing
commands are clipped to the region's bounds (a `ClippedLayer` thus has a known width and height).
The `ClippedLayer` will take care of scaling and translating its clip rectangle based on its affine
transform, but that transform cannot be rotated due to the fact that the OpenGL clip rectangle has
to be axis-aligned.

`GroupLayer` can _optionally_ be clipped. Clipping is not free, so don't use it if you don't need
it, but when you're implementing a scrolling list or something like that, a clipped `GroupLayer` is
often just what you need.

**[RootLayer]**: this serves as the root of a scene graph. It's just a `GroupLayer` that knows that
it is always part of a scene graph. A layer emits a [Layer].`state` signal when it is added to, or
removed from, a scene graph root, so the root layer is needed to differentiate between an actual
scene graph and a disconnected fragment thereof.

### Layer input and hit testing

In addition to propagating render state down the scene graph, Layers also handle hit testing and
dispatching mouse and touch input to the appropriate layer. A default hit testing mechanism is
provided which takes care of transforming the to-be-tested point based on the affine transforms of
all the layers in the scene graph, and checking whether the resulting transformed point is in the
bounds of a particular layer.

This means that only layers which know their size can be "hit" by default. An unclipped
`GroupLayer` does not know its size. An `ImageLayer` and `CanvasLayer` know their size, as do a
`ClippedLayer` and clipped `GroupLayer`. A custom `Layer` which handles its own painting by
overriding `paintImpl` does not know its size (unless it overrides `width` and `height`). If a
sizeless layer wants to participate in hit testing, it can be configured with a custom hit tester.

**Interactions**: Dispatching input to layers takes the form of "interactions" (see [Interaction]).
An interaction is started when a mouse button is pressed, or when a touch gesture starts. That
event is used to determine which layer was hit by the input event and the hit layer becomes the
_interaction layer_. Mouse movement or touch movement events that come in after an interaction has
started are dispatched to the interaction layer, no additional hit testing is performed to see if
those events remain in the bounds of the interaction layer or potentially hit another layer. The
interaction ends when the mouse button is released or the touch gesture ends.

Touch events map naturally to interactions, and each separate touch gesture (finger) is tracked and
dispatched to its own separate interaction layer. This is not always what you want, but if you are
doing crazy multi-touch input handling, you should probably handle global [Touch] events and sort
things out yourself.

Mouse events do not always map to interactions, and some mouse events are thus dispatched in
"one-shot" interactions. When no buttons are pressed, mouse motion events are dispatched as
one-shot interactions to whatever layer is under the mouse as it moves. Mouse wheel events are
dispatched to the current interaction if there is one, otherwise they are dispatched as one-shot
interactions to whatever layer is under the mouse at the time. Mouse hover (enter/exit) events are
always dispatched as one-shot interactions.

**Interactivity**: To make event dispatch more efficient, each Layer tracks whether or not it is
"interactive". If a layer or any of its children have event listeners registered, then that layer
is interactive and participates in hit testing and event dispatch. If a layer (and all of its
children) have no event listeners, it does not participate in hit testing. This is usually what you
want, but if you are using hit testing or layer event dispatch for other purposes, you may need to
manually configure layer interactivity.

**Dispatchers**: None of this event dispatch happens by default. If you wish
to receive a particular kind of per-layer event, you must register the appropriate dispatcher with
the appropriate [Input] event signal. Per-layer event dispatch is not free, so you get total
control over whether and when this processing is performed.

**Bubbling**: When you register your dispatcher, you also choose whether you want that dispatcher
to support event _bubbling_. Bubbling means that an event is dispatched not only to the interaction
layer, but also to every parent of that layer all the way up to the root of the scene graph.

This is useful when you're implementing UI-behavior in a scene graph. A button might want to handle
mouse clicks or touches, but when it is in a scrolling list and the user starts a touch gesture on
the button but then flicks upward, the scrolling group that contains the button wants to take over
and scroll the list instead of performing the button interaction, so they both need to hear the
event stream. This leads us to _capture_.

**Capture:** When event bubbling is enabled, multiple layers hear about the events in a given
interaction. Any one of those layers can _capture_ the interaction and for the remainder of the
interaction only that layer will hear the events. All the other layers will receive a `CANCEL`
event and hear nothing further about that interaction.

This is useful in scenarios like the above. At the start of a touch gesture, both the button and
scrolling group see and process all events (the button arms itself on touch start and the scrolling
group just notes the position at which the touch started). The scrolling group can then capture the
interaction once it moves a certain distance from the point at which it started. The button will
see the `CANCEL` and will disarm itself and stop processing the interaction. The scrolling group
can then do whatever it needs to handle the scrolling gesture.

**Layer.events**: Every layer has an `events` signal which is used to dispatch every kind of
per-event layer. The event dispatch mechanisms make use of this events signal, but you can also use
the signal for your own nefarious purposes.

## Platforms

PlayN currently supports four target platforms:

### Desktop Java

The desktop Java backend uses a standard [Java VM] and uses [LWJGL] to access OpenGL on the
supported desktop OSes: Windows, Mac OS X, and Linux. This is the backend that one uses for day to
day development of their game, which allows one to leverage all of the sophisticated tools
available in the Java ecosystem.

For example, using [JRebel] or the [Eclipse IDE]'s edit and continue support allows one to make
code changes and have that new code hot reloaded into their running game. Needless to say, this can
dramatically increase one's efficiency when tuning game behavior or doing experimental coding.

It is also possible to deploy games for this platform. The standard PlayN Maven build supports the
creation of a single stand-alone jar file which contains the entire game and assets and which can be
paired with a per-platform Java launcher for consumer delivery, or easily sent to teammates to test
out new builds by running `java -jar yourgame.jar`.

### Android

The Android backend simply uses the standard Android platform APIs, which are already designed to
be used from Java. The only thing to note is that PlayN requires API level 15 or higher (Android
4.0.3 or higher). Google's reports in January of 2015 indicate that over 92% of Android devices are
running 4.0.3 or later.

### iOS

The iOS backend uses [RoboVM] to compile Java bytecode to ARM executables for deployment on iOS.
RoboVM provides excellent emulation of many of the JRE APIs, which allows one to use many
third-party Java libraries if they restrict their deployments to Java, Android and iOS.

RoboVM also provides Java-friendly translations of nearly all of the native iOS APIs, which allows
games to implement iOS-specific functionality (like Game Center integration, camera access, etc.)
directly in Java using most of the same tools they use to develop their game.

Note that building and deploying a game to iOS can only be done on a Mac due to the inavailability
of the developer tools on other platforms.

### HTML5

The HTML5 backend uses [GWT] to translate Java code into JavaScript, and uses the [WebGL],
[Canvas2D] and other browser APIs to implement the PlayN services.

Due to limitations of the JavaScript virtual machine and browser APIs, the HTML5 backend is the
most limited of all the backends. It does not support most of the standard JRE APIs. It does not
support synchronous asset loading, nor binary data loading or processing. Care must be taken to
ensure good performance, especially if one plans to run their game on mobile browsers.

That said, it is by far the most accessible way to deploy your game. If you can simply send someone
a URL and your game appears in their web browser &mdash; no OS security warnings, no app stores, no
fuss &mdash; you have taken a big step toward solving one of the hardest problems in game
development: getting people to actually try your game.

## More information

For more detailed information on the PlayN platform, you should refer to the [source
code](https://github.com/playn/playn). It is well organized and readable (if I do say so myself),
and one can often directly and easily find answers to implementation detail questions.

You can also ask questions on the [mailing list](http://groups.google.com/group/playn) where you
will find the PlayN maintainers and many active users of the library. For "how do I do X"
questions, please check the [cookbook](/cookbook/) and also [Stack
Overflow](http://stackoverflow.com/questions/tagged/playn).

[Assets]: http://playn.github.io/docs/api/core/playn/core/Assets.html
[Canvas2D]: http://www.w3.org/TR/2dcontext/
[CanvasLayer]: http://playn.github.io/docs/api/scene/playn/scene/CanvasLayer.html
[Canvas]: http://playn.github.io/docs/api/core/playn/core/Canvas.html
[ClippedLayer]: http://playn.github.io/docs/api/scene/playn/scene/ClippedLayer.html
[Clock]: http://playn.github.io/docs/api/core/playn/core/Clock.html
[Disposable]: http://playn.github.io/docs/api/core/playn/core/Disposable.html
[Eclipse IDE]: https://eclipse.org/
[GL20.Buffers]: http://playn.github.io/docs/api/core/playn/core/GL20.Buffers.html
[GL20]: http://playn.github.io/docs/api/core/playn/core/GL20.html
[GLBatch]: http://playn.github.io/docs/api/core/playn/core/GLBatch.html
[GLBatch]: http://playn.github.io/docs/api/core/playn/core/GLBatch.html
[GLProgram]: http://playn.github.io/docs/api/core/playn/core/GLProgram.html
[GWT]: http://www.gwtproject.org/
[Game]: http://playn.github.io/docs/api/core/playn/core/Game.html
[Graphics]: http://playn.github.io/docs/api/core/playn/core/Graphics.html
[GroupLayer]: http://playn.github.io/docs/api/scene/playn/scene/GroupLayer.html
[Image.Region]: http://playn.github.io/docs/api/core/playn/core/Image.Region.html
[ImageLayer]: http://playn.github.io/docs/api/scene/playn/scene/ImageLayer.html
[Image]: http://playn.github.io/docs/api/core/playn/core/Image.html
[Image]: http://playn.github.io/docs/api/core/playn/core/Image.html
[Input]: http://playn.github.io/docs/api/core/playn/core/Input.html
[Interaction]: http://playn.github.io/docs/api/scene/playn/scene/Interaction.html
[JRebel]: http://zeroturnaround.com/software/jrebel/
[Java VM]: http://www.oracle.com/technetwork/java/javase/downloads/index.html
[Keyboard]: http://playn.github.io/docs/api/core/playn/core/Keyboard.html
[LWJGL]: http://www.lwjgl.org/
[Layer]: http://playn.github.io/docs/api/scene/playn/scene/Layer.html
[Mouse]: http://playn.github.io/docs/api/core/playn/core/Mouse.html
[Net.Builder]: http://playn.github.io/docs/api/core/playn/core/Net.Builder.html
[Net.Response]: http://playn.github.io/docs/api/core/playn/core/Net.Response.html
[Net.WebSocket]: http://playn.github.io/docs/api/core/playn/core/Net.WebSocket.html
[OpenGL ES 2.0]: https://www.khronos.org/opengles/2_X/
[Platform]: http://playn.github.io/docs/api/core/playn/core/Platform.html
[Pointer]: http://playn.github.io/docs/api/core/playn/core/Pointer.html
[QuadBatch]: http://playn.github.io/docs/api/core/playn/core/QuadBatch.html
[RFuture]: http://threerings.github.io/react/apidocs/react/RFuture.html
[React]: https://github.com/threerings/react
[RenderTarget]: http://playn.github.io/docs/api/core/playn/core/RenderTarget.html
[RoboVM]: http://www.robovm.com/
[RootLayer]: http://playn.github.io/docs/api/scene/playn/scene/RootLayer.html
[SceneGame]: http://playn.github.io/docs/api/scene/playn/scene/SceneGame.html
[Sound]: http://playn.github.io/docs/api/core/playn/core/Sound.html
[Surface]: http://playn.github.io/docs/api/core/playn/core/Surface.html
[TextBlock]: http://playn.github.io/docs/api/core/playn/core/TextBlock.html
[TextFormat]: http://playn.github.io/docs/api/core/playn/core/TextFormat.html
[TextLayout]: http://playn.github.io/docs/api/core/playn/core/TextLayout.html
[TextWrap]: http://playn.github.io/docs/api/core/playn/core/TextWrap.html
[TextureSurface]: http://playn.github.io/docs/api/core/playn/core/TextureSurface.html
[Texture]: http://playn.github.io/docs/api/core/playn/core/Texture.html
[TileSource]: http://playn.github.io/docs/api/core/playn/core/TileSource.html
[Tile]: http://playn.github.io/docs/api/core/playn/core/Tile.html
[Touch]: http://playn.github.io/docs/api/core/playn/core/Touch.html
[TriangleBatch]: http://playn.github.io/docs/api/core/playn/core/TriangleBatch.html
[UniformQuadBatch]: http://playn.github.io/docs/api/core/playn/core/UniformQuadBatch.html
[WebGL]: https://www.khronos.org/webgl/
[immediate mode]: http://en.wikipedia.org/wiki/Immediate_mode_%28computer_graphics%29
[playn-scene]: http://playn.github.io/docs/api/scene/
