---
title:  "Wireguard with Systemd"
date:   2018-02-22T13:13:13+01:00
draft: false
description: "How to setup wireguard with systemd-networkd"
toc: false
tags:
  - linux
---

As you might know, *systemd-networkd* got support for *wireguard*.
The feature is pretty new. So here is my setup:

**Server**

*/etc/systemd/network/wg0.netdev*
~~~ ini
[NetDev]
Name=wg0
Kind=wireguard
Description="Wireguard Server"

[WireGuard]
PrivateKey=<private key of server>
ListenPort=51820

[WireGuardPeer]
PublicKey=<public key of client>
AllowedIPs=10.0.0.2/24
~~~

*/etc/systemd/network/wg0.network*
~~~ ini
[Match]
Name=wg0

[Network]
Address=10.0.0.1/24
IPForward=True
IPMasquerade=True
~~~

**Client**

And here comes the interesting part. I don't use *systemd-networkd* with
*wireguard* on my client. The reasons for this are a modification of
wg-quick@wg0.service (I trigger i3blocks via POSIX signals for having a
nice VPN icon in my i3statusbar) and the circumstance that
*systemd-networkd* only knows one state: *on*. So if you would configure
the VPN on your client via *systemd-networkd* you would run that VPN on
every startup automatically. There are usecases for this, but that are
not my usecases. I don't need the VPN that often. So for my client, I
use the old way with */etc/wireguard/wg0.conf* file. Nevertheless here
is the client configuration via *systemd-networkd*.  Please keep in
mind: I didn't test the client setup...

*/etc/systemd/network/wg0.netdev*
~~~ ini
[NetDev]
Name=wg0
Kind=wireguard
Description="Wireguard Client"

[WireGuard]
PrivateKey=<private key of client>
ListenPort=51820

[WireGuardPeer]
PublicKey=<public key of server>
AllowedIPs=0.0.0.0/0
Endpoint=<server>:51820
~~~

*/etc/systemd/network/wg0.network*
~~~ ini
[Match]
Name=wg0

[Network]
Address=10.0.0.2/24
DNS=10.0.0.1/24

[Route]
Destination=10.0.0.0/24
~~~
