---
layout: docs
---

# 1.x Release notes

* See release notes on PlayN 2.x [here](notes.html).

## PlayN v1.8.5
* This is mostly a bugfix release, so no API diffs are provided.
* (Flash) Flash backend was removed.
* (Core) Payments API was removed.
* (Core) `Analytics` and `RegExp` services were removed.
* (Core) Removed the multiline text functionality that was deprecated in 1.8.
* (Core) The color shader backend was eliminated. All rendering is now done with the texture
  shader, and colored rectangles are rendered via a tinted 1x1 image.
* (Core) Permit zero in [ImageLayer].`setSize/setWidth/setHeight`.
* (Core) Permit calling [ImageLayer].`width/height` on an image layer with no image, but for which the width/height was manually set.
* (iOS) Fixed issue where garbage pixels sometimes appeared in canvas images (mostly on non-Retina displays).
* (HTML) Improvements to (hacky) font measurement code.
* (HTML) Added `HtmlPlatform.Config.rootId` for using a root element id other than `playn-root`.

## PlayN v1.8
* Notes on migrating a project from [1.7 to 1.8](Migrating17to18.html).

### Core
* Added [Font].`derive(float size)`.
* Added `GroupLayer.destroyAll`, renamed `clear` to `removeAll`.
* Improved JSON parsing performance somewhat.
* Added [Assets].`getBytes` and [Assets].`getBytesSync`. Not implemented on HTML/Flash backends (due to
  platform limitations in HTML's case).
* Added `TextFormat.antialias` to allow disabling of antialiasing when rendering text. Doesn't work
  on HTML backend because it's impossible to disable antialiasing in HTML5.
* Added `TextLayout.text` which tells you what text will be rendered by a `TextLayout`.
* Added [Graphics].`layoutText(String,TextFormat,TextWrap)` which returns one `TextLayout` instance
  for each line. The old mechanism where a single `TextLayout` could represent many lines of text
  is deprecated.
* Added `TextBlock` for rendering centered/left/right-aligned multiline text.

### Java
* Improved performance when uploading texture data to GPU.
* Added [JavaPlatform.Config].`convertImagesOnLoad` which causes images to be converted to GPU friendly code on a
  background thread at load time instead of on the main render thread the first time the image is
  used.
* Switched `Storage` implementation to use Java preferences (instead of a properties file written
  to temporary storage). This means that Java Storage data persists across machine reboots, a
  useful characteristic if you're shipping a game using the Java backend.
* Added [JavaPlatform.Config].`emulateTouch` for emulating multitouch on the Java backend. Press F11 when enabled
  and the touch pivot point is set, and a mouse click then results in a two-finger touch, mirrored
  across the pivot point. This is similar to how it works in the iOS simulator.
* Added `swt-java` backend, which hosts LWJGL in a SWT Canvas. This is useful if you want to
  overlay platform native UI elements atop your PlayN game. Due to limitations of LWJGL, overlaying
  AWT components atop a PlayN game doesn't work on Mac OS.
* Added [JavaPlatform.Config].`appName` which configures the name of the native app running your PlayN game.

### Android
* Added `GameActivity.makeWindowFlags` to allow customizing window flags (e.g. reinstate status
  bar).
* Performance improvements in sending vertex data to GPU/shaders.
* Fixed bug with `Canvas` and HiDPI mode.
* Added support for registering custom fonts using a `Typeface` instance; this is needed if you
  want to register one of the Android default fonts for use in your game.
* Made [Sound].`preload` work properly for SFX.

### iOS
* Made [Canvas].`fillText` work when a fill gradient is configured.
* Added `IOSPlatform.OrientationChangeListener` for hearing about orientation changes. This will
  probably some day be deprecated in favor of a cross-platform API for hearing about orientation
  changes, but a lot of work is needed to support a game that works in both portrait and landscape
  orientations.
* Sounds obtained via [Assets].`getSound` are now played via OpenAL, which is substantially higher
  performance than the old AVAudioPlayer mechanism. AVAudioPlayer is still used for
  [Assets].`getMusic` because that's what it's for. See the migration guide for new requirements for
  CAFF and AIFC files.

----
## PlayN v1.7.2
* This is a minor patch release, so no API diffs are provided.
* (Java) LWJGL native libraries are automatically unpacked and used. It is no longer necessary to
  manually setup `java.library.path`.
* (Java) Substantially improved speed of uploading `CanvasImage` image data to GPU.
* (Java) `mvn package` now creates standalone jar file which runs your game.
* (Android) Upgraded to `android-maven-plugin` 3.6.0 which accommodates tool rearrangements in
  latest Android SDK.
* (Android) Fixed issue with `Canvas` stroke width, cap, etc. not being saved and restored.
* (Archetype) Brought the Ant build scripts up to date with various recent changes.

## PlayN v1.7.1
* This is a minor patch release, so no API diffs are provided.
* (Core) Added [Pointer].`Event.capture` which allows one to capture a pointer interaction, canceling
  any other ongoing interactions.
* (Core) Reduced fragment shader precision. Should improve performance with little to no reduction
  in graphics quality.
* (Core) [Layer].`setScale(0)` no longer throws an exception. This avoids the need to specially check
  for edge cases when animating the scale of a layer.
* (Java) We now use LWJGL 2.9.0 which works with Java 7 on the Mac. Yay!
* (iOS) Fixed long standing bug with `SurfaceImage` (originally in `SurfaceLayer`). No longer will
  the last rendered surface sometimes not show up.

## PlayN v1.7
* Notes on migrating a project [from 1.6 to 1.7](Migrating16to17.html).

### Core
* Added `SurfaceImage`, deprecated `SurfaceLayer`. `SurfaceImage` allows surfaces to be drawn and
  then shared among multiple [ImageLayer] instances, just like a normal image. In addition to
  simplifying the API, this allows a `SurfaceImage` to be used as a repeating background, and/or
  stretched like any other [Image] in an [ImageLayer].
* Added [Surface].`drawLayer`. This allows you to capture a "snapshot" of a scene graph into a
  `Surface`. On GL-based backends, this executes all custom shaders and is essentially identical to
  the normal rendering pipeline except that the results are written to a separate texture instead
  of the framebuffer. This opens the door to all sorts of fun stuff.
* Restructured `Game` interface. Now [Game].`Default` implements the previously mandated
  `update`/`paint` model (and improves rendering smoothness for that model), and the bare `Game`
  interface allows a `Game` to implement whatever approach to separating physics from rendering
  that a game desires. See the [Migrating16to17](Migrating16to17.html) for the code changes needed
  to use [Game].`Default`
* Added `Clock` to simplify life for libraries and games that need to handle interpolation of
  update/paint times.
* Added `PlayN.tick` which returns a high-precision timestamp that's useful for animation.
* Added [Net].`Builder` which allows one to build HTTP requests with custom headers, supply binary
  POST payloads (except on HTML backend), read response headers and read binary response data
  (except on HTML backend).
* Added [Image].`setRepeat` and removed [ImageLayer].`setRepeat`. Due to the way images are handled in
  GL, this admits fewer "unworkable" configurations. It was previously possible to attempt to use
  the same image in multiple layers with different repeat configurations, and tha would not have
  actually worked. Now it's clear that an Image can have only one repeat configuration. This also
  enables `Pattern` to honor an images repeat configuration (partially implemented).
* Added [Image].`setMipmapped` for using mipmaps to improve quality of downscaled images on GL-based
  backends.
* [Image].`glTex(Sub)Image2D` moved to [GLContext].`tex(Sub)Image2D`.
* `IndexedTrisShader` is now easier to extend/customize.
* Many previously deprecated APIs were removed. If you haven't switched from `ResourceCallback` to
  `Callback`, you're going to have to do it now.
* Deprecated [Surface].`setTransform` ( [Canvas].`setTransform` was deprecated in the 1.6 release and
  [Surface].`setTransform` should also have been deprecated, but was missed).

### Box2D
* Eliminated PlayN's fork of JBox2D as our changes are now merged upstream. A dependency on
  `playn-jbox2d` now pulls in `org.jbox2d:jbox2d-library:2.2.1.1` which is GWT-compatible. See
  [Migrating16to17](Migrating16to17.html) for the changes you'll need to make to your project
  configuration.

### HTML
* Made text messages work in [Net].`WebSocket` implementation. Previously only binary messages
  worked. Has anyone actually used web sockets?
* Upgraded gwt-voices to 3.2.0.
* Retired the HTML/DOM backend.

### Android
* Added [Net].`WebSocket` implementation for Android.
* Archetype now includes configuration for signing and zipaligning your APK, which are needed if
  you want to release your game to Google Play Store.

### iOS
* Added `IOSPlatform.Config.interpolateCanvasDrawing` which can be set to false to disable
  interpolation on Retina devices (which is useful for pixel-art style games).
* Fixed [Image].`getRGB` on Retina devices. It now no longer interpolates pixels.
* Fixed [Canvas].`drawPoint` on Retina devices. It now draws a proper square pixel.
* Archetype now includes `monotouch-maven-plugin` which allows one to build and deploy iOS apps
  without having to use MonoDevelop (command line building unfortunately requires the Xamarin.iOS
  "business license").
* Archetype now provides a much more sensible MonoTouch configuration out of the box: it builds an
  IPA, strips unused code from the binary, builds only for ARMv7.

----
## PlayN v1.6
* The way projects are organized has changed, please see [Migrating15to16](Migrating15to16.html)
  for details.

### Core
* Implemented tinting for layers (only on GL backends). See [Layer].`setTint` and [Layer].`tint`.
* Added [Log].`setMinLevel` to allow suppressing log messages below a certain level. (Recommended by
  Google for Android release builds.)
* Added [Sound].`release` for releasing audio resources sooner than waiting for GC to do it.
* Added [Assets].`getMusic` which allows backends to make some optimizations relating to large audio
  files.
* [Graphics].`setSize` was removed, and special `setSize` methods were added to individual platform
  backend code that can reasonably support them (e.g. `HtmlGraphics.setSize`).
* Added [GLContext].`Stats` for debugging rendering performance on GL backends. (See Triple Play's
  HUD class for an easy way to display these stats.)
* Deprecated [Canvas].`setTransform` because it interacts poorly with automatic scale factor
  management in HiDPI modes.
* Added `CanvasImage.snapshot` which can be used to create an immutable snapshot of a canvas image
  which has higher render performance.
* Added `TextLayout.ascent/descent/leading` for cases where an app needs to know more about the
  text that will be rendered by a `TextLayout` (for underlining, for example).
* Added [Json].`Writer.useVerboseFormat` to cause the JSON writer to generate pretty printed output
  (rather than compact, everything on one line output).
* Added support for nested clipping regions (e.g. clipped groups inside of clipped groups).

### Java
* Made the Java backend look for .wav audio files and then fall back to .mp3. This allows a game to
  use uncompressed .wav audio files, and only compress them when preparing an Android, iOS, or HTML
  build.
* Made playback of large MP3s work (when loaded as music).

### HTML
* Added `HtmlAssets.ImageManifest` which can be used to pre-load the dimensions of all images known
  to your app, and enable [Assets].`getImageSync` to (sort of) work in the HTML backend. A wiki
  article explaining this will be forthcoming.
* Added support for HiDPI mode. See `HtmlPlatform.Config.scaleFactor` and
  `HtmlAssets.setAssetScale`.
* Added `HtmlGraphics.registerFontMetrics` for overriding the (hacky) measurement of font line
  height.
* Removed source code from the stock POMs. HTML backends now need to add the source jar files to
  their `html/pom.xml`. See playn-samples for an example.

### Android
* Fixed issue with audio not stopping when device was put to sleep.
* Images loaded locally are now marked as "purgeable" and "input shareable". Google for "android"
  and those terms to learn more.
* Added `AndroidGraphics.setCanvasScaleFunc` which allows games to use lower resolution canvas
  images if desired. This is useful on devices with low memory.
* Added `AndroidAssets.BitmapOptions` which allows games to downsample images if desired. This is
  useful on devices with low memory.
* Added `GameActivity.prefsName` for customizing the name of the Android preferences file.
* Added `GameActivity.logIdent` for customizing the Android log identifier. It defaults to `playn` which is what was hard-coded before.
* Rewrote sound backend based on `SoundPool`. Music (large audio files) still relies on the old
  more-hardware-resource-intensive approach.

### iOS
* Added `IOSPlatform.Config` for specifying configuration options.
* Added `IOSPlatform.Config.frameInterval` for specifying target FPS on iOS.
* Added `IOSImage.toUIImage` for custom platform code that needs to manipulate an image loaded via
  `IOSAssets.getImage`.
* Numerous bug fixes and performance improvements.

----
## PlayN v1.5.1
* Fixes issues with GWT compilation.
* Reduces likelihood of problems with exported `gwt-user` Maven dependency.
* Updates a number of transitive dependencies (LWJGL, Guava, JUnit, Android).

## PlayN v1.5
### Core
* [Layer] transform management has changed somewhat: layers now maintain their scale and rotation
  internally and only apply them to their transform prior to being rendered. Layers also provide
  getters for those values now. Because the values are no longer extracted from the affine
  transform (a lossy process) many annoyances are alleviated, but one must take care to either use
  the Layer accessors exclusively or to manipulate the transform directly exclusively. Don't do
  both or you will encounter weirdness.
* [Graphics].`setSize` is deprecated (and does nothing). The size of your game view on Android/iOS is
  dictated by the device and any native controls you add to the native layout. The size on Java is
  configured via `JavaPlatform.Config`. The size in HTML is configured by the size of your
  `playn-root` div. The size in Flash is configured by the size of the `object` element that
  displays your Flash movie.
* [Graphics].`layoutText` now allows the empty string. It yields a `TextLayout` with width 0 and a
  height appropriate for the configured font.
* Image loading is now asynchronous on all platforms (previously iOS/Java/Android loaded images
  syncrhonously). [Assets].`getImageSync` can be used for synchronous image loading on platforms that
  support it (iOS/Java/Android).
* Text loading is now asynchronous on all platforms (previously iOS/Java/Android loaded text
  synchronously). [Assets].`getTextSync` can be used for synchronous text loading on platforms that
  support it.
* All audio loading is now done on a background thread, but `assets().getSound("foo").play()` will
  still do "the right thing" because requests to play/stop a pending sound are noted and applied
  once the sound is loaded.
* [Assets].`getRemoteImage` allows loading images from URLs.
* `Assets` no longer caches assets on any platform. Use `CachingAssets` wrapper.
* `Assets` methods for watching loaded assets are deprecated. Use `WatchedAssets` wrapper.
* `AssetWatcher.Listener` is now an abstract class and has a `progress` method.
* `ResourceCallback` is deprecated, `Callback` is now used in its place.
* `Net` callbacks now report `HttpException` on failure, which includes the HTTP status code.
* `Touch`/`Pointer` now also reports cancelled events (which happen on Android/iOS).
* [Platform].`setPropagateEvents` can be used to cause events to be propagated down (and back up) the
  layer hierarchy instead of just being dispatched directly to the hit layer.
* [Log].`Collector` allows one to intercept all PlayN log messages (for sending over the network with bug reports, say).
* `Storage` provides an interface for batch setting/deleting properties, which dramatically
  increases performance on Android when updating hundreds or thousands of properties at once.
* `Json` now provides `getLong`.

### Java
* `JavaPlatform` is now initialized via `JavaPlatform.Config` which introduces a number of new configuration options.

### Android
* Various framebuffer bugs relating to backgrounding the app have been fixed. If you are still able
  to make your app do strange things by backgrounding and restoring it, please report a bug.
* The Android back button is now configured to move your game task to the back of the stack rather
  than ending it (which breaks things).
* `GameActivity` provides calldown methods for computing the default `Bitmap.Config` to use when
  loading images.
* `AndroidAssets` provides a `BitmapOptionsAdjuster` for controlling the `Bitmap.Config` (and other
  options) on an image-by-image basis when your images are loaded.

### iOS
* PlayN uses MonoTouch 6.0.6 and OpenTK-1.0. You will need to update your POM and .csproj files.
* Update your `ios/pom.xml` to use ikvm-maven-plugin 1.1.4.
* `IOSPlatform.uiOverlay` provides a `UIView` on which native controls can be overlayed atop the
  game view.
* `IOSPlatform.rootViewController` provides access to the root view controller. This is needed to
  push new views over the game view, like the Game Center view.

----
## PlayN v1.4
### Core
* Can now receive notifications when game is paused/resumed and will exit:
  [PlayN.LifecycleListener].
* Added per-layer touch event handling: [Layer]`.addListener(Touch.LayerListener)`.
* Per-layer mouse event handling now uses [Mouse.LayerListener] which supports `onMouseOver`,
  `onMouseOut` and `onMouseWeheelScroll`.
* Added clipped group layers:
  [Graphics.createGroupLayer(width,height)](http://docs.playn.googlecode.com/git/javadoc/playn/core/Graphics.html).
* Added [Net.WebSocket](http://docs.playn.googlecode.com/git/javadoc/playn/core/Net.WebSocket.html)
  which currently works on HTML and Java backends.
* Added custom GLSL shader support for GL-based backends. See [GLShader] and [ShaderTest.java].
* Added [GLContext].`setTextureFilter` for configuring image scaling filter on GL-based backends.
* Added [Sound.volume](http://docs.playn.googlecode.com/git/javadoc/playn/core/Sound.html) for
  obtaining the current volume of a sound.
* Added [Mouse].`isEnabled/setEnabled`, same for [Touch] and [Pointer].
* Exposed [Image].`ensureTexture` as a public API.
* [JsonObject.getArray](http://docs.playn.googlecode.com/git/javadoc/playn/core/Json.JsonObject.html)
  now returns null for non-existent keys, not an empty array.
* Removed a great deal of previously deprecated methods ([Canvas].`drawText`, [Graphics].`createPath`,
  [Graphics].`createPattern`, `CanvasLayer`, `TextLayout` effects, etc.).
* Various fixes to `GL20` implementations.
* Fixed issues with clipped layers with non-zero origin.
* Improved error reporting to
  [Sound](http://docs.playn.googlecode.com/git/javadoc/playn/core/Sound.html) resource listeners on
  all backends.

### Java
* Added `JavaPlatform.registerHeadless` for use when using the JavaPlatform in unit tests. This
  allows one to run unit tests without configuring the LWJGL native libraries.
* Added `JavaAssets.setAssetScale` for testing downscaled assets.
* Fixed issue with playing, stopping then playing looping sounds again.

### HTML
* `HtmlPlatform` is now configured using [HtmlPlatform.Configuration], which includes configuration
  for alpha transparency of the game canvas and anti-aliasing.
* `Pointer` now correctly supports devices with both touch and mouse input.
* [Keyboard.getText](http://docs.playn.googlecode.com/git/javadoc/playn/core/Keyboard.html) is now
  implemented.

### iOS
* [Touch.Event.id](http://docs.playn.googlecode.com/git/javadoc/playn/core/Touch.html) now
  correctly reports unique ids for touch events.
* Made [Pointer](http://docs.playn.googlecode.com/git/javadoc/playn/core/Pointer.html) properly use
  only the first touch and ignore subsequent touches.
* Added support for CAFF (.caf) audio files in addition to MP3.
* Errors are properly reported if an invalid URL is passed to [Net].`post/get`.
* Fixed single frame of blankness between loading image disappearing and first game frame being rendered.
* Fixed default landscape orientation (which is landscape right).
* Fixed inter-line spacing in wrapped text rendering.
* Fixed issue with supplying null label to
  [Keyboard.getText](http://docs.playn.googlecode.com/git/javadoc/playn/core/Keyboard.html).
* Fixed issue with providing initial value in
  [Keyboard.getText](http://docs.playn.googlecode.com/git/javadoc/playn/core/Keyboard.html).

----
## PlayN v1.3.1

* (Core) Added [Image].`clearTexture` for when one needs to free graphics memory without waiting
  around for GC to trigger it.
* (Archetype) Reworked the way the per-backend modules are managed. See the updated
  [GettingStarted] guide for how to build and test new projects.
* (Archetype) Various improvements to iOS archetype which make things work well enough that it can
  be documented and turned loose on the world.
* (HTML/Flash) Fixed bug with [Canvas].`draw/fillRoundRect`.
* (Android) Made [Net].`get/post` asynchronous to match other backends.
* (Android) Fixed [Keyboard].`getText` threading issue.
* (Android) Fixed interline spacing issue on wrapped text.

## PlayN v1.3
### Core
* Changed [Image.width/height](http://docs.playn.googlecode.com/git/javadoc/playn/core/Image.html)
  and [http://docs.playn.googlecode.com/git/javadoc/playn/core/Canvas.html Canvas.width/height]
  from `int` to `float`.
*
  [Graphics.createImage/createSurface](http://docs.playn.googlecode.com/git/javadoc/playn/core/Graphics.html)
  now accepts `float` width and height and rounds up to an `int` width/height for you.
* Added [PlayN.invokeLater](http://docs.playn.googlecode.com/git/javadoc/playn/core/PlayN.html).
* Added [Path.bezierTo](http://docs.playn.googlecode.com/git/javadoc/playn/core/Path.html), removed [Path].`arcTo`.
* Added [Canvas.stroke/fillRoundRect](http://docs.playn.googlecode.com/git/javadoc/playn/core/Canvas.html).
* Added [Image.getRgb](http://docs.playn.googlecode.com/git/javadoc/playn/core/Image.html).
* Added [Image.Region.setBounds](http://docs.playn.googlecode.com/git/javadoc/playn/core/Image.Region.html).
* Added [Image.transform](http://docs.playn.googlecode.com/git/javadoc/playn/core/Image.html).
* Added [Mouse.MotionEvent.dx/dy](http://docs.playn.googlecode.com/git/javadoc/playn/core/Mouse.MotionEvent.html).
* Added
  [Mouse.lock/unlock/isLocked/isLockSupported](http://docs.playn.googlecode.com/git/javadoc/playn/core/Mouse.html).
  Only works on Java backend currently.
* Allow supplying null to
  [Image.setImage](http://docs.playn.googlecode.com/git/javadoc/playn/core/Image.html) to clear out
  image.
* Added [Mouse.hasMouse](http://docs.playn.googlecode.com/git/javadoc/playn/core/Mouse.html) and
  [http://docs.playn.googlecode.com/git/javadoc/playn/core/Touch.html Touch.hasTouch].
* Added
  [Json.TypedArray.Util](http://docs.playn.googlecode.com/git/javadoc/playn/core/Json.TypedArray.Util.html).
* Added
  [ImmediateLayer.renderer](http://docs.playn.googlecode.com/git/javadoc/playn/core/ImmediateLayer.html).
* Deprecated
  [Canvas.drawText](http://docs.playn.googlecode.com/git/javadoc/playn/core/Canvas.html), replaced
  by [Canvas].`strokeText` and [Canvas].`fillText`.
* Deprecated
  [TextFormat.Effect](http://docs.playn.googlecode.com/git/javadoc/playn/core/TextFormat.Effect.html).
  Effects can now be achieved using `stroke/fillText`.
* Updated [Pythagoras](https://github.com/samskivert/pythagoras) dependency to 1.2.
* Fixed problem where `GroupLayer` would be marked as non-interactive if it had listeners but no
  interactive children.
* Fixed issue where
  [Sound.addCallback](http://docs.playn.googlecode.com/git/javadoc/playn/core/Sound.html) would not
  properly notify callbacks after the sound was loaded.

### Java
* Replaced Java graphics backend with version based on LWJGL. This provides greater consistency
  with the Android, iOS, and HTML5/WebGL backends. *Note:* you will need to update your
  `java/pom.xml` file based on the latest archetype.
* Added HiDPI support to Java backend (allows you to test HiDPI mode for your Android or iOS game
  locally). See `JavaPlatform.register`.
* Added [GL20](http://docs.playn.googlecode.com/git/javadoc/playn/core/gl/GL20.html) implementation
  for Java.
* Made [Net.post/get](http://docs.playn.googlecode.com/git/javadoc/playn/core/Net.html)
  asynchronous to match behavior of other backends.

### Android
* Added HiDPI graphics support (though it is not yet automatically detected and enabled).
* Implemented custom font support. See `AndroidGraphics.registerFont`.
* Implemented
  [Keyboard.getText](http://docs.playn.googlecode.com/git/javadoc/playn/core/Keyboard.html).
* Android no longer crashes if it can't load the native library needed to support older devices. It
  may still crash if said older device lacks the GL methods needed by PlayN, but some devices fail
  to load the library, yet support the needed GL calls.

### iOS
* Added HiDPI (Retina) support.
* Added support for treating (non-Retina) iPad like Retina iPhone, allowing graphics reuse.
* Various improvements to the ios submodule in the PlayN archetype.
* Fixed crashes relating to use of [System].`err/out` on iOS 5.

### HTML
* Added new (most likely faster) quad shader for HTML WebGL backend. Try it with "&glshader=quad".
* Fixed issue where mouse dragging sometimes triggered browser drag-and-drop mechanism.
* Removed transparency from Canvas element used on WebGL.

### Flash
* Fixed content type used when making HTTP POST requests.
* Enabled use of `crossdomain.xml` files when loading images.
* Improved font rendering via use of `AntiAliasType.ADVANCED`.

----
## PlayN v1.2
### Core
* Added mouse and pointer dispatch to layers. See
  [Layer.addListener(Mouse.Listener)](http://docs.playn.googlecode.com/git/javadoc/playn/core/Layer.html),
  [Layer.addListener(Pointer.Listener)],
  [Layer.setHitTester](http://docs.playn.googlecode.com/git/javadoc/playn/core/Layer.html).
* Added [Image.subImage](http://docs.playn.googlecode.com/git/javadoc/playn/core/Image.html),
  deprecated [ImageLayer].`setSourceRect` and [ImageLayer].`clearSourceRect`.
* Added [Image.toPattern](http://docs.playn.googlecode.com/git/javadoc/playn/core/Image.html),
  deprecated [Graphics].`createPattern`.
* Added [Canvas.createPath](http://docs.playn.googlecode.com/git/javadoc/playn/core/Canvas.html),
  deprecated [Graphics].`createPath`.
* Added
  [GroupLayer.addAt](http://docs.playn.googlecode.com/git/javadoc/playn/core/GroupLayer.html).
* Added
  [Layer.Util.parentToLayer(Layer,Layer,IPoint,Point)](http://docs.playn.googlecode.com/git/javadoc/playn/core/Layer.Util.html).
* Added [Surface.setAlpha](http://docs.playn.googlecode.com/git/javadoc/playn/core/Surface.html).
* Added [Surface.fillTriangles](http://docs.playn.googlecode.com/git/javadoc/playn/core/Surface.html) in two variants.
* Fixed [Surface.fillRect](http://docs.playn.googlecode.com/git/javadoc/playn/core/Surface.html)
  when used with a fill pattern.
* Made methods that accept `ResourceCallback` properly contravariant in their type parameter. For
  example
  [Image.addCallback(ResourceCallback)](http://docs.playn.googlecode.com/git/javadoc/playn/core/Image.html).
* Removed `value(int)`, `value(double)`, and `value(float)` methods from
  [JsonSink](http://docs.playn.googlecode.com/git/javadoc/playn/core/json/JsonSink.html). They are
  properly handled by `value(Number)` and these overrides were actually causing problems by
  (silently) promoting `long` to `double`.
* Removed `PlayN.assetManager` methods (deprecated in v1.1). Use
  [PlayN.assets](http://docs.playn.googlecode.com/git/javadoc/playn/core/PlayN.html#assets())
  method.

*Note*: the following are provisional interfaces, not fully implemented, and subject to change:
* Added
  [Keyboard.hasHardwareKeyboard](http://docs.playn.googlecode.com/git/javadoc/playn/core/Keyboard.html)
  and [http://docs.playn.googlecode.com/git/javadoc/playn/core/Keyboard.html Keyboard.getText].
* Added [GL20](http://docs.playn.googlecode.com/git/javadoc/playn/core/gl/GL20.html) abstraction
  over OpenGL ES 2.0. See
  [http://docs.playn.googlecode.com/git/javadoc/playn/core/Graphics.html Graphics.gl20]. This (in
  theory) allows creation of 3D OpenGL games that run on Android and WebGL.

*Note also*: `CanvasLayer` was spared the axe in this release, but it's going away in the next release. Update your code!

### Android
* Bumped to android-maven-plugin 3.1.1 which fixes annoying "must clean before running package"
  problem.
* Fixed use of [String].`isEmpty` which is not available on older Android versions.
* Numerous improvements to GL backend, which should improve performance.
* [PlayN.mouse](http://docs.playn.googlecode.com/git/javadoc/playn/core/PlayN.html#mouse()) now
  returns a service that NOOPs rather than throwing an exception.

### Flash
* Implemented a bunch of features that had been lagging behind the rest of the platform: text
  layout and rendering, immediate mode rendering, alpha support for layers, etc.

### HTML
* Fixed bugs in touch event handling.
* Fixed bug in `HtmlInternalTransform.clone`.
* You can enable GL error checking in the WebGL backend by adding `?glerrors=check` to the URL.
* For Flash based audio (Chrome supports the Web Audio API and is not affected), calling
  [Sound].`play()` before the sound has loaded no longer causes the Flash sound to auto play once it
  loads.

### iOS
* Implemented IOSNet.
* Implemented IOSSound (thanks Nate!).
* Implemented orientation handling.
* Added `ios` submodule to standard PlayN Maven archetype. There are still some wrinkles, but it's
  a lot easier to use the iOS backend now.

### Box2D
* Rewrote `DebugDrawBox2D` to use `CanvasImage` instead of the (deprecated in v1.1) `CanvasLayer`.

----
## PlayN v1.1.1

* (Core)
  [Storage.keys()](http://docs.playn.googlecode.com/git/javadoc/playn/core/Storage.html#keys()) is
  documented as not returning a view of the keys (meaning additions and removals of storage entries
  are not reflected, nor do they cause problems, as one iterates over `keys`). Certain backends
  that were returning a view were changed not to do so.
* (Core)
  [Sound.addCallback](http://docs.playn.googlecode.com/git/javadoc/playn/core/Sound.html#addCallback(playn.core.ResourceCallback))
  added, which allows games to know when a sound has completed loading.
* (Java) Fix for Java `Net` when response length exceeds 4096 bytes.
* (HTML) Fix for IE which was failing due to attempted use of `TypedArray`.

## PlayN v1.1

### Core
New features:
* Added
  [Canvas.setAlpha](http://docs.playn.googlecode.com/git/javadoc/playn/core/Canvas.html#setAlpha(float)).
* [Json] interface was rewritten:
  * Moved from json.org's parser to a more sane parser that matches the behavior of web mode's
    JSON.parse.
  * JSON arrays and objects are now mutable (add, set, remove items).
  * Add an optional default parameter to all JSON getters (0 or null is the default otherwise).
  * Add type introspection to JSON objects and arrays: isArray, isBoolean, isNumber, etc.
  * For an example of the changes you must make to your code, see
    [this commit](http://code.google.com/p/playn-samples/source/detail?r=ed42c8ec40f659e017ef358ca640c7cade28af8a).
* Added [ImmediateLayer]. See [ImmediateTest.java] for an example of its use.
  * Note that the `ImmediateLayer` API may evolve slightly based on feedback as it is a new API.
* Added [PlayN.assets](http://docs.playn.googlecode.com/git/javadoc/playn/core/PlayN.html#assets())
  for obtaining the assets service (replaces `PlayN.assetManager`).

Obsoleted:
* `CanvasLayer` was deprecated. Use `CanvasImage` in conjunction with [ImageLayer]. This
  combination provides a superset of `CanvasLayer` functionality.
* [Image].`replaceWith` was removed.
* `PlayN.assetManager` (and `AssetManager`) was deprecated, use `PlayN.assets` (and `Assets`)
  instead.

### HTML
New features:
* Added HTML5 canvas backend (which joins the HTML5 WebGL backend and the now-deprecated HTML5 DOM
  backend). The canvas backend will automatically be selected for browsers that don't support
  WebGL. Append ?renderer=canvas to force the use of the canvas backend.
* Simple log messages are sent to the browser console even if enhanced logging is not enabled.

Bug fixes:
* Touch events have `preventDefault` called on them automatically now. This prevents undesirable
  scrolling and other weird behavior on mobile browsers.
* Fixed rendering issues with repeat-x/y images.
* Fixed Maven dependencies: `playn-html` no longer exports an inappropriate dependency on
  `gwt-user`.
* Modified Google App Engine support. `playn-html` no longer exports a dependency on GAE jars.
  Those dependencies are added to projects created via the Maven archetype.

### Android
New features:
* Android now properly references `.mp3` files for audio instead of `.wav` files. All backends in
  PlayN now use MP3 encoding.

Bug fixes:
* Pre-multiplied alpha is now properly supported.
* GL cleanup (texture and framebuffer deletion) no longer performed on the finalizer thread.

### iOS
New features:
* The entire iOS backend is a new feature.
* The functionality is not 100% complete (see the [platform status page](PlatformStatus) for
  details) but it is sufficiently complete to try things out.
* There are limited instructions for building your game on iOS. See
  [this thread](https://groups.google.com/d/topic/playn/hkATZ9vjkck/discussion) for details.

### Java
New features:
* Added support for loading assets asynchronously to mimic the behavior of the HTML backends. Set
  the `playn.java.asyncLoad` system property to enable async loading. For example: `mvn
  -Dplayn.java.asyncLoad test -Ptest-java`.
* Added support for registering custom fonts with the Java backend.
  * Other platforms will eventually also have such support.
  * See [ShowcaseJava.java] and [TextDemo.java] for an example of registering and using a custom
    font.

Bug fixes:
* Background is properly cleared to black before painting.

----
## PlayN v1.0.3
* (HTML) Updated gwt-voices dependency to 2.1.5 (fixes Web Audio API issues).
* (Java) Fixed issue with java.io.tmpdir usage.

## PlayN v1.0.2
* (HTML) Added support for deploying PlayN games to Google App Engine.
* (Archetype) Changed `gameName` to `JavaGameClassName` to further communicate expected
  capitalization and naming convention.
* (Core) Added
  [Pointer.Event.isTouch](http://docs.playn.googlecode.com/git/javadoc/playn/core/Pointer.Event.html#isTouch()).
* (Core) Added
  [Storage.keys](http://docs.playn.googlecode.com/git/javadoc/playn/core/Storage.html#keys()).

## PlayN v1.0.1
* (Java) Added MP3 playback support to Java backend. WAV files are no longer needed.
* (Java) Changed JavaAssetManager to load files from the classpath rather than directly from the
  file system.
* (Flash) Disabled the Flash backend as it is currently incompatible with the latest GWT release.

## PlayN v1.0

We weren't making nice release notes back in these days.

[Assets]: http://docs.playn.googlecode.com/git/javadoc/playn/core/Assets.html
[Canvas]: http://docs.playn.googlecode.com/git/javadoc/playn/core/Canvas.html
[Font]: http://docs.playn.googlecode.com/git/javadoc/playn/core/Font.html
[GLContext]: http://docs.playn.googlecode.com/git/javadoc/playn/core/gl/GLContext.html
[GLShader]: http://docs.playn.googlecode.com/git/javadoc/playn/core/gl/GLShader.html
[Game]: http://docs.playn.googlecode.com/git/javadoc/playn/core/Game.html
[Graphics]: http://docs.playn.googlecode.com/git/javadoc/playn/core/Graphics.html
[ImageLayer]: http://docs.playn.googlecode.com/git/javadoc/playn/core/ImageLayer.html
[Image]: http://docs.playn.googlecode.com/git/javadoc/playn/core/Image.html
[ImmediateLayer]: http://docs.playn.googlecode.com/git/javadoc/playn/core/ImmediateLayer.html
[ImmediateTest.java]: http://code.google.com/p/playn/source/browse/tests/core/src/playn/tests/core/ImmediateTest.java
[JavaPlatform.Config]: http://docs.playn.googlecode.com/git/javadoc/playn/java/JavaPlatform.Config.html
[Json]: http://docs.playn.googlecode.com/git/javadoc/playn/core/Json.html
[Layer]: http://docs.playn.googlecode.com/git/javadoc/playn/core/Layer.html
[Log]: http://docs.playn.googlecode.com/git/javadoc/playn/core/Log.html
[Mouse.LayerListener]: http://docs.playn.googlecode.com/git/javadoc/playn/core/Mouse.LayerListener.html
[Mouse]: http://docs.playn.googlecode.com/git/javadoc/playn/core/Mouse.html
[Net]: http://docs.playn.googlecode.com/git/javadoc/playn/core/Net.html
[Platform]: http://docs.playn.googlecode.com/git/javadoc/playn/core/Platform.html
[PlayN.LifecycleListener]: http://docs.playn.googlecode.com/git/javadoc/playn/core/PlayN.LifecycleListener.html
[Pointer]: http://docs.playn.googlecode.com/git/javadoc/playn/core/Pointer.html
[ShaderTest.java]: http://code.google.com/p/playn/source/browse/tests/core/src/main/java/playn/tests/core/ShaderTest.java
[ShowcaseJava.java]: http://code.google.com/p/playn-samples/source/browse/showcase/java/src/main/java/playn/showcase/java/ShowcaseJava.java
[Sound]: http://docs.playn.googlecode.com/git/javadoc/playn/core/Sound.html
[Surface]: http://docs.playn.googlecode.com/git/javadoc/playn/core/Surface.html
[TextDemo.java]: http://code.google.com/p/playn-samples/source/browse/showcase/core/src/main/java/playn/showcase/core/text/TextDemo.java
[Touch]: http://docs.playn.googlecode.com/git/javadoc/playn/core/Touch.html
