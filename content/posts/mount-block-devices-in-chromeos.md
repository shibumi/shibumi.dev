---
title: "Mount Block Devices in ChromeOS"
date: 2023-08-05T19:04:49+02:00
draft: false
description:
tags:
 - linux
 - devops
---

I am a big fan of LUKS encrypted USB sticks. They are easy to make and easy to handle on most Linux systems.
ChromeOS is one of these systems, where I had trouble with LUKS encrypted USB sticks or block devices in general.
Although ChromeOS is capable to mount a various number of filesystems, it has no idea what to do with a LUKS encrypted USB stick.
The first idea most people have is launching a Crostini container and decrypting the USB stick via `cryptsetup`.
However, this does not work due to a few security limitations on ChromeOS. In this tutorial, I will show you how you can allow
your Crostini container to mount and handle LUKS encrypted usb sticks or any additional
block device in general. The first step you will have to do is opening the ChromeOS developer
shell via `ctrl+alt+t` in your ChromeOS window. Next, start your `termina` VM
via `vmc start termina`. For this tutorial I am going to assume that you have already a LXC container called `penguin`.
You can print the config of this container via: `lxc config show penguin`.

For mounting and handling block devices we have to do two changes:

1. Set the container to privileged mode. (This might be a security risk, thus only do this if you know what you are doing)
2. Add a raw LXC configuration to allow block devices, device mapping and other permissions that are needed.

We hav no text editor in the termina VM, hence we have to add the raw LXC config with a little trick:

```shell
$ lxc config set penguin raw.lxc=$(cat << EOF
lxc.cgroup.devices.allow = c *:* rwm
lxc.cgroup.devices.allow = b *:* rwm
EOF
)"

$ lxc config set penguin security.privileged=true
```

The above snippet sets all necessary permissions. After doing this restart the LXC container.
Next, you need to add all block devices + partition devices manually. In my case, this is what I did:

```shell
$ lxc config device add penguin /dev/sda unix-block=/dev/sda mode=0666
$ lxc config device add penguin /dev/sda1 unix-block=/dev/sda1 mode=0666
```

With these changes you should be able to jump into the container as usual and decrypt it with `cryptsetup luksOpen /dev/sda usb`.

