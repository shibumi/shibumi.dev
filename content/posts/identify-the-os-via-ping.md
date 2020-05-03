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

One of my readers has pointed out, that you might need to add the hop count to the TTL if your target is more than one hop away.
The hop count is the number of "Internet nodes" you've passed to get to your target.
Here is a more complex example for this blog:

```
traceroute to shibumi.dev (78.46.124.83), 30 hops max, 60 byte packets
 1  _gateway (192.168.178.1)  3.646 ms  3.642 ms  3.626 ms
 2  62.155.243.118 (62.155.243.118)  6.483 ms  6.490 ms  6.473 ms
 3  n-ea9-i.N.DE.NET.DTAG.DE (62.154.24.222)  17.246 ms  17.240 ms  18.123 ms
 4  n-ea9-i.N.DE.NET.DTAG.DE (62.154.24.222)  18.112 ms  18.080 ms  18.028 ms
 5  * * *
 6  core23.fsn1.hetzner.com (213.239.252.230)  20.986 ms  28.003 ms  30.109 ms
 7  spine3.cloud2.fsn1.hetzner.com (213.239.239.134)  25.811 ms  19.757 ms spine1.cloud2.fsn1.hetzner.com (213.239.239.126)  18.434 ms
 8  * * *
 9  10145.your-cloud.host (159.69.97.15)  20.257 ms  20.259 ms  20.233 ms
10  * * *
11  kurisu.shibumi.dev (78.46.124.83)  20.063 ms  20.031 ms  20.005 ms
```

The hop count in this case is 11. So you gonna add 11 to the TTL you've aquired via ping:
```
PING shibumi.dev(shibumi.dev (2a01:4f8:1c17:4572::1)) 56 data bytes
64 bytes from shibumi.dev (2a01:4f8:1c17:4572::1): icmp_seq=1 ttl=55 time=19.3 ms
```

11+55 makes 66, we are close to the number 64 (maybe the ping took a different route?), so it's very likely, that the server is running on Unix or Linux.
If you have an explanation for the hop + TTL difference, write me a mail.
