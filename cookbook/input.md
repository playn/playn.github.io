---
layout: cookbook
---

# Input

Here we have recipes for doing things with user input.

## Tracking modifier keys

Sometimes you want to keep track of whether the shift or ctrl or whatever key is down, maybe for
special debugging or for part of your game. There's unfortunately no cross-platform API for
checking the current state of a given key, so you have to keep track of it yourself. Here's a quick
snippet that does just that:

```java
import playn.core.Keyboard;
import playn.core.Key;

public class YourGame extends SceneGame {

  private boolean shiftDown, ctrlDown;

  public YourGame (Platform plat) {
    // ...
    plat.input().keyboardEvents.connect(new Keyboard.KeySlot() {
      public void onEmit (Keyboard.KeyEvent ev) {
        switch (ev.key) {
          case SHIFT: shiftDown = ev.down; break;
          case CONTROL: ctrlDown = ev.down; break;
          default: break;
        }
      }
    });
    // ...
  }
}
```
