---
layout: docs
---

# 1.5 to 1.6 migration

A couple of changes to the way that projects are structured were effected with the PlayN 1.6
release. This document describes those changes and how to update your PlayN project to accommodate
them.

## Separate assets submodule

Prior to PlayN 1.6, projects included their assets (images, sounds, etc.) directly in their `core`
submodule. The resources were then included in the `core` jar file for the project and accessed
from there by the different platform backends.

This bundling of the media assets on Android has long been a source of problems. Android has a
special approach to bundling media into an app's APK and because PlayN was not using this
mechanism, certain media (fonts and audio) had to first be extracted from the jar file and written
to temporary storage on the filesystem before it could be passed to the Android APIs. This
complicated the code and provided worse app performance than if the assets were included
"properly".

Properly including the assets means putting them in an `assets` directory at the top-level of the
Android project. In the case of a PlayN game, the `android` directory is the top-level of the
Android project. It so happens that the iOS backend _also_ requires assets to be placed into an
`assets` directory at the top-level of the project, and a hacky approach to making this work had
been in effect prior to PlayN 1.6. With PlayN 1.6 the way Android and iOS assets are configured
have been unified and everything is simpler and cleaner.

In the new app organization, games have a top-level `assets` submodule which contains all of their
assets. The `android` and `ios` submodules _do not_ depend (in the Maven sense) on the `assets`
submodule, but instead symlink the assets directly into their respective project directories so
that they can be found by the Android and iOS build systems. This ensures that the assets are not
included twice into the project (once in the jar file and once via the custom Android and iOS build
systems). The other backends (HTML, Flash, Java) still load assets via the classpath and _do_ have
a dependency on the new `assets` submodule (in addition to their existing dependecy on the `core`
submodule).

Instructions for converting your game to this new structure now follow.

### Migrating your assets to a separate submodule

We are going to assume in these instructions that your game is in a top-level directory called
`yourgame` which contains `core`, `android`, `html`, etc. subdirectories.

Depending on when your project was created, your assets might be in:

```
yourgame/core/src/main/java/yourpackage/resources/...
```

or

```
yourgame/core/src/main/resources/...
```

In either case, you should create a new top-level directory:

```
yourgame/assets
```

And populate it with a `pom.xml` file. The easiest way to create this POM file is to copy
`core/pom.xml` to `assets/pom.xml`, delete everything except the configuration at the top of the
new file and change `-core` to `-assets`. Here is the Hello sample app `assets/pom.xml` file, for
example:

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <parent>
    <groupId>com.googlecode.playn</groupId>
    <artifactId>playn-hello</artifactId>
    <version>1.0-SNAPSHOT</version>
  </parent>

  <artifactId>playn-hello-assets</artifactId>
  <name>PlayN Hello Assets</name>
</project>
```

Also add the assets submodule to your top-level `pom.xml` file:

```
  <modules>
    <module>assets</module>
    <module>core</module>
  </modules>
```

Now create the `yourgame/assets/src/main/resource/assets` directory. Move all of your assets from
their current location to this new assets directory. For example, if you previously had:

```
yourgame/core/src/main/java/yourpackage/resources/images/...
yourgame/core/src/main/java/yourpackage/resources/sounds/...
```

You should end up with a directory structure like so:

```
yourgame/assets/src/main/resources/assets/images/...
yourgame/assets/src/main/resources/assets/sounds/...
```

If you are using the HTML backend, you also need to create
`assets/src/main/resources/YourGameAssets.gwt.xml` and put the following XML code into it:

```
<module>
  <public path="assets" />
</module>
```

Next you need to update your Java, HTML and Flash POMs to depend on the new `assets` submodule.
This will invole adding a dependency that looks something like:

```
    <dependency>
      <groupId>com.googlecode.playn</groupId>
      <artifactId>playn-hello-assets</artifactId>
      <version>${project.version}</version>
    </dependency>
```

to `java/pom.xml`, `hmtl/pom.xml` and `flash/pom.xml`. Of course you should a `groupId` and
`artifactId` that are appropriate for your game.

You will also need to update `yourgame/html/src/main/java/yourpackage/YourGame.gwt.xml` and
`yourgame/flash/src/main/java/yourpackage/YourGameFlash.gwt.xml` to include a reference to the new
`YourGameAssets.gwt.xml` GWT module. Simply add the following to `YourGame.gwt.xml` and
`YourGameFlash.gwt.xml`:

```
  <inherits name='YourGameAssets'/>
