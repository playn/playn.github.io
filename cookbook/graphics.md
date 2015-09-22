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
