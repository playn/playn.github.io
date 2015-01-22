---
layout: docs
---

# Setup

Here we explain how to set up your development environment so that you can build PlayN games from
source code and run them. We will explain two ways to do so: via the command line with [Maven] and
via the [Eclipse IDE]. It is also possible to build and run PlayN games via the Netbeans IDE,
IntelliJ IDE and most any other IDE one might use for Java development.

PlayN games use a Maven-based build system. Most IDEs now support some level of understanding of
Maven-based projects, which means that you should at least be able to check out and build a PlayN
game, and run the Java backend, without difficulty. The complications arise when you try to build
and deploy the other backends (Android, iOS, HTML5) via your IDE.

Personally, I recommend just usign the command line to build and deploy all backends except Java,
because you don't need to do it very often and it is simple and reliable to do so. The main
maintainer of PlayN builds and deploys things that way, so you know it's going to work. However, it
*is* possible to build and deploy the other backends via your IDE. Search Google and you'll find
tutorials on how to do it.

Each backend is structured like a native app for that platform: the Android backend of your game is
built and deployed like any other Android application, the HTML5 backend is built and deployed like
any other GWT application, the iOS backend is build and deployed like any other RoboVM application.
Each of those projects provides Eclipse plugins at a minimum, which can usually be wrangled into
building and deploying a PlayN game, but the configuration necessary is not something that I'm
familiar with (remember, I use Maven for all that), so these docs won't be explaining it.

## Maven

[Maven] is a build system for Java applications which has a lot of terrible properties, but some
really nice ones which dramatically simplify the development of applications that depend on lots of
libraries. It's thanks to Maven that the *extraordinairily* complex problem of building and
deploying a single application to *four totally different* application platforms can be
accomplished with four trivially simple command line invocations of one tool. So when you're knee
deep in some annoying build problem and hating Maven and the horse it rode in on, remember that it
has also done some really good things too.

If you don't already have Maven installed, you'll need to install it. You need at least Maven 3.0,
but Maven 3.1 is better. If you already have Maven installed, run `mvn -v` to make sure it's new
enough.

On Linux you can probably just `apt-get install maven` (or use whatever package manager your distro
uses). On Mac OS X, you can `brew install maven31` (use [Homebrew]). On Windows you'll probably
need to follow [these instructions](http://maven.apache.org/download.cgi). As far as I know there's
no good package installer for Windows that makes things easy, but hey, you're a Windows developer
so you're probably used to it.

Once you have Maven installed, you'll also need [Git] installed so that you can check out the demo
games to ensure that your setup is working. You can use a GUI git client or a command line client,
it doesn't matter.

### Clone the samples

Now that you're ready to go. Run the following (or do the equivalent in your GUI tool):

```
git clone https://github.com/playn/playn-samples.git
```

### Java backend

From here we should be able to build and run the Java backend straight away:

```
cd playn-samples/hello
mvn test -Pjava
```

You should see a window popup that looks like this:

![Hello world screen](hello.png)

When you click the mouse in the window, a little pea (which may or may not be spinning) should
appear.

If you see the window and a pea, then you're done! You've just built and run your first PlayN game.
Now go do the [tutorial](tutorial.html) or start working on your own game and don't worry about any
of the other backends until you're sure PlayN is the library you want to use. Getting those working
will involve more annoying steps and not much fun. I guarantee that it will eventually work, so
don't waste your time on it until you're sure you need to do it. You don't need to "make sure it
works" right now. It does.

### Android backend

To build and deploy the Android backend, you'll first need to install the [Android SDK]. These days
that comes with a whole copy of the IntelliJ IDE. You don't need all that, so you can just scroll
down to *SDK Tools Only* and download those.

Once you've unpacked the SDK somewhere, you need to run `tools/android` from there and have it
download and install at least the most recent version of the SDK files. That might happen
automatically, but I'm not sure, so best to double check.

Finally, you need to tell Maven where you installed the SDK. This involves adding some XML to your
`.m2/settings.xml` file. On Mac OS and Unix, that's in your home directory: `~/.m2/settings.xml`,
on Windows it's in `C:\Users\USERNAME\.m2\settings.xml` assuming you're not using an ancient
version of Windows.

If your settings file doesn't exist, just copy the below into it, being sure to fill in the path
to where you installed the Android SDK:

```xml
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
     xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
         http://maven.apache.org/xsd/settings-1.0.0.xsd">

  <profiles>
    <profile>
      <id>android-sdk</id>
      <properties>
        <android.sdk.path>
          PATH / TO / THE / ANDROID / SDK
        </android.sdk.path>
      </properties>
    </profile>
  </profiles>

  <activeProfiles>
    <activeProfile>android-sdk</activeProfile>
  </activeProfiles>
</settings>
```

If that file does already exist, just merge the `<profiles>` and `<activeProfiles>` sections into
what you already have.

Next you need to [create and run](http://developer.android.com/tools/devices/emulator.html) an
Android emulator, or plugin in a developer-enabled Android device into your USB port. You can make
sure your Android emulator or device is properly connected by running:

```
$ANDROIDSDK/platform-tools/adb logcat
```

If it says `- waiting for device -` then something isn't working. If you see reams and reams of log
spew, then it is working.

Assuming it is working, then you're nearly done. Just do the following:

```
cd playn-samples/hello
mvn install -Pandroid
```

And this will build and install the Hello demo to your connect Android emulator or phone. It will
show up in your app list as an app named `Hello` with a weird green pea as an icon. Start it up and
tap the screen to create some peas!

### iOS backend

TODO

### HTML5 backend

TODO


[Android SDK]: http://developer.android.com/sdk/index.html
[Eclipse IDE]: https://eclipse.org/
[Git]: http://git-scm.com/
[Homebrew]: http://brew.sh/
[Maven]: http://maven.apache.org/
