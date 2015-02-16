---
layout: docs
---

# 1.x to 2.x migration

Here are some quick notes I posted to the mailing list. More detailed instructions forthcoming:

1. You have to rename a bunch of stuff (mostly packages changed).

2. The static services went away. A lot of what those did is no longer necessary
(`graphics().createGroupLayer()` is now just `new GroupLayer`), but there are still places where
you need to do things that will require a Graphics instance which you can no longer just pull out
of thin air. You can either just stuff things into static variables when your game starts up and
stick with the thin-air approach, or you can pass what you need down through your game code. The
latter approach will clarify the dependencies your code has, which I think is a good thing in the
long run, but which may be more annoying rewiring than you have the time for.

3. Input handling changed a little. `Pointer` passes an `Interaction` around which contains the
associated `Pointer.Event`. This can be a lot of annoying changes if you had a lot of `Input`
interactions in your code, but the transformations are still mindless. It's basically the same
functionality in nicer clothing.

The one thing you actually have to think about a little bit is `Texture` and texture management. If
you don't care at all, you can just use `Image` the way you used to use `Image` and things will
*mostly* work. But if you're rendering to `Surface` then you will be forced to deal with `Texture`
because you no longer have the option of drawing an image to a texture (which basically NOOPs if
the image is not yet fully loaded). You can still write code like this:

```java
if (image.isLoaded()) surf.draw(image.texture(), ...);
```

which is effectively what the old code did, but now can't hide from the ugliness of that approach.
Depending on your stomach for hackery, that may motivate you to properly wait for your images to
load elsewhere in your code and turn them into Texture objects at that time, then you can draw
`Texture` directly to your `Surface`s and as a bonus, you don't have to hold onto those `Image`
objects, retaining a bunch of memory unnecessarily.

You also need to take care with managed vs. unmanaged `Texture`. If you plan to stuff your
`Texture` into an `ImageLayer` then use a managed texture (the default), but if you're going to be
drawing your texture manually, then you may also want to make it unmanaged so that you don't
accidentally free your texture by sticking it into a layer and then layer destroying that layer
(which will free the texture). If you see textures mysteriously drawn as blackness, or as some
totally different texture, this is probably what happened.

The added complexity is unfortunate, but it's not too difficult to deal with, and the added value
of not having to retain CPU memory for ALL of your images after they've been uploaded to the GPU is
a big big win on memory constrained platforms.
