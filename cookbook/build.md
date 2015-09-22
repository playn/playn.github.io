---
layout: cookbook
---

# Build

Here we have recipes for doing things with your game's build.

## Using JBox2D

If you want to use PlayN's supplied JBox2D support, you need to add a few things to your game's
build to make sure it works everywhere. The main place to add it is to your `core/pom.xml`:

```xml
  <dependencies>
    ...
    <dependency>
      <groupId>io.playn</groupId>
      <artifactId>playn-jbox2d</artifactId>
      <version>${playn.version}</version>
    </dependency>
    ...
  </dependencies>
```

This will make things work when you're testing with the Java backend, and is all you need to do to
get things working for the Android and iOS backends as well. If you're using the HTML backend, then
you need to do a few more things. First, add to `html/pom.xml`:

```xml
  <dependencies>
    ...
    <dependency>
      <groupId>io.playn</groupId>
      <artifactId>playn-jbox2d</artifactId>
      <version>${playn.version}</version>
      <classifier>sources</classifier>
    </dependency>

    <dependency>
      <groupId>org.jbox2d</groupId>
      <artifactId>jbox2d-library</artifactId>
      <version>${jbox2d.version}</version>
      <classifier>sources</classifier>
    </dependency>
    ...
  </dependencies>
```

Then add to `html/src/main/java/.../YourGame.gwt.xml`:

```xml
<module rename-to='...'>
  ...
  <inherits name="org.jbox2d.JBox2D" />
  ...
</module>
```

This will ensure that GWT has the source code it needs for JBox2D on the build path, and that it
includes it into your project.
