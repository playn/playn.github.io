---
layout: cookbook
---

# Scene graph

Here we have recipes for doing things with the scene graph.

## Using `Pointer` to combine `Mouse` and `Touch`

The `Pointer` mechanism allows your game to react to either mouse or touch events using a
lowest-common denominator API that is usually sufficient for basic interaction. To cause `Pointer`
events to be dispatched to layers just add the following to your game:

```java
import playn.scene.Pointer;

public class MyGame extends SceneGame {
  public final Pointer pointer;
  public MyGame (Platform plat) {
    super(plat, 33);
    // combines mouse and touch events into pointer events
    pointer = new Pointer(plat, rootLayer, true);
  }
}
```

That's it. See _Reacting to a click on a Layer_ for an example of how to listen for clicks on a
layer and respond to them.

## Reacting to a click on a `Layer`

This example will use the `Pointer` system, but the same approach works if you want to use `Mouse`
or `Touch` events directly. Note that you need to follow the instructions in _Using Pointer to
combine Mouse and Touch_ in order to use the `Pointer` system.

Just create a layer and connect a listener to its `events` signal:

```java
import playn.scene.Pointer;
// ...
ImageLayer layer = new ImageLayer(plat.assets().getImage("button.png"));
layer.events().connect(new Pointer.Listener() {
  public void onStart (Pointer.Interaction iact) {
    plat.log().info("Button click started!");
  }
  public void onEnd (Pointer.Interaction iact) {
    plat.log().info("Button click released!");
  }
  // onDrag() notifies you of movement while the interaction is happening
  // onCancel() notifies you if the interaction was canceled; this happens on mobile
  // sometimes and you should clean up and preted like the click never happened
});
```

Note that `ImageLayer` "knows" its bounds. This is necessary for hit testing to work. When a mouse,
pointer or touch interaction starts, the dispatcher for the appropriate input mechanism looks at
the scene graph at the bounds of each layer to determine which layer is "hit" by the coordinates of
the interaction.

If you create a `Layer` and override `paintImpl`, that layer will not know its bounds by default,
and thus will not react to events because it will assume its size is 0x0. If you want your layer to
respond to events you need to override `width()` and `height()` and return the size of your layer.
This is also true of `GroupLayer`. It will not respond to events itself, though children of a group
layer (like an `ImageLayer`) would respond to events because the dispatcher will keep looking down
the scene graph for a layer hit by an interaction.

If you want the `GroupLayer` itself to respond to events, you can either override `width()` and
`height()` again, or you can set a custom `HitTester` via `Layer.setHitTester`. Note that when
you're doing custom hit testing, you may want to use `Layer.hitTestDefault` to first check whether
any children of the `GroupLayer` were hit before doing your custom hit testing. For example:

```java
GroupLayer group = new GroupLayer();
group.setHitTester(new Layer.HitTester() {
  public Layer hitTest (Layer self, Point p) {
    Layer child = self.hitTestDefault(p);
    if (child != null) return child; // child was hit
    // otherwise check whether p is in your group layer's bounds
  }
});
// now add children to the group, some of which react to events...
```
