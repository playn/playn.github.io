---
layout: docs
---

# Create game skeleton

Due to the fact that PlayN supports four different target platforms, a PlayN game project has a lot
of moving parts. Fortunately, the [Maven] build system used by PlayN allows those parts to be
cleanly separated and to stay out of your way until and unless you need them.

## Game project structure

A PlayN game project consists of a top-level meta module and a number of different sub-modules.
Here's an outline of the structure of the [Hello] example project:

```
hello/pom.xml - main project Maven build file
     /core    - cross-platform game code
     /assets  - cross-platform game assets
     /android - Android backend code and configuration
     /html    - HTML backend code and configuration
     /java    - desktop Java backend code and configuration
     /robovm  - iOS (RoboVM) backend code and configuration
```

The main cross-platform game code is in the `core` module. The cross-platform game assets are in
the `assets` module. Due to requirements of the Android and RoboVM builds, it is most convenient to
have the assets in a separate module rather than bundled with the `core` module. The remaining
modules deal with the various supported target platforms.

### Core and Assets

The assets module simply contains images, sounds and other non-code game assets. These are placed
into the `assets/src/main/resources/assets/` directory and organized however you like. The Hello
project contains:

```
assets/pom.xml
assets/src/main/resources/assets/images/bg.png
assets/src/main/resources/assets/images/pea.png
```

The core module contains the game code. This is placed into the `core/src/main/java/` directory
and organized like a normal Java project:

```
core/pom.xml
core/src/main/java/playn/sample/hello/core/HelloGame.java
```

Each module also contains a `pom.xml` Maven build file which contains build instructions and
configuration.

The PlayN sample games follow the Maven standard project layout, which places resources into
`src/main/resources` and code into `src/main/java`, but a game author is free to change that layout
if desired. [This Stack Overflow question] describes the process of customizing the directories in
which Maven looks for code and resources.

Note that even if you plan to build with an IDE, changing directories via the Maven configuration
is a good idea because the IDE will usually read the Maven build configuration files to determine
where to find code and resources in a Maven project. This also ensures that building from the
command line continues to work properly.

### Java backend

The Java module contains just a single source file which bootstraps the game when running in the
JVM:

```
java/pom.xml
java/src/main/java/playn/sample/hello/java/HelloGameJava.java
```

### Android backend

The Android module contains a number of Android-specific configuration files, a source file which
defines an Android `Activity` and which bootstraps the game on Android, and any Android-specific
media resources like the app icons.

```
android/AndroidManifest.xml
android/pom.xml
android/proguard.cfg
android/project.properties
android/res/drawable-hdpi/icon.png
android/res/drawable-ldpi/icon.png
android/res/drawable-mdpi/icon.png
android/res/values/strings.xml
android/src/main/java/playn/sample/hello/android/HelloGameActivity.java
```

The `AndroidManifest.xml` file is the main configuration for an Android app. You'll want to
familiarize yourself with the [Android manifest docs] if you'll be deploying to Android.

### iOS backend

The RoboVM module contains a number of iOS-specific configuration files, a source file which
defines a `UIApplication` and bootstraps the game on iOS, and any iOS-specific media resources like
app icons and splash screens.

```
robovm/Info.plist.xml
robovm/pom.xml
robovm/resources/Default*.png
robovm/resources/Icon*.png
robovm/resources/iTunesArtwork
robovm/robovm.properties
robovm/robovm.xml
robovm/src/main/java/playn/sample/hello/robovm/HelloGameRoboVM.java
```

The `Info.plist.xml` file is the main configuration file for an iOS app. You'll want to
familiarize yourself with [iOS application docs] if you'll be deploying to iOS.

### HTML backend

The HTML module contains the GWT configuration file, a source file which defines a GWT module that
bootstraps your game, an HTML page that hosts your game, and metadata for a Java webapp, which you
can use if you deploy your game via a `war` file (to Google App Engine, for example).

```
html/pom.xml
html/src/main/java/playn/sample/hello/HelloGame.gwt.xml
html/src/main/java/playn/sample/hello/html/HelloGameHtml.java
html/src/main/webapp/HelloGame.html
html/src/main/webapp/WEB-INF/web.xml
```

The `HelloGame.gwt.xml` file is the main GWT configuration file. The GWT [project organization]
documentation provides details on these configuration files.

## Maven archetype

Maven contains facilities for generating new projects from a so-called archetype. PlayN uses this
mechanism to make it easy to generate a new PlayN game project with all the different parts
properly configured according to a small amount of information provided by you up front.

To generate a new PlayN game project using Maven, run the following command:

```
mvn archetype:generate -DarchetypeGroupId=io.playn -DarchetypeArtifactId=playn-archetype -DarchetypeVersion=2.0
```

At the moment version 2.0 is not yet published to Maven Central. If you have installed a local
version of PlayN, you can use the archetype ```Version=2.0-SNAPSHOT```.

This will ask you to provide various metadata for your project. These are explained in turn:

```
Define value for property 'groupId': :
```

This should be a reverse domain that identifies your project. Examples include:
`com.googlecode.myproject`, `com.github.myid.myproject`, `com.mydomain.myproject`.

```
Define value for property 'artifactId': :
```

This should be an all lowercase identifier that identifies your game. Examples include:
`monkeybattle`, `upsetavians`, `gameamazing`.

```
Define value for property 'version':  1.0-SNAPSHOT: :
```

This defines the version used when naming your jar files. You can press enter to use the default:
`1.0-SNAPSHOT`, or if you don't plan on using Maven to deploy snapshot versions of your game to a
Maven repository, you can specify whatever version you prefer (e.g. `1.0`, `0.1`, `r55-alpha`).

```
Define value for property 'package':  com.mydomain.myproject: :
```

This defines the Java package in which your game files will be placed. The default will be the
value you provided for `groupId`, which is often also a good package name. However, you can use
whatever package you like. The PlayN project, for example, eschews the Java tradition of using
verbose reverse domain package names and simply uses `playn`.

```
Define value for property 'JavaGameClassName': :
```

This defines the name used for your game when naming various Java classes. As such it should follow
Java class naming conventions and start with an upper-case letter. Examples include:
`MonkeyBattle`, `UpsetAvians`, `GameAmazing`.

Once you have provided these properties, you will be asked to confirm that they are correct.

```
Confirm properties configuration:
groupId: ....
artifactId: ...
version: ...
package: ...
JavaGameClassName: ...
 Y: :
```

If they are, enter y and press return. Your game skeleton will be generated in a directory with the
name that you provided for `artifactId`.

You should now be able to run your skeleton game:

```
cd <your-new-game-directory>
mvn test -Pjava
```

If you are doing this in preparation for a tutorial, [head back there](index.html#tutorials) and get
going. Otherwise good luck with your exciting new game!

[Android manifest docs]: https://developer.android.com/guide/topics/manifest/manifest-intro.html
[Hello]: http://github.com/playn/playn-samples/tree/master/hello
[Maven]: http://maven.apache.org/
[This Stack Overflow question]: http://stackoverflow.com/questions/4955359/changing-the-maven-structure-src-java-to-src-javasource
[iOS application docs]: https://developer.apple.com/library/ios/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Introduction/Introduction.html
[project organization]: http://www.gwtproject.org/doc/latest/DevGuideOrganizingProjects.html
