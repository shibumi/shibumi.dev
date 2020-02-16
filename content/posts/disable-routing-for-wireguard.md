---
title: "Disable routing for Wireguard"
date: 2020-02-04T17:18:40+01:00
draft: false
---

Think about the following scenario. You have a client at home and you have a
server.  The server permits ssh connections only from the wireguard network
(eg. 10.0.0.0/24).  You have wireguard configured and running on your client,
but you don't want to route all traffic through wireguard.  You actually just
want to access the server via wireguard and route all other traffic normally
through your local gateway (let's say 192.168.2.1). The solution is disabling
the routing for the wireguard client.  And this is how it works:

Normally the wg-quick command will create iptable rules for routing all of your
traffic through your new wireguard gateway (your server running wireguard). You
can disallow this routing via setting `Table = off` inside of your wg
configuration. For example: `/etc/wireguard/germany.conf`:

```ini
[Interface]
Address = 10.0.0.3/24
PrivateKey = <clients private key>
Table = off

[Peer]
PublicKey = <servers public key>
AllowedIPs = 0.0.0.0/0
Endpoint = <your server>:51820
PersistentKeepalive = 25
```

This will disable all routing on the client for wireguard and you should be
able to find your server on for example 10.0.0.1 and connect to the internet
via your normal gateway.

Two of my readers have mentioned that you could also just set `AllowedIPs =
10.0.0.0/24` instead of setting `Table = off` in the wireguard configuration.
