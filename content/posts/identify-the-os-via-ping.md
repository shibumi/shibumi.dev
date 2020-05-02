---
title: "Identify the OS via ping"
date: 2020-05-02T15:29:06+02:00
draft: false
description: "How to identify the Operating System (OS) via ping utils"
tags:
 - linux
 - ctf
---

This article will be rather short. I just wanted to highlight something, that not much people know. This could be helpful for network diagnostics or capture-the-flag games.

If you ever find yourself in the situation to identify a device's OS only by it's IP address, you can try just pinging the device.
The TTL (Time-To-Live) will give you an hint about the OS. You can use the following table for the beginning:

| OS | TTL |
| -- | -- |
| Linux/Unix | 64 |
| Windows | 128 |
| Solaris/AIX | 254 |

Here is an example for my local router:

```
PING 192.168.178.1 (192.168.178.1) 56(84) bytes of data.
64 bytes from 192.168.178.1: icmp_seq=1 ttl=64 time=1.15 ms
64 bytes from 192.168.178.1: icmp_seq=2 ttl=64 time=1.71 ms
```
