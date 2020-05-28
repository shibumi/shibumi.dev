---
title: "Wayland in 2020"
date: 2020-05-28T15:44:27+02:00
draft: false
description: "Using bemenu and wl-copy with sway on Wayland"
tags:
 - linux
---

It is nearly a year since my last blog article about Wayland on Linux. Thus I thought it is time for an update on how
my desktop with sway developed. What happened?

* I changed my file sharing scripts
* I moved from rofi to bemenu
* I changed my scripts, that were based on rofi

For my file sharing scripts I introduced a new helper script with the generic name `share`.
`share` just uploads a file via SFTP to one of my servers and returns a link to this file.
I decided to move away from using [file](https://filebin.net/), because I would like to be
in control over my data. My old filebin provider [https://paste.xinu.at](https://paste.xinu.at)
has deleted uploaded files after a while. The `share` script depends on `wl-copy`, `rsync`, `openssh`
and `libnotify`. If you want to have a look on `share` and the other scripts, check out my [dotfiles](https://github.com/shibumi/dotfiles/tree/master/.local/bin).

The next topic is rofi. I was actually very happy with rofi, but I nevertheless
decided to went away from it, because there is still no native Wayland support.
So I had a look on the alternatives [wofi](https://hg.sr.ht/~scoopta/wofi) and
[bemenu](https://github.com/Cloudef/bemenu). Wofi looked nice, but I got turned
down by their GTK dependency and their style configuration via CSS. However bemenu was not
100% pain free, too. Bemenu is unable to spawn on the current focused sway workspace.
This means, if you use a multi monitor setup bemenu will always appear on the same screen.

Bemenu has a parameter flag for choosing the right sway monitor, but the format is different to the one that sway uses.
Luckily I managed to find a solution for it. When looking over `swaymsg -r -t get_outputs` I realized that the
monitor names have a specific format: `VGA-1`, `HDMI-A-3`...

I also realized that the last number in this format is the bemenu monitor index I need. The solution is a small python script,
that retrieves the current focused monitor name and extracts the last number via regex:

```python
#!/usr/bin/env python

import asyncio
from i3ipc.aio import Connection
import re


async def main():
    i3 = await Connection().connect()
    outputs = await i3.get_outputs()
    for output in outputs:
        if output.focused:
            return output.name

focus = asyncio.run(main())
match = re.search('.*-(\d)', focus)
print(match.group(1))
```

Hint: This unfortunately only works for a monitor setup with less than 10 monitors. If you have more (wtf?), just change the regex.

I am invoking the python script directly as bemenu parameter flag as: `bemenu -m "$(script)"`.

With moving from rofi to bemenu, I also had to change my password and oath scripts.
My oath script is new:

```bash
source "${HOME}/.local/share/scripts/bemenu"

input=$(ykman oath list | _bemenu -p "oath")
oath=$(ykman oath code -s "$input")
echo "$oath" | wl-copy --paste-once
```

It spawns up bemenu for selecting an oath resource that is saved on my Yubikey and copies it into my Wayland clipboard.
Note that I use `--paste-once` as parameter for `wl-copy`. With this flag I am able to paste this OATH code only once. The clipboard will get
cleaned up afterwards (very useful for secrets, passwords, etc). The downside of `wl-copy --paste-once` is that you can only paste to Wayland
applications with it (this is annoying if you are using Chromium, like me).

My bemenu-gopass script uses the same mechanism:

```bash
source "${HOME}/.local/share/scripts/bemenu"

input=$(gopass list -f | _bemenu -p "gopass")
printf '%s' "$(gopass show -o "$input")" | wl-copy --paste-once
```

`_bemenu` is a small function with my custom bemenu command, because bemenu has no configuration file yet:

```bash
#!/bin/bash

_bemenu() {
  bemenu -i --hb "#151718" --tb "#151718" --nb "#151718" --hf "#9FCA56" --tf "#9FCA56" --fb "#151718" --fn "font pango:inconsolata 8" -m "$(swayfocused)" --no-exec "$@"
}
```

`swayfocused` is the name of my python script that I've mentioned above.




