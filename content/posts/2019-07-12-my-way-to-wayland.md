---
title: "My Way to Wayland"
date: 2019-07-12T22:03:07+02:00
draft: true
toc: false
images:
tags:
  - untagged
---

I guess everybody knows that X11 aka Xorg is a pain in the ass and a security nightmare.
Therefore it shouldn't be such a suprise that I think about switching to Wayland for a long time now.
And it looks like it's finally the day, where I can switch to wayland without effects on my convenience.

But first let's sum up what I need:

* Screen-recording
* Screenshots
* Screen-locking
* A nice tiling window manager
* A dmenu/rofi like menu library with a client
* A notification daemon
* Setting a background

To my suprise there are solutions for every bullet point now.

* [wf-recorder](https://github.com/ammen99/wf-recorder) for screen-recording
* [grim](https://github.com/emersion/grim) for screenshots
* [swaylock](https://github.com/swaywm/swaylock) for screen-locking
* [sway](https://github.com/swaywm/sway) the i3-compatible wayland compositor
* [rofi](https://github.com/davatorium/rofi) as menu library. Unfortunately it's not a native wayland application. So I hope I can replace it with something awesome in the future.
* [mako](https://github.com/emersion/mako) as wayland-ready notification daemon
* [swaybg](https://github.com/swaywm/swaybg) for setting a background


