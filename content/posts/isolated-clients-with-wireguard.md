---
title: "Isolated clients with Wireguard"
date: 2020-02-02T15:03:12+01:00
draft: false
---

The Wireguard VPN doesn't isolate clients on default. If you want to enable client isolation, you can do so via the following iptables rules:

```
iptables -I FORWARD -i wg0 -o wg0 -j REJECT --reject-with icmp-adm-prohibited
ip6tables -I FORWARD -i wg0 -o wg0 -j REJECT --reject-with icmp6-admin-prohibited
```

If you want relax the rules for certain clients you can do as follows (where 10.10.10.3 refers to the client and 10.10.10.0/24 to the Wireguard VPN network):

```
iptables -I FORWARD -i wg0 -s 10.10.10.3/32 -d 10.10.10.0/24 -j ACCEPT
```
