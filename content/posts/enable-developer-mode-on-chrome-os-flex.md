---
title: "How to enable developer mode on Chrome OS Flex"
date: 2022-01-14T12:28:10+01:00
draft: false
description:
tags:
 - linux
---

I have recently switched to Chrome OS Flex as main operating system. The experience so far is really great.
It does everything what it should do. I can browse the internet with it, game with it (in the past Google Stadia, now Xbox Cloud),
answer my mails and even work on Arch Linux. Even printing worked pretty much out of the box.

What does not work properly at the moment is scanning over wifi with my very old HP DeskJet 2540 printer with embedded scanner.
Sadly, Chrome OS does not provide much logging. You can access `/var/log/messages` via visiting `file:///var/log/messages` in your
browser, but this does not give you enough debug information in this case.

This means I had to enable developer mode on my machine. At first, I thought I could just switch to the developer channel of Chrome OS
and this would allow me to access the debug mode, but it does not.

For having direct access to the filesystem, you have to enable developer mode. Developer mode is different to using the developer channel,
because developer mode disables most of Chrome OS great security features (for instance [dm-verity](https://docs.kernel.org/admin-guide/device-mapper/verity.html)).

Enabling developer mode on a Chrome OS Flex device is a lot different to enabling it on a Chrome OS device. On a Chrome OS device you just have to 
press a certain shortcut on boot and you can directly jump into developer mode, but developer mode alone gives you no write access to the filesystem.
For enabling write access, there might be a special screw you have to modify, because many Chrome OS devices have physical write protection.

This article, however, focuses on Chrome OS Flex devices. I hope it is helpful for someone, because I had to collect different information from different areas
in the internet.

## Switching to developer channel

Switching to developer channel is the easiest step. You just have to go into settings, go to `Change channel` and switch to the developer channel.
The official Google documentation has a more detailed description: [https://support.google.com/chromebook/answer/1086915](https://support.google.com/chromebook/answer/1086915?hl=en). Small note from my side: You do not have to powerwash when you change the channel from stable to beta or developer channel.
`Powerwash` is the name of Google's reset mechanism. `Powerwashing` your device means it gets resetted and all personal data will be deleted.

## Switching to developer mode

For enabling developer mode on a Chrome OS Flex device you have edit Chrome OS's `grub.cfg` file in the EFI partition. You cannot do this on the device directly, you must boot a Linux system on the device, mount the correct partition and modify the `grub.cfg` file in the EFI partition.

In my case, I either gave away all my other laptops or all my other laptops are Chrome OS devices, so I had a little bit of trouble to create a bootable Linux USB stick
with Chrome OS. I thought I could just plug in the USB stick, start my Crostini Linux container on my Chrome OS Flex device, forward the USB stick to the container
and then use a Linux tool like `dd` to flash the ISO file (in my case Arch Linux, of course) to the USB stick.

This does not work. Chrome OS will mount the USB stick in Chrome OS instead and there is no way to forward the device to the Crostini container.
Luckily, there is a solution for this and it is called [Chromebook Recovery Utility](https://chrome.google.com/webstore/detail/chromebook-recovery-utili/pocpnlppkickgojjlmhdmidojbmbodfm). The Chromebook Recovery Utility is actually built for creating bootable Chrome OS recovery usb sticks, but with this tool you can also flash any other ISO on an USB stick. There are just a few steps you have to follow:

1. You must rename your ISO file from `<filename>.iso` to `<filename>.bin`
2. In Step 1 of the tool, you click on the little gear icon on the upper right corner.

Clicking on the gear icon opens a dialog box, where you can select `Use local image`. This will allow you to flash the ISO file to the USB stick.

Now, that you have the USB stick, use the USB stick to boot into a Linux RAMFS. In the Linux RAMFS, you can list all partitions via the command `fdisk -l`.
Remember the partition that has the label `EFI...` and then mount this partition via `mount <path to partition> /mnt`.
Next, jump into the `/mnt` directory and search for the file `grub.cfg`. Open this file and insert `cros_debug` to all `grub.cfg` lines.
You can do this by replacing `cros_efi` with `cros_efi cros_debug` (in vim: `:%s/cros_efi/cros_efi cros_debug/g`). Then `umount` and reboot into Chrome OS.

If the device does not boot into developer mode, try also appending `kvm-intel.vmentry_l1d_flush=always` to the `grub.cfg` file. Moreover, `cros_efi` might be called `cros_legacy` on your system, this is especially the case for devices that do not support UEFI.

In Chrome OS open Google Chrome and press `ctrl+alt+t`, this will open the Chrome OS shell (crosh). Type `shell` to get direct shell access. Voila, you are in developer mode now.

## Mounting the rootfs writeable

Developer mode alone might not be sufficient, because you want to very likely modify files. If you tried mounting the rootfs writeable, you might have realized that this does not work. This is because of [dm-verity](https://docs.kernel.org/admin-guide/device-mapper/verity.html). For disabling dm-verity, you must run the following command on Chrome OS Flex and reboot: `/usr/share/vboot/bin/make_dev_ssd.sh --remove_rootfs_verification --force --partition 2`.

The command can be destructive, so make sure to backup any meaningful data first. After a fresh reboot you should be able to do: `sudo mount -o remount,rw /`. This remounts your rootfs writeable and you can directly work on the rootfs. This comes very useful when you want to debug system internals or want more log data for preparing a bug report to the Google Chrome OS team.