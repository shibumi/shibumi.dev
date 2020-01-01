---
title: "My pacman.conf file"
date: 2020-01-01T21:12:09+01:00
draft: false
---

Many users don't modify their **pacman.conf** file. Either because they think
there is not so much to configure or because they are afraid to break
something. In this short article I want to highlight some nice options, that
make my daily use with Arch Linux a lot easier.

First of all, here is my **pacman.conf** without comments:
```ini
[options]
HoldPkg     = pacman glibc
Architecture = auto
IgnorePkg   =
Color
TotalDownload
CheckSpace
VerbosePkgLists
ILoveCandy
SigLevel    = Required DatabaseOptional
LocalFileSigLevel = Optional

[testing]
Include = /etc/pacman.d/mirrorlist
Usage = Sync Search

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[community-testing]
Include = /etc/pacman.d/mirrorlist
Usage = Sync Search

[community]
Include = /etc/pacman.d/mirrorlist

[multilib-testing]
Include = /etc/pacman.d/mirrorlist
Usage = Sync Search

[multilib]
Include = /etc/pacman.d/mirrorlist
```

Most of it should be pretty similar to your **pacman.conf**. Let's start with
the **[options]** sections.  I use the following additional keywords in this
section: **Color**, **TotalDownload**, **CheckSpace**, **VerbosePkgLists** and
**ILoveCandy**. **Color** should be clear, it enables colorized output for
pacman. **TotalDownload** displays more information about downloads and
provides therefore information like the ETA, a download rate and more.
**CheckSpace** checks your system for enough space, before trying to install
packages, **VerbosePkgLists** gives you more information about packages (like
the repository where they come from) and **ILoveCandy** enables the famous
pacman videogame easteregg. If you haven't turned it on yet, you probably
should :-)

So much about my global custom options. Let's talk about repositories. You
might have seen already that I have enabled all testing repositories. Shouldn't
this break my system? No, because I use the keyword **Usage = Sync Search**. This
restricts the usage of the testing repositories on synchronization and search.
Thus it's possible to install testing packages, without accidently installing
them on `pacman -Syu`. Instead I am able to just do `pacman -U
testing/<package name>` and I will install a package from testing.
