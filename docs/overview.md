---
layout: docs
---

# Overview

Here we describe the major components of the PlayN library and how they fit together. This is a
conceptual introduction, so we don't show a lot of code. For code, see the [tutorial](tutoria.html)
and the [cookbook](cookbook.html).

## Graphics

PlayN is a library for making games and graphics are pretty important to games, so we'll start
there. PlayN builds all of its graphics services on top of [OpenGL ES 2.0]. This is a low-level GPU
accelerated graphics library which is supported across all the desktop and mobile platforms
supported by PlayN.

### OpenGL

OpenGL is basically a giant collection of functions, some of which manipulate invisible driver and
GPU state, and others of which build up buffers and commands to be sent to the graphics card. PlayN
exposes the OpenGL ES 2.0 API pretty much unadulterated, with some minor bits of Java-fication.
This is 

[OpenGL ES 2.0]: https://www.khronos.org/opengles/2_X/