```

Next, you will need to edit the Java, Android and iOS backend bootstrap classes and _remove_ the
code that configures an asset path prefix (asset path prefixes are no longer needed on those
platforms):

In `yourgame/java/src/main/java/yourpackage/YourGameJava.java`, remove:
```
  platform.assets().setPathPrefix(yourpackage/resources");
```

In `yourgame/android/src/main/java/yourpackage/YourGameActivity.java`, remove:
```
  platform().assets().setPathPrefix("yourpackage/resources");
```

In `yourgame/ios/Main.cs`, remove:
```
  p.assets().setPathPrefix("assets");
```

Finally, you will need to add some Maven boilerplate that will cause the `android/assets` and
`ios/assets` symlinks to be generated during the build. Add the following to the `<plugins>`
section of `android/pom.xml` and `ios/pom.xml`:

```
      <plugin>
        <groupId>com.pyx4j</groupId>
        <artifactId>maven-junction-plugin</artifactId>
        <version>1.0.3</version>
        <executions>
          <execution>
            <phase>generate-sources</phase>
            <goals>
              <goal>link</goal>
            </goals>
          </execution>
        </executions>
        <!-- generate a symlink to our assets directory in the proper location -->
        <configuration>
          <links>
            <link>
              <src>${basedir}/../assets/src/main/resources/assets</src>
              <dst>${basedir}/assets</dst>
            </link>
          </links>
        </configuration>
      </plugin>
```

Alternatively, you can simply create the symlinks and commit them to your version control system.
The links should be from `android/assets` to `assets/src/main/resources/assets`, for example.

## Source code no longer included with binary jar files

GWT (which is used by the HTML and Flash backends of a PlayN game) requires the source code as well
as the compiled `.class` files normally distributed for a library. To accommodate this requirement,
PlayN previously included its source files into the `.jar` file used to distribte its compiled
class files. PlayN games then followed suit and included their source files into their `core`
submodule's jar files so that their `html` and `flash` submodules could find them.

This causes problems, particularly when one is trying to set up more rapid development for GWT
apps, because the source files get copied into the `target/classes` directory which is necesarily
included in the classpath when doing incremental development in GWT (using devmode or the new super
devmode). If someone then put their real source directory after the `target/classes` in the
classpath, GWT would inadvertently find the copied source files first and potentially use out of
date copies of the source, leading to confusion.

Maven already has a mechanism for distributing the source files for a project, using the
`<classifier>` mechanism for dependencies. Thus PlayN has switched to not bundling its source code
in its binary jar files and instead requires projects to add dependencies on the `sources` jar
files.

If your project uses the HTML or Flash backends, you will need to add the following to the
`<dependencies>` section of your `html/pom.xml` and `flash/pom.xml`:

```
    <dependency>
      <groupId>com.googlecode.playn</groupId>
      <artifactId>playn-html</artifactId>
      <version>${playn.version}</version>
      <classifier>sources</classifier>
    </dependency>
```

The `play-html:sources` dependency will automatically include the `playn-core:sources` and
`pythagoras:sources` dependencies.

If you use `jbox2d` on your project, you will also need to add:

```
    <dependency>
      <groupId>com.googlecode.playn</groupId>
      <artifactId>playn-jbox2d</artifactId>
      <version>${playn.version}</version>
      <classifier>sources</classifier>
    </dependency>
```

If you use `tripleplay` on your project, you will also need to add:

```
    <dependency>
      <groupId>com.threerings</groupId>
      <artifactId>tripleplay</artifactId>
      <version>${playn.version}</version>
      <classifier>sources</classifier>
    </dependency>
```

If you want to convert your game to no longer include source files in its binary `core` jar file,
make the following changes to your `core/pom.xml`.

Remove:

```
    <resources>
      <!-- include the source files in our main jar for use by GWT -->
      <resource>
        <directory>${project.build.sourceDirectory}</directory>
      </resource>
      <!-- and continue to include our standard resources -->
      <resource>
        <directory>${basedir}/src/main/resources</directory>
      </resource>
    </resources>
```

and change this:

```
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-source-plugin</artifactId>
    </plugin>
```

to this:

```
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-source-plugin</artifactId>
      <executions>
        <execution>
          <id>attach-sources</id>
          <phase>generate-resources</phase>
          <goals>
            <goal>jar-no-fork</goal>
          </goals>
        </execution>
      </executions>
   </plugin>
```

Then add a dependency to your sources jar file to your `html/pom.xml` and `flash/pom.xml` files. In
the Hello sample project, this dependency looks like this:

```
    <dependency>
      <groupId>com.googlecode.playn</groupId>
      <artifactId>playn-hello-core</artifactId>
      <version>${project.version}</version>
      <classifier>sources</classifier>
    </dependency>
```
