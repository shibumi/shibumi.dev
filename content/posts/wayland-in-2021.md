---
title: "Wayland in 2021"
date: 2021-03-13T19:21:33+01:00
draft: false
description: Running Wayland on Linux in 2021
tags:
 - linux
---

A year ago I wrote about my Wayland setup on Linux. This year I would like to give you a small
update on how I am going with Wayland on Arch Linux and how it is my daily driver at home and work.
The setup itself stayed pretty much the same:

* Operating System: Arch Linux
* Window Manager: Sway
* Status bar: Heavily customized Barista bar
* Screenshots: Bash script utilizing Grim + Slurp
* Screen recordings: Bash script utilizing wf-recorder
* Sharing Text: Bash script utilizing wl-clipboard
* Dynamic Menu: bemenu
* Password Management: A combination of gopass, bemenu and bash
* Screensharing: xdg-desktop-portal-wlr + pipewire

You can find my full setup in my [dotfiles repository on Github](https://github.com/shibumi/dotfiles).

Let us have a quick look on the whole setup from above bullet point per bullet point.

## Sway

My sway setup is not so special. I use [mako](https://github.com/emersion/mako) for notifications,
[kanshi](https://github.com/emersion/kanshi) for dynamic display configuration and a few other scripts.
The full sway config can be found here: [https://github.com/shibumi/dotfiles/blob/master/.config/sway/config](https://github.com/shibumi/dotfiles/blob/master/.config/sway/config)

## Status bar

[Barista](https://barista.run) is a Framework written in Go for writing i3-compatible status bars.
The framework should cover most functionality you are looking for and if you want additional
features you can easily execute scripts via this framework or extend it by pure Go code.
However I would only suggest this framework for people who feel comfortable with Go.
The configuration process can be tedious and I am still missing 1-2 features I would like to have.
If you have everything you need [Barista](https://barista.run) is definitely way faster than your
usual status bar that just executes bash scripts. Here is a small snippet from my status bar
that is showing the current Yubikey state:

```go
	barista.Add(yubikey.New().Output(func(gpg bool, u2f bool) bar.Output {
		if u2f {
			out := outputs.Text("U2F")
			out.Color(colors.Scheme("degraded"))
			return out
		}
		if gpg {
			out := outputs.Text("GPG")
			out.Color(colors.Scheme("degraded"))
			return out
		}
		return nil
	}))
```

If you are interested in the full code you can find it here: [https://github.com/shibumi/ryoukai/blob/master/main.go](https://github.com/shibumi/ryoukai/blob/master/main.go)

## Screenshots

For triggering screenshots I use this short script:
```bash
#!/bin/bash
readonly SCREENSHOTDIR="$HOME/.cache/screenshot"

if [[ ! -e "$SCREENSHOTDIR" ]]; then
  mkdir -p "$SCREENSHOTDIR"
fi
readonly TIME="$(date +%Y-%m-%d-%H-%M-%S)"
readonly IMGPATH="$SCREENSHOTDIR/img-$TIME.png"
grim -g "$(slurp)" "$IMGPATH"
share "$IMGPATH"
```

The script just takes a screenshot via slurp and grim, puts the screenshot in a directory in my home directory
and triggers my `share`-script. The `share` script just handles notifications and uploads it to my webserver
via SSH and copies the link to it in my clipboard. The full `share`-script can be found here: [https://github.com/shibumi/dotfiles/blob/master/.local/bin/share](https://github.com/shibumi/dotfiles/blob/master/.local/bin/share)

## Screen recordings

For screen recordings I have a script called `videoshot-wl`. It is a little bit more complicated than the script for taking
screenshots. It makes use of slurp and wf-recorder and it works the following way:

1. The script gets triggered and spawns a sub shell. This sub shell is recording the screen.
2. If the scripts gets triggered again the sub shell will get killed, the recording proccess stopped and the recording uploaded to my webserver.

In bash this looks like this:
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
      share "$VIDPATH"
    fi
    rm "$PIDPATH"
    rm "$RESOURCEPATH"
  ) &
else
  readonly PID="$(cat $PIDPATH)"
  kill -SIGINT "$PID"
fi
```

The uploading process happens in my `share` script.

## Sharing text

Sharing text is very simple again. For sharing text I just copy it in my clipboard (this happens already when marking
something in my terminal) and then I use my `textshot-wl` script:

```bash
#!/bin/bash
readonly TEXTSHOTDIR="$HOME/.cache/textshot/"

if [[ ! -e "$TEXTSHOTDIR" ]]; then
  mkdir -p "$TEXTSHOTDIR"
fi
readonly TIME="$(date +%Y-%m-%d-%H-%M-%S)"
readonly TEXTPATH="$TEXTSHOTDIR/text-$TIME.txt"
wl-paste >"$TEXTPATH"
share "$TEXTPATH"
```

The script is just writing everything in my clipboard into a text file and uploads it. The webserver will then show
the text file as it is. The disadvantage of this approach is clearly that I will have no additional features like
comments or syntax highlighting (I miss this sometimes). If I really need those features I use [gist](https://gist.github.com/)

## Dynamic menu

My dynamic menu for starting programs is just a customized execution of bemenu:

```bash
#!/bin/bash
bemenu-run -i --hb "#151718" --tb "#151718" --nb "#151718" --hf "#9FCA56" --tf "#9FCA56" --fb "#151718" --fn "font pango:inconsolata 8" "$@" -m "$(swayfocused)" -p ">"
```

## Password management

I have direct access to my password manager via bemenu and gopass.
Via bemenu I choose the password entry (fuzzy search, yeah), then the script will trigger gopass
and then the output of  gopass will get copied for one-time use in my wayland clipboard:

```bash
$!/bin/bash
source "${HOME}/.local/share/scripts/bemenu"

input=$(gopass list -f | _bemenu -p "gopass")
printf '%s' "$(gopass show -o "$input")" | wl-copy --paste-once
```

The interesting part here is the one-time usage. I can use this password in the clipboard **only** once.
If I paste it, it will instantly get deleted from my clipboard. This also means that this currently only works
in Wayland applications (one of the reasons why I use this script less than I should).

Small addition: I have a similar script for pasting OATH codes from my yubikey:

```bash
$!/bin/bash
source "${HOME}/.local/share/scripts/bemenu"

input=$(ykman oath list | _bemenu -p "oath")
oath=$(ykman oath code -s "$input")
echo "$oath" | wl-copy --paste-once
```

### Update (2021-03-14)

I always thought that `wl-copy --paste-once` does not work in the browser, because the browser was not
Wayland-native. Turns out even with Wayland-native browsers you will encounter the same bug.
This seem to be related to [https://github.com/bugaevc/wl-clipboard/issues/107](https://github.com/bugaevc/wl-clipboard/issues/107).
I decided to fix this issue for me via using a timer and `wl-copy --clear` instead of `wl-copy --paste-once`:

The new script for triggering bemenu looks like this:
```bash
#!/bin/bash
source "${HOME}/.local/share/scripts/bemenu"

input=$(gopass list -f | _bemenu -p "gopass")
printf '%s' "$(gopass show -o "$input")" | wl-copy
sleep 5
wl-copy --clear
```

## Screen sharing

Screen sharing is a bigger topic. I really had a lot(!) issues with it over the last
months, especially in combination with Microsoft Teams and other enterprise-ish software.
Nevertheless I think I have found a stable solution for it a few days ago.

What you need is:

* chromium or Firefox with WebRTC pipewire support (you need to enable this in chromium)
* [xdg-desktop-portal-wlr](https://github.com/emersion/xdg-desktop-portal-wlr)
* pipewire + libpipewire02 + pipewire-media-session

First make sure that the pipewire-media-session service is enabled and running for your user.
The devs of xdg-desktop-portal-wlr say that you normally do not need it, but for some strange reasons
you will need the a running pipewire-media-session service:

```
$ systemctl enable --user pipewire-media-session.service
```

Furthermore you need to set the following environment variable: `XDG_CURRENT_DESKTOP=sway`.
I do this via my `.config/environment.d/envvars.conf`-file:
```
EDITOR=nvim
PAGER=less
SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
IBUS_SOCK="$XDG_RUNTIME_DIR/ibus.socket"
TERM="xterm-256color"
GOPATH=$HOME/go
GOBIN=$HOME/go/bin
_JAVA_AWT_WM_NONREPARENTING=1
_JAvA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true"
JAVA_FONTS=/usr/share/fonts/TTF
KUBECONFIG="$(find ~/.kube/configs/ -type f -exec printf '%s:' '{}' +)"
XDG_CURRENT_DESKTOP=sway
XDG_SESSION_TYPE=wayland
```

This file sets all of my environment variables and gets automatically loaded by systemd on login.
If you have the environment variable and a working pipewire-media-session service everything else should work
out of the box.

### Update (2021-03-14)

Right now it is not possible to directly select the output for the screen sharing in the browser.
You can work around this issue via this little script here:

```bash
#!/bin/bash
source "${HOME}/.local/share/scripts/bemenu"

input=$(swaymsg -t get_outputs | jq -r '.[].name' | _bemenu)
/usr/lib/xdg-desktop-portal -r & /usr/lib/xdg-desktop-portal-wlr -r -o "$input" &
```

This script allows me to select the screen for screen sharing. I just have to remember that I need to
trigger this script before sharing my screen. The preview window in the web browser will then show the
correct screen preview. The disadvantage from this method is that you need to know your monitors
name. If you find a better solution for this let me know.
