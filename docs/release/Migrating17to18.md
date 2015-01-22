---
layout: docs
---

# 1.7 to 1.8 migration

## iOS Audio

The audio code for iOS previously used `AVAudioPlayer` to play sound effects as well as music. This
provided decent but not awesome performance, and games which need to play multiple, overlapping,
high-frequency sound effects would likely encounter big slowdowns due to the less than awesome
performance of `AVAudioPlayer`. The code for sound effects was rewritten to use `OpenAL` (a limited
version of which is built into iOS), which dramatically increases playback performance for sound
effects. Music is still handled by `AVAudioPlayer` because that provides the most flexibility and
music is generally not something that needs high-performance playback.

This change resulted in one incompatible change which games will need to make note of: if you were
using IMA4 compressed CAFF files, you will need to switch to IMA4 compressed AIFF files (denoted
AIFC). Only uncompressed CAFF files are now supported, and using uncompressed CAFF files will
trigger the use of the OpenAL code path and the high performance audio. Using MP3 or AIFC files
(even if loaded via `Assets.getSound`) will use the slower `AVAudioPlayer` code path.

Here's the list of valid ways to convert your audio files for the iOS backend:

```
# creates (uncompressed) sound.caf (little endian, 16 bit)
afconvert -f caff -d LEI16 sound.wav
# creates (uncompressed) sound.caf (little endian, 16 bit, 22kHz)
afconvert -f caff -d LEI16@22050 sound.wav
# creates (uncompressed) sound.caf (little endian, 16 bit, MONO)
afconvert -f caff -d LEI16 -c 1 sound.wav
# creates sound.aifc (IMA4 compression)
afconvert -f AIFC -d ima4 sound.wav
# creates sound.aifc (IMA4 compression, MONO)
afconvert -f AIFC -d ima4 -c 1 sound.wav
```

This release also introduces another change, which I'd like to eventually make consistent across
all platforms, which is that each time you play() a sound, it is started anew on a separate channel
(and thus can overlap itself). You can only control (adjust volume, stop, etc.) the *last* played
instance, but if you're playing a sound often enough to overlap with itself, that is highly
unlikely to matter. The upside is that this DWYM for the most part, because if you're playing a
sound rapid fire, you don't want it to cut out earlier playing copies until/unless you run out of
hardware audio resources.

## iOS Overlay Views

Previously there existed an `IOSPlatform.uiOverlay()` method to obtain a `UIView` into which you
could add components to overlay them on top of your game. That has been removed and you can now add
components to the game view directly by adding them to the `UIView` returned by
`IOSPlatform.gameView()`.

The old code did some hackery to try to make things mostly work when the device was rotated, but it
was error prone. The new code does not currently do anything to handle rotation, and eventually I
hope to figure out how to get iOS to properly auto-rotate the game view (in which case all children
will be properly autorotated as well), but I have not yet figured out the right set of complex
`UIView`/`UIViewController` incantations to make that work.

## Multi-line text

Multi-line text is no longer handled per-platform inside a single `TextLayout` instance. Instead a
new method:

```
TextLayout[] Graphics.layoutText(String,TextLayout,TextWrap)
```

wraps text and returns a `TextLayout` instance for each line of the wrapped text. This also means
that text alignment is no longer handled in per-platform code, but is instead handled in
cross-platform code (making things more consistent and eliminating needlessly duplicated code).

A new class `playn.util.TextBlock` can be used to easily handle a block of wrapped text, and it
provides the same text alignment mechanisms that were provided by `TextLayout`. Simply create a
`TextBlock` using the `TextLayout[]` you got from `layoutText` and call its `fill` or `stroke`
methods to render the text as desired.
