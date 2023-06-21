---
layout: docs
---

# Release notes

* The latest API changes are summarized in: [core diffs], [scene diffs].

## PlayN v2.0.8
Thanks to various external contributors for these patches.
* (core) Fixed issue when image regions referred to disposed textures.
* (core) Fixed issues with scaling factors < 1.
* (robovm) Fixed missing calls to save/restore state for Canvas.
* (android) Fixed text rendering for non-integer font sizes.

## PlayN v2.0.7
* Unusable release due to Maven shenanigans.

## PlayN v2.0.6
Thanks to various external contributors for these patches.
* (core) Fix rendering issue in `Canvas.fillRoundRect/strokeRoundRect`.
* (core) Expose ability to create `Canvas` with pixel size and scale.
* (ios) Close SQLite connection on termination.
* (ios) Use UIScreen.nativeScale instead of scale where available (iOS 8+).
* (all) Various changes to fix memory leaks.
* (ios) Fix NSTimer in `RoboPlatform.willTerminate`.

## PlayN v2.0.5
* (core) Fixed problems when clipping rectangle had negative dimensions.
* (core) Added `Scale.roundToNearestPixel` for aligning things to pixel grid on scaled displays.
* (core) `Assets` now looks for higher resolution resource to scale down before looking for a
  lower resolution resource to scale up.
* (core) Added `Input.focus` signal which is emitted when app gains and loses focus. Note that on
  desktop, HTML and other platforms that support window focus, this is different from the enter app
  being paused and resumed.
* (core) `Input.getText` now allows you to pass in the text to use for the `Ok` and `Cancel`
  buttons.
* (core) Added `Exec.invokeNextFrame` which allows an action to be queued up that will run on the
  next frame tick (and _only_ the next frame tick). This also documents that `Exec.invokeLater` can
  possibly run your action on an OS UI thread when the app is paused and the frame tick is not
  running.
* (scene) `ImageLayer` now references new texture before releasing old one. This avoids freeing and
  recreating the same texture in certain edge cases.
* (scene) When the game loses focus, any in progress UI interactions are canceled. This avoids
  problems like a mouse pointer being pressed, then the app loses focus and never hears the release
  event.
* (robovm) Updated RoboVM dependency to 2.3.5.
* (android) Use faster method to commit data saved via `Storage`.
* (android) Bitmaps are no longer loaded as ARGB_4444 on low memory devices. All devices use
  ARBG_8888. Android deprecated support for ARGB_4444.
* (android) The soft keyboard is automatically shown as soon as `Input.getText` dialogs are popped
  up. Previously the user had to tap in the text entry field to show the keyboard.

## PlayN v2.0.4
* (core) Ensure that Java 8 compatible bytecode is generated when building with Java 9+.
* (core) Added [Image] `close` method for explicitly freeing GPU resources (texture) associated
  with `Image`.
* (android) Stop clearing out cache directory in `Activity.onDestroy`. We no longer use the cache
  directory and the app might be using it for its own purposes.
* (android) Fixed issues with `GL20` and `Canvas.save` methods which were removed in later Android
  SDK versions.
* (java) Fixed issue with LWJGL and Java 9+.

## PlayN v2.0.3
* (java) Updated LWJGL dependency to 3.1.6.

## PlayN v2.0.2
* (core) Added [Net.Response] `payloadImage`. Note: this is not available on the HTML backend.
* (core) Added "collector" functions for all event types to [Mouse] and [Keyboard]. See
  `keyEvents` for example.
* (core) [Image] `isLoaded` now only returns true if the image was successfully loaded (not if it
  failed). This is more likely to be what the caller wants.
* (core) Added [Canvas] `drawArc`.
* (core) Fixed issue where `keyboardEnabled`, `mouseEnabled` and `touchEnabled` were not actually
  being honored.
* (core) Added `createPath` and `createGradient` (back) to [Graphics]. They're also available on
  [Canvas], but sometimes you want to create them without having a `Canvas` instance around.
* (java) Fixed some issues with `Clip` handling different audio formats.

## PlayN v2.0.1
* (core) Added device orientation notifications to [Graphics]. See `Graphics.deviceOrient` and
  `Graphics.orientationDetail`.
* (core) Added [Exec] `isMainThread`.
* (core) Fixed bug where textures were released on the non-GL thread (causing crashes).
* (scene) Added debug outline rendering for scene graph. See [Layer] `DEBUG_RECTS`.
* (scene) Added [Layer] `visit` and `debugPrint`.
* (robovm) Added `roboipa` profile to archetype project. Makes it easier to build IPAs.
* (java) Fixed bug in [Assets] `readBytes`: buffer was not being flipped.

## PlayN v2.0

* Everything has changed! Well, not everything, but a lot of stuff.
* Read the [overview](../overview.html) documentation for a summary of the new world order.
* Read the [1.x to 2.x migration guide](Migrating1xto2x.html) for details on changes.

## PlayN v1.x

* The [1.x release notes](notes-1.x.html) are archived on a separate page

[Assets]: http://playn.io/docs/api/core/playn/core/Assets.html
[Canvas]: http://playn.io/docs/api/core/playn/core/Canvas.html
[Exec]: http://playn.io/docs/api/core/playn/core/Exec.html
[Graphics]: http://playn.io/docs/api/core/playn/core/Graphics.html
[Image]: http://playn.io/docs/api/core/playn/core/Image.html
[Keyboard]: http://playn.io/docs/api/core/playn/core/Keyboard.html
[Layer]: http://playn.io/docs/api/scene/playn/scene/Layer.html
[Mouse]: http://playn.io/docs/api/core/playn/core/Mouse.html
[Net.Response]: http://playn.io/docs/api/core/playn/core/Net.Response.html
[core diffs]: ../api/core/changes.html
[scene diffs]: ../api/scene/changes.html
