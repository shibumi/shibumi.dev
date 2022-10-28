---
title: "Install Arch Linux on ChromeOS"
date: 2022-10-28T22:48:11+02:00
draft: false
description: How to install Arch Linux on ChromeOS
toc: false
images:
tags:
  - linux
---

Hello there.


I have not written a new article for quite a time now, but the waiting is
finally over.  Here comes the article everyone of you ever waited for.

Let us install Arch Linux on ChromeOS together. Yihaaaa...

(Not quite what you expected? Feel free to drop this article :'D).

If you are reading this, this means you are still here. Nice. So, let us start
with a short explanation on why I am doing this:

I think I am a Linux user for over 10 years now. In these 10 years, I have
tested countless of different window managers, distributions and tools on
Linux. These 10 years **allowed** me to do this, because I either went to school
or to university. If you are following me on [Twitter](https://twitter.com/sh1bumi),
you might know that I have recently finished my master's degree and got hired
at a [refrigerator company](https://www.gearrice.com/update/the-story-behind-googles-unique-mini-fridges/). Therefore, you may understand my inspiration for this article.

So, you might ask yourself why I am even switching. I went full circle in these ten years, going
from heavy desktop environments like KDE or Gnome, to slim tiling window managers like sway or dwm,
back to Gnome with Fedora on a work laptop. In the end it was bluetooth that defeated me.
It has been another night in a hotel with Sway and bluetooth on command line that made me finally realize
that I waste too much time with stuff 'normal' people do not suffer from.

This is why I have decided to change something. Sure, I could have just used a nice bluetooth manager
applet and call it a day, but I like to tinker around. This is how I ended up replacing the Debian
container with Arch Linux on a Thinkpad T14 AMD running ChromeOS Flex, what a combination!

Why ChromeOS? ChromeOS is something that always fascinated me since [Lennart Poettering described it as more secure than your typical Linux distribution](https://0pointer.net/blog/#:~:text=In%20fact%2C%20right%20now%2C%20your%20data%20is%20probably%20more%20secure%20if%20stored%20on%20current%20ChromeOS%2C%20Android%2C%20Windows%20or%20MacOS%20devices%2C%20than%20it%20is%20on%20typical%20Linux%20distributions.). Of course, this does not apply to ChromeOS Flex, because you will lose all [Verified Boot](https://www.chromium.org/chromium-os/chromiumos-design-docs/verified-boot/) capabilities, but it is still a nice test bed for finding out if I would buy a Chromebook in the future. I won't go into too much details here, this might be something for another article. Instead, let us finally do something technical and install Arch Linux in [Crostini](https://chromium.googlesource.com/chromiumos/docs/+/master/containers_and_vms.md) in ChromeOS. Crostini is a custom environment in ChromeOS that allows running Linux containers. I do not know how it works in detail, but I do know that there is a VM running on ChromeOS called **termina**. This VM is a very small Linux installation with only one purpose: Running containers via LXC.

Via a Google software called [sommelier](https://chromium.googlesource.com/chromiumos/platform2/+/master/vm_tools/sommelier/) it is even possible to start apps in the container and forward their graphical user interface to the ChromeOS window manager.

The first step you have to do is enabling Linux on ChromeOS. For this you need a device that is running on x86_64 architecture. As far as I know ARM chromebooks are not supported. If the Linux environment is installed you can destroy and recreate the **termina** VM via crosh (ChromeOS' own terminal running in a Chrome tab). Next, just spin up an Arch Linux container via this line:

```
vmc container termina arch https://us.lxd.images.canonical.com/ archlinux/current
```

If you see any error messages, just ignore them. These error messages confused me a lot, but if you
jump into **termina** via running `vsh termina` you should be able to run `lxc list` and see
a new running container.

From here, you can follow the Arch Linux installation guide. Jump in the container (`lxc exec arch -- bash`) and run the following:

```
# pkill -9 -u old-username
# groupmod -n new-username old-username
# usermod -d /home/new-username -l new-username -m -c new-username old-username
# passwd username
# visudo
# usermod -aG wheel username
```

The above changes the old username (most likely your Gmail ID) to something shorter,
sets a new password and gives you sudo permissions via the wheel group.

For installing the [cros-container-guest-tools](https://aur.archlinux.org/packages/cros-container-guest-tools-git) you need a few additional packages (`base-devel`,`devtools`,`pacman-contrib`, `wayland`, `xorg-xwayland`). Before you install these, install `reflector` and seta better package mirror, for instance via `reflector -n 10 --sort score > /etc/pacman.d/mirrorlist`.

One major issue I had was network connectivity. For some reason, `systemd-networkd` failed and the container only got an IPv6 address. I fixed this issue via installing `dhclient` and enabling it via `systemctl enable dhclient@eth0`. Note, that you need a dbus session to use `systemctl`, so you really want to get into the container via running `lxc console`.

The following is a summary of all the steps above:

```
# exit
# lxc console arch
# <press enter>
# sudo -i
# pacman -S reflector
# reflector -n 10 --sort score > /etc/pacman.d/mirrorlist
# pacman -Syu base-devel pacman-contrib wayland xorg-xwayland devtools dhclient
# systemctl start dhclient@eth0
# curl "https://aur.archlinux.org/cgit/aur.git/snapshot/cros-container-guest-tools-git.tar.gz" -LO
# tar xfvz cros-container-guest-tools-git.tar.gz
# cd cros-container-guest-tools-git
# makepkg -si
# exit
# systemctl --user enable --now sommelier@0
# systemctl --user enable --now sommelier@1
# systemctl --user enable --now sommelier-x@0
# systemctl --user enable --now sommelier-x@1
# exit
```

From here, you should be good to go. Stop all running containers do the renaming:

```
# lxc stop --force arch
# lxc stop --force penguin
# lxc rename penguin debian
# lxc rename arch penguin
```

Then open the ChromeOS Terminal App (not crosh) and just start Linux via starting the penguin container.

Voila, you should be running Arch Linux on ChromeOS now.

