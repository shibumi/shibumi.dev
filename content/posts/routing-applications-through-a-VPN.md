---
title: "Routing applications through a VPN"
date: 2020-01-27T22:06:59+01:00
draft: false
description: "How to route you favourite linux application through a VPN using systemd-nspawn container"
tags:
  - linux
---

You may know this problem: You are using a laptop for work and for private stuff and you don't want that
your private traffic gets leaked when you activate your company/university VPN.

I solved this problem via using systemd-nspawn containers for routing certain applications (like webbrowsers) through a specific VPN. First you need a systemd-nspawn container. On Arch Linux you can achieve this via using one of the following steps:

**For an Arch Linux container named archlinux**
```
# pacstrap -c -d /var/lib/machines/archlinux base <your favourite VPN application>
```

**For a Debian container named buster**
```
# debootstrap --include dbus,<your favourite VPN application> buster /var/lib/machines/buster
```

**For an Ubuntu container named bionic**
```
# debootstrap --include dbus,<your favourite VPN application> bionic /var/lib/machines/bionic http://archive.ubuntu.com/ubuntu/
```

When done, create a systemd service override via `systemctl edit systemd-nspawn@<container name>.service`:
```ini
[Service]
ExecStart=
ExecStart=/usr/bin/systemd-nspawn --quiet --keep-unit --boot --link-journal=try-guest --settings=override --machine=%I --capability=CAP_NET_ADMIN --network-veth --bind-ro=/tmp/.X11-unix:/tmp/.X11-unix --setenv="DISPLAY=:0"
```

How does this differ to the usual systemd-nspawn setup? The default line is the following;
```ini
ExecStart=/usr/bin/systemd-nspawn --quiet --keep-unit --boot --link-journal=try-guest --network-veth -U --settings=override --machine=%i
```

The new parameters are: `--capability=CAP_NET_ADMIN` for giving the container the permission to do various network-related operations (Note: This setup is not intended to be secure. It's just for routing traffic for certain apps through a VPN). `--bind-ro=/tmp/.X11-unix:/tmp/.X11-unix` for binding the X11 socket from the container to the X11 socket from the host. This way we are able to start X11 applications inside the container and see them on the host. `-setenv="DISPLAY=:0"` sets the necessary display options for X11 inside of the container. In the end you should be able to start the container `machinectl start <containername>`, login via `machinectl login <containername>` and start your VPN + your favourite X application. If you don't need a graphical application you can get rid of the X11 socket binding in the systemd service override. Regarding VPN configuration: Just configure the VPN as normal, just inside of the container. If you are not able to login you might want to edit the `/etc/securetty` file in the container and add pseudo terminals like `pts/0` to it. You can do this via using `machinectl shell <containername>` this will give directly a shell instead of logging you into a container via pseudo terminal.
