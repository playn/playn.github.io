---
layout: docs
---

# Release notes

* The latest API changes are summarized in: [core diffs], [scene diffs].

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
[Exec]: http://playn.io/docs/api/core/playn/core/Exec.html
[Graphics]: http://playn.io/docs/api/core/playn/core/Graphics.html
[Layer]: http://playn.io/docs/api/scene/playn/scene/Layer.html
[core diffs]: ../api/core/changes.html
[scene diffs]: ../api/scene/changes.html
