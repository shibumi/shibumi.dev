---
title: "Postmortem 2020-04-28"
date: 2020-04-29T00:04:35+02:00
draft: false
description: "postmortem for shibumi.dev for the 2020-04-28"
tags:
 - linux
 - devops
 - postmortem
---

## Prolog

My server went down today. So I've decided to write a little postmortem for me, so that I will hopefully learn from my server outage.
This is also a nice moment to learn how Google writes postmortems: [https://landing.google.com/sre/sre-book/chapters/postmortem/#id-YAJuMt7iQW](https://landing.google.com/sre/sre-book/chapters/postmortem/#id-YAJuMt7iQW)

## Overview

**Date**: 2020-04-29

**Status**: Complete, action items in progress

**Impact**: The following of my components went down for a period of 5 hours and 6 minutes:
* [https://shibumi.dev](https://shibumi.dev)
* WKD server
* [https//nspawn.org](https://nspawn.org) (images are partly persist unavailable)
* IRC bouncer
* git server

**Root Causes**: Backup restore mechanisms didn't work as expected. Server has booted after upgrade, but has been partly inconsistent.
The package manager dnf has stopped working, due to the python2 to python3 move of Fedora 32. Also SSH login were not possible anymore.
Login on Rescue console, was not possible due to selinux enforcing new PAM rules.

**Trigger**: Failed Upgrade from Fedora 31 to Fedora 32.

**Resolution**: I've setup Fedora 31 again and restored the files I needed from the backup, instead of doing a full system backup or trying to repair the broken Fedora 32 installation.

**Detection**: [https://uptimerobot.com](https://uptimerobot.com) registered a server failure at 2020-04-28 15:45:23 CET.

## Lesson Learned

### What went well

* Monitoring detected server failures quickly. However, not all services are covered yet (HTTP and ICMP only).
* Restoring single files from the restic backup worked superb.

### What went wrong

* Restoring full system from restic was not possible. I really have to look into this and train such situations. After an hour of battling with restic, grub and several other tools, I just gave up and rebuild the server from scratch.
* Hetzner Console is awful. I have an US key layout on my laptop, but the Hetzner console uses a German key layout. So I've encountered different annoying issues:
	1. The root login failed, due to z/y swap, so I need to start the rescue image and set a new password.
	2. Pasting URLs into the console got altered. I tried downloading some RPMs, but I wondered that curl told me, that the host `http` is unknown. So after several minutes I've realized, that the colon in the URL got altered to a semicolon, because of the wrong key layout. This situation made me manually correcting all pasted URLs.
* The login via password on a TTY didn't work on Fedora 32, because of a combination of enabled selinux and PAM rule that enforces, that users with a UID under 1000 can't login locally.
* SSH login has not been possible. I still have no explanation for this.
* An upgrade of a fresh Fedora 31 to a Fedora 32 took over 30min with max CPU load. No explanation for this here as well. Maybe the Hetzner VMs are just too weak or Hetzner has altered the Fedora 31 images so much, that a clean update is not possible anymore. This could be the explanation, why Hetzner has not released a Fedora 32 image yet.

### Where I have been lucky

* Restic backup restore of single files worked.

### Action Items for the future

* Finally having an ansible playbook for restoring a server from scratch
* Testing restic full system restores.
* Generating new systemd-nspawn images for [https://nsapwn.org](https://nspawn.org)
* Adding more service monitoring via [https://uptimerobot.com](https://uptimerobot.com)
* High-Availability for my blog (maybe a second server + reverse proxy?)

## Timeline

2020-04-28 (all times CET):

* 15:45: first outage.
* 16:20: back online again with broken Fedora 32 installation.
* 20:51: back online again with most systems (images for [https://nspawn.org](https://nspawn.org) are still missing).
