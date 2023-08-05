---
title: "Yubikey in Crostini"
date: 2023-08-05T21:45:18+02:00
draft: false
description: How to setup a Yubikey in Arch Linux within ChromeOS
tags:
- linux
- devops
---

Hello friend,

long ago I have ditched Arch Linux for my main operating systems and switched to ChromeOS with Arch Linux in Crostini.
For a long time this setup worked fine, until I encountered a few issues with Arch Linux and Yubikeys.

In this article, I would like to show you how I setup my Yubikey on Arch Linux running in Crostini within ChromeOS.

First, we have to ensure that `/etc/polkit-1/rules.d/99-pcscd.rules` exists with following content:

```javascript
polkit.addRule(function(action, subject) {
  if (action.id == "org.debian.pcsc-lite.access_card" &&
  subject.isInGroup("wheel")) {
    return polkit.Result.YES;
  }
});
polkit.addRule(function(action, subject) {
  if (action.id == "org.debian.pcsc-lite.access_pcsc" &&
  subject.isInGroup("wheel")) {
    return polkit.Result.YES;
  }
});
```

My `$HOME/.gnupg/scdaemon.conf` looks as follows:
```
reader-port Yubico YubiKey
pcsc-driver /usr/lib/libpcsclite.so
card-timeout 5
disable-ccid
pcsc-shared
```

And my `$HOME/.gnupg/gpg-agent.conf`:

```
allow-loopback-pinentry
pinentry-program /usr/bin/pinentry-gnome3
max-cache-ttl 60480000
default-cache-ttl 60480000
```

