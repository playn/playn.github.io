---
layout: cookbook
---

# Graphics

Here we have recipes for doing basic graphical things.

## Taking a screenshot

You can use the OpenGL API to copy the data from the main frame buffer into a `ByteBuffer`, but
then you will need to use platform-specific APIs to either save that to a file, or you can send the
pixel data over the network to a server using the `Net` services.

Here's a simple approach to saving a screenshot to a file, in your game. First in
`core/.../YourGame.java` put the following code:

```java
import java.nio.ByteBuffer;
import playn.core.*;

public class YourGame extends SceneGame {
  // ...

  public void saveScreenshot () {
    // figure out how big the viewport is in pixels (we may be on a HiDPI display)
    Graphics gfx = plat.graphics();
    Scale scale = gfx.scale();
    IDimension size = gfx.viewSize;
    int width = scale.scaledCeil(size.width()), height = scale.scaledCeil(size.height());

    // read the framebuffer into our byte array
    ByteBuffer buf = gfx.gl.bufs.createByteBuffer(width*height*4);
    gfx.gl.glReadPixels(0, 0, width, height, GL20.GL_BGRA, GL20.GL_UNSIGNED_BYTE, buf);

    // finally save the screenshot
    saveScreenshot(width, height, buf);
  }

  protected void saveScreenshot (int width, int height, ByteBuffer buffer) {
    // noop; this is overridden by the platform backend
  }
}
```

Then in `java/.../YourGameJava.java` put the following code:

```java
import java.awt.geom.AffineTransform;
import java.awt.image.AffineTransformOp;
import java.awt.image.BufferedImage;
import java.awt.image.DataBufferByte;
import java.awt.image.DataBufferInt;
import java.io.File;
import java.io.IOException;
import java.nio.ByteBuffer;
import javax.imageio.ImageIO;

public class YourGameJava {

  public static void main(String[] args) {
    // ...
    new YourGame(plat) {
      @Override protected void saveScreenshot (int width, int height, ByteBuffer buffer) {
        BufferedImage image = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
        DataBufferInt dbuf = (DataBufferInt)image.getRaster().getDataBuffer();
        buffer.asIntBuffer().get(dbuf.getData());

        // now we need to flip it on the y-axis
        AffineTransform tx = AffineTransform.getScaleInstance(1, -1);
        tx.translate(0, -image.getHeight(null));
        AffineTransformOp op = new AffineTransformOp(tx, AffineTransformOp.TYPE_NEAREST_NEIGHBOR);
        image = op.filter(image, null);

        try {
          ImageIO.write(image, "PNG", new File("screenshot.png"));
        } catch (IOException ioe) {
          ioe.printStackTrace(System.err);
        }
      }
    };
    // ...
  }
}
```

## Adding Custom Fonts

You can use custom fonts in your PlayN game. You'll need to add custom configuration for each
backend that you're using, but once that's done, using the font in your game code is simple. The
fonts are registered by name and you simply create `playn.core.Font` instances with the appropriate
name and use them as normal:

```java
Font font = new Font("Custom Font Name", style, size);
TextFormat format = new TextFormat(font);
TextLayout layout = gfx.layoutText("Hello PlayN World", format);
// ...
```

You also need to obtain your font in `.ttf` or `.otf` format. Place your fonts into the `assets`
module in your game, something like so:

```
assets/src/main/resources/assets/fonts/myfont.ttf
```

Now on to the instructions for configuring the custom fonts in each backend.

### Java backend

In the Java backend, you write code in your bootstrap class to register fonts with `LWJGLPlatform`:

```java
public class MyGameJava {
  public static void main (String[] args) throws Exception {
    LWJGLPlatform.Config config = new LWJGLPlatform.Config();
    LWJGLPlatform plat = new LWJGLPlatform(config);
    plat.graphics().registerFont("My Font", plat.assets().getFont("fonts/myfont.ttf"));
    // ...
  }
}
```

### Android backend

In the Android backend, you write code in your bootstrap activity class to register the fonts:

```java
public class MyGameActivity extends GameActivity {
  @Override public void main () {
    platform().graphics().registerFont("fonts/myfont.ttf", "My Font", Font.Style.PLAIN);
    // ...
  }
}
```

