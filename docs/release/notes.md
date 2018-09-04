---
layout: docs
---

# Release notes

* The latest API changes are summarized in: [core diffs], [scene diffs].

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
