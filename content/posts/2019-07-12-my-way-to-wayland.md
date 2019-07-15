---
title: "My Way to Wayland"
date: 2019-07-12T22:03:07+02:00
draft: false
toc: false
images:
tags:
  - untagged
---

I guess everybody knows that X11 aka Xorg is a pain in the ass and a security nightmare.
Therefore it shouldn't be such a suprise that I think about switching to Wayland for a long time now.
And it looks like it's finally the day, where I can switch to wayland without effects on my convenience.

**TL;DR** here is the link to my dotfiles with the whole configuration: [https://github.com/shibumi/dotfiles](https://github.com/shibumi/dotfiles)

But first let's sum up what I need:

* Screen-recording
* Screenshots
* Screen-locking
* A nice tiling window manager
* A dmenu/rofi like menu library with a client
* A notification daemon
* Setting a background

I've decided to go with the following setup:

* [wf-recorder](https://github.com/ammen99/wf-recorder) for screen-recording
* [grim](https://github.com/emersion/grim) for screenshots
* [swaylock](https://github.com/swaywm/swaylock) for screen-locking
* [sway](https://github.com/swaywm/sway) the i3-compatible wayland compositor
* [rofi](https://github.com/davatorium/rofi) as menu library. Unfortunately it's not a native wayland application. So I hope I can replace it with something awesome in the future.
* [mako](https://github.com/emersion/mako) as wayland-ready notification daemon
* [swaybg](https://github.com/swaywm/swaybg) for setting a background


So, how do I start sway? I've build a statement in my `.zshrc` file to start sway automatically, when I
login into my `TTY1`:
```bash
if [ "$(tty)" = "/dev/tty1" ]; then
	exec sway
fi
```

My mako configuration looks like this:
```ini
font=Inconsolata 14
background-color=#151718
text-color=#9FCA56
border-color=#151718

[urgency=high]
text-color=#CD3F45
```

The mako configuration sets some font and color configurations on-default and a special text color for notifications with urgency `high`.

My sway configuration is the same as with my i3 configuration, the only difference is this specific section here:
```bash
# Setting sway specific inputs
input * xkb_layout "de"
input * xkb_variant "us"

# Setting sway specific executions
exec mako
exec swaybg -c "#151718"
```

This configuration will set my us/de hybrid keymap layout and will autoexecute mako and swaybg on sway start.

The next big question is:"How do I share screenshots? Record my Screen or share copypasted text?".
Well, I have a solution for this as well. Here is my small shell script for sharing text via filebin:
```bash
#!/bin/bash
readonly TEXTSHOTDIR="$HOME/.cache/textshot/"

if [[ ! -e "$TEXTSHOTDIR" ]]; then
  mkdir -p "$TEXTSHOTDIR"
fi
readonly TIME="$(date +%Y-%m-%d-%H-%M-%S)"
readonly TEXTPATH="$TEXTSHOTDIR/text-$TIME.txt"
wl-paste >"$TEXTPATH"
readonly OUTPUT="$(fb "$TEXTPATH")"
wl-copy "$OUTPUT"
notify-send "Text uploaded" "$OUTPUT"
```

Taking a screenshot and sharing it via filebin is quite simple as well (btw feel free to fork it and modify it to your needs. All snippets are licensed under GPLv3):
```bash
#!/bin/bash
readonly SCREENSHOTDIR="$HOME/.cache/screenshot"

if [[ ! -e "$SCREENSHOTDIR" ]]; then
  mkdir -p "$SCREENSHOTDIR"
fi
readonly TIME="$(date +%Y-%m-%d-%H-%M-%S)"
readonly IMGPATH="$SCREENSHOTDIR/img-$TIME.png"
grim -g "$(slurp)" "$IMGPATH"
readonly OUTPUT="$(fb "$IMGPATH")"
wl-copy "$OUTPUT"
notify-send "Screenshot uploaded" "$OUTPUT"
```

And finally my solution for sharing screen recordings on the fly (this is a little bit longer):
```bash
#!/bin/bash
readonly VIDEOSHOTDIR="$HOME/.cache/videoshot"

if [[ ! -e $VIDEOSHOTDIR ]]; then
  mkdir -p "$VIDEOSHOTDIR"
fi

readonly PIDPATH="$VIDEOSHOTDIR/videoshot.pid"
readonly RESOURCEPATH="$VIDEOSHOTDIR/videoshot.txt"

if [[ ! -f "$PIDPATH" ]]; then
  readonly TIME="$(date +%Y-%m-%d-%H-%M-%S)"
  readonly VIDPATH="$VIDEOSHOTDIR/rec-$TIME.mp4"
  (
    wf-recorder -g "$(slurp)" -f "$VIDPATH" &
    echo "$!" >"$PIDPATH"
    echo "$VIDPATH" >"$RESOURCEPATH"
    notify-send "Start recording" "$VIDPATH"
    readonly PID="$(cat $PIDPATH)"
    wait "$PID"
    readonly VIDPATH="$(cat $RESOURCEPATH)"
    if [ ! -f "$VIDPATH" ]; then
      notify-send "Recording aborted"
    else
      readonly OUTPUT="$(fb "$VIDPATH")"
      wl-copy "$OUTPUT"
      notify-send "Video uploaded" "$OUTPUT"
    fi
    rm "$PIDPATH"
    rm "$RESOURCEPATH"
  ) &
else
  readonly PID="$(cat $PIDPATH)"
  kill -SIGINT "$PID"
```

Another topic is pasting passwords from a password manager via rofi into your current window.
The tool `xdotool` is not available anymore, because it's X11 only, so wayland will not support it.
Luckily there seems to be someone who has created `ydotool`, it's a replacement for `xdotool` and uses `/dev/uinput` as source for the inputs. However I decided against it, because installing two new libraries and `ydotool` was a too big hassle for me. So I just stick with copying the password into the buffer via `wl-copy`:
```bash
#!/bin/bash
_rofi() {
  rofi -i -no-levenshtein-sort -lines 8 "$@"
}

input=$(gopass list -f | rofi -lines 8 -dmenu -p "gopass")
printf '%s' "$(gopass show -o "$input")" | wl-copy
```

**Note:** This solution is not perfect, as well, because the output will be stored into the clipboard and the clipboard will not get cleaned up! So using `ydotool` is might a better solution.

If you experience problems with Java applications like, `IntelliJ`-IDEs, then you should put the following line in your `.zshrc.` or `.bashrc` line:
```
export _JAVA_AWT_WM_NONREPARENTING=1
```
