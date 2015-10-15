---
layout: cookbook
---

# Sound

Here we have recipes for doing things with sound.

## Loading and playing a sound

In order to play a sound in your game, you first have to put a sound file into your `assets`
project in the right location. All game assets (sounds and images) are placed into this directory
(which is relative to the root of your game project):

```
assets/src/main/resources/assets
```

Inside that directory, you can arrange things however you like, but one common approach is to have
`images` and `sounds` subdirectories, so we will follow that approach in this example and add:

```
assets/src/main/resource/assets/sounds/ding.mp3
```

Now we can load and play our new sound easily. The following code loads the sound when the game
starts up and plays it whenever any mouse button is depressed:

```java
import playn.core.*;

public class YourGame extends SceneGame {
  public YourGame (Platform plat) {
    final Sound sound = plat.assets().getSound("sounds/ding");

    plat.input().mouseEvents.connect(new Mouse.ButtonSlot() {
      public void onEmit (Mouse.ButtonEvent ev) {
        if (ev.down) sound.play();
      }
    });
    // ...
  }
}
```

Note that when we load the sound, we __don't__ supply the `.mp3` suffix for the file. This is
because PlayN supports different audio formats for different backends. For example, on the iOS
backend, it is recommended to use CAF (uncompressed) and AIFC (compressed) sound formats rather
than WAV and MP3. PlayN will look for sounds using the suffixes preferred by the backend in
question and then fall back to the more general suffixes if it cannot find the preferred suffix.

The search order for each platform is as follows:

  * Java: .wav, .mp3
  * HTML: .mp3
  * Android: .mp3
  * RoboVM: .caf, .aifc, .mp3

A good practice is to store all of your sounds as uncompressed `.wav` files for use during
development and then have your build automatically generate appropriate compressed formats for the
backends to which you are deploying. This ensures that you always have a perfect copy of your
source audio from which you can transcode to new formats if and when they arise. If you store your
source audio in `.mp3` format, then it is already compressed and transcoding it to another format
will result in reduced sound quality.
