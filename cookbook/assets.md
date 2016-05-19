---
layout: cookbook
---

# Assets

Here we have recipes for doing things with assets.

## Loading assets from Android APK expansion files.

`AndroidAssets` supports plugging in a custom asset loader to enable loading assets from APK
expansion files. Here is a loader that uses the Android apk-expansion library:

```java
import java.io.IOException;
import java.io.InputStream;
import android.content.res.AssetFileDescriptor;
import com.android.vending.expansion.zipfile.APKExpansionSupport;
import com.android.vending.expansion.zipfile.ZipResourceFile;
import playn.android.AndroidAssets;

/**
 * An asset source that loads assets from from APK expansion files. Android supports two expansion
 * files, a main and patch file. The versions for each are passed to the constructor. If you are
 * not using either of the files, supply {@code 0} for the version. Both files will be searched for
 * resources.
 *
 * <p>Expansion resources do not make an assumption that the resources are in a directory named
 * 'assets' in contrast to the Android resource manager. Use {@link #setPathPrefix} to configure
 * the path within the expansion files.</p>
 *
 * <p>Expansion files are expected to already exist, be zipped, and to follow the
 * <a href="http://developer.android.com/google/play/expansion-files.html">Android expansion
 * file guidelines</a>.</p>
 *
 * <p>Due to Android limitations, fonts and typefaces can not be loaded from expansion files.
 * Fonts should be kept within the default Android assets directory so they may be loaded via the
 * AssetManager.</p>
 *
 * @throws IOException if the expansion files are missing.
 */
public class ExpansionAssetSource implements AndroidAssets.AssetSource {

  private final ZipResourceFile expansionFile;

  public ExpansionAssetSource (int mainVersion, int patchVersion) throws IOException {
    expansionFile = APKExpansionSupport.getAPKExpansionZipFile(
      plat.activity, mainVersion, patchVersion);
    if (expansionFile == null) throw IOException("Missing APK expansion zip files");
  }

  @Override
  public InputStream openStream (String assetPath) throws IOException {
    return expansionFile.getInputStream(assetPath);
  }

  @Override
  public AssetFileDescriptor getFileDescriptor (String assetPath) throws IOException {
    return expansionFile.getAssetFileDescriptor(assetPath);
  }
}
```

To use it, you need to add the apk-expansion library to your build, which is unfortunately
difficult because Google does not publish Android libraries to Maven Central.

You can just copy the library source code to your game project per the instructions in this Stack
Overflow post:

http://stackoverflow.com/questions/22368251/how-to-make-android-expansion-file-using-android-studio

Or if you build your game with Gradle or Android Studio, there may be a less hacky way to do it.
