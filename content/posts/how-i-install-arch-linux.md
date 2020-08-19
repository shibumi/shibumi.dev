---
title: "How I install Arch Linux"
date: 2020-08-19T15:51:25+02:00
draft: false
description:
tags:
 - linux
---

Recently I have installed Arch Linux on a shiny new Lenovo Thinkpad T14 AMD.
This blog article shall mainly be a reminder for me for the future,
but feel free to use anything useful in it.

I did not install Arch Linux for a long time (nearly over 8 years, lol).
Therefore I never saw a need to automate an Arch Linux installation.
I am aware, that there are solutions for automated Arch Linux installation.
This guide, however, will be a manually guide (I will hopefully automate this later.. HAHA).

The T14 has a 512GB NVMe (this is over 3x more than my X220 with 120GB SSD) and 32GB RAM.
Therefore I have decided for the following partition schema.

| Partition | Size | Usage |
| ---- | ---- | ---- |
| nvme0n1p1 | 1 GB | ESP |
| nvme0n1p2 | 32GB | swap |
| nvme0n1p3 | 479G | System |


Next step was creating the filesystems:

```
# mkfs.vfat -F 32 /dev/nvme0n1p1
# cryptsetup luksFormat /dev/nvme0n1p3
# cryptsetup luksOpen /dev/nvme0n1p3 system
# mkfs.ext4 /dev/mapper/system
```

I left the swap partition out, because I installed it later, when the base system was there.
As next step I mounted everything:

```
# mount /dev/mapper/system /mnt
# mkdir /mnt/boot
# mount /dev/nvme0n1p1 /mnt/boot
```

The next step created my base system, with everything what i need.

```
# pacstrap /mnt base linux linux-firmware sway iwd alacritty chromium fwupd \
	hplip w3m slurp pacman-contrib ttf-baekmuk noto-fonts-emoji hugo skim \
	man-db archlinux-contrib cups ttf-sazanami ttf-inconsolata noto-fonts \
	fuse2 fuse3 wl-clipboard gcr pinentry pcsclite yubico-c yubico-c-client \
	yubico-pam yubikey-manager yubikey-personalization yubikey-touch-detector \
	zsh-syntax-highlighting weechat pavucontrol xorg-xev brightnessctl \
	mlocate xorg-server-xwayland grim wf-recorder exa tlp acpi \
	sof-firmware amd-ucode tmux sudo go zsh git mako htop \
	gcc libnotify base-devel swaylock bemenu neovim gopass pulseaudio pamixer \
# genfstab -p /mnt >> /mnt/etc/fstab
```

For my swap partition I entered this line into my fstab file:
```
# /dev/mapper/swap UUID=a4d116ea-450e-4902-8a9d-b8a829c87d35
/dev/mapper/swap          	none      	swap      	defaults  	0 0
```

And this line here into /etc/crypttab:
```
swap		PARTUUID=c89118d6-5d50-bb4e-9c31-b55205861134				/dev/urandom		swap,cipher=aes-xts-plain64,size=256
```

Where PARTUUID=c89118d6-5d50-bb4e-9c31-b55205861134 is the partition UUID of /dev/nvme0n1p1.
Next I chrooted into the system and generated locales, mkinitcpio, boot loader etc.

```
# nvim /etc/locale.gen
# locale-gen
# nvim /etc/mkinitcpio.conf
```

My /etc/mkinitcpio.conf uses systemd hooks:
```
HOOKS=(base systemd keyboard autodetect modconf block sd-vconsole sd-encrypt filesystems fsck)
```

Finally I set up my kernel, the bootloader and set a new root password and started into the new system:

```
# mkinitcpio -p linux
# mkdir -p /boot/loader/entries
# nvim /boot/loader/loader.conf
# nvim /boot/loader/entries/motoko.conf
# passwd root
# bootctl install
# bootctl status
# exit
# umount /mnt/boot
# umount /mnt
# cryptsetup luksClose system
# reboot
```

My loader.conf:
```
default motoko.conf
editor no
```

My motoko.conf:
```
title motoko
linux  vmlinuz-linux
initrd amd-ucode.img
initrd initramfs-linux.img
options rd.luks.uuid=6de4dec9-6d2e-448f-a743-591194eeae8d rd.luks.options=discard rd.luks.name=6de4dec9-6d2e-448f-a743-591194eeae8d=system root=UUID=b80387fc-41de-424a-9ec7-3abc7cb14d8d rw
```


After rebooting, I did a few other things, just like setting up a new user, cloning my dotfiles repository into the users home, setting timedatectl,
systemd-nspawn and systemd-resolved and more.

I hope this short guide gives you a rope to follow and I hope my way of installation will not be invalid in the next 10 years.