Note that Android requires that you supply a font style as well as a name. The Android backend will
only use your custom font when the name *and* style match. More on that below.

### RoboVM backend

In the RoboVM (iOS) backend, you register the font in your game's `Info.plist.xml` file:

```
    <key>UIAppFonts</key>
    <array>
      <string>assets/fonts/myfont.ttf</string>
    </array>
```

Note that you do not supply a name here. That means that if you're deploying to iOS, you *must*
register your font with the name that's embedded in the font. [This Stack Overflow
question](http://stackoverflow.com/questions/16788330/how-do-i-get-the-font-name-from-an-otf-or-ttf-file)
explains how to find the name embedded in the font. If you don't use the correct name, your code
will fall back to the default system font on iOS which is not what you want.

Also, note that on iOS all custom fonts are only available via the `PLAIN` font style. You can use
`RoboFont.registerVariant` if you want to map bold or italic variants to a single name plus `BOLD`
or `ITALIC` styles, but you probably should not do that. Again see the notes below on font styles.

### HTML backend

In the HTML backend, you must load your custom fonts in the `<style>` section of your game's HTML
file:

```
<!DOCTYPE html>
<html>
  <head>
    <title>My Game</title>
    <style>
      @font-face {
        font-family: "My Font";
        src: url(mygame/fonts/myfont.ttf);
      }
      // ...
    </style>
  </head>
  <body bgcolor="black">
    <div id="playn-root">
      <!-- cause the browser to preload our custom fonts -->
      <span style="font-family: 'My Font'">.</span>
    </div>
    <script src="mygame/mygame.nocache.js"></script>
  </body>
</html>
```

In HTML you can also put `font-weight` and `font-style` into the `@font-face` directive if you want
to denote that a particular font is `BOLD` or `ITALIC`, but again, you probably shouldn't. See the
final section on the recommended way to handle bold and italic typeface variations.

Note that we not only register the font via a `@font-face` CSS directive, but we place a `<span>`
element inside the `<div id="playn-root">` because this causes the browser to start loading the
font immediately when the page is loaded. If you do not do this, the browser will not start loading
the font until your game first attempts to use it, and there is no way to find out when the font
has actually loaded, so you may end up rendering some text in the incorrect font before it has
finished loading.

### On font styles

In the old days before "proper typography" came to computers, it was common for computers to use a
single "font" (rendering of a typeface into shapes) for both plain, bold and italic, where the bold
and italic variants were generated algorithmically. This of course was anathema to anyone who
actually cared about fonts, and when the revolution came, this approach was lined up against the
wall and shot.

Now, civilized, right thinking people use separate "fonts" for each variant of a given typeface
that they will be using. So you'd have "Helvetica.ttf" for Helvetica Plain, and
"Helvetica-Bold.ttf" for Helvetica Bold, and so forth.

Java hails from the pre-revolutionary days and thus still offers support for algorithmically
created font variations. So you can load Helvetica.ttf and ask Java to turn that into a bold
variant and it will (and Mike Parker will roll over in his grave). Android and iOS are from a more
enlightened era and they do not provide support for this. My recommendation is to ignore the font
style mechanism entirely, load all of your fonts as `Font.Style.PLAIN` and use separate names like
"Garamond" and "Garamond Bold" (loaded from separate .ttf files) if you're using both the plain and
bold variants of a typeface.

That said, this is not possible with certain built in fonts. The only fonts you can really depend
on existing on all platforms are "Helvetica", "Times New Roman" and "Courier" (maybe "Arial" but I
haven't tested that). If you want to use those typefaces instead of loading your own custom
typefaces, then you can only access the bold and italic variants by using the `Font.Style` enums.

PlayN does some extra work under the hood to make sure that when you use `new Font("Helvetica",
Font.Style.BOLD, 24f)` the *real* bold variant of Helvetica is used on platforms that provide it
(Android, iOS and HTML), while (desktop) Java does whatever Java does, probably something horrible.
So the only time you really want to be using the `Font.Style` stuff is if you're using built-in
fonts. Otherwise load everything as `Font.Style.PLAIN` and ignore styles. There's even a
constructor font `Font` that ignores style, so just use `new Font("My Font", 24f)` and bask in the
glory of proper line weights and glyph shapes for each variant of your custom typefaces.
