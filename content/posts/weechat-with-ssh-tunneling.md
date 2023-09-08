---
title: "Weechat With SSH Tunneling"
date: 2023-09-08T21:43:31Z
draft: false
description: How to setup Weechat with SSH Tunneling
tags:
 - linux
---

In the past, I have used Weechat with Weechat and IRC relays. Since, I have switched to ChromeOS, I disabled the IRC relay, because I switched
to the Weechat Android App on ChromeOS. Nevertheless, I was never 100% happy with the Weechat relay. The relay usually works via a shared password
and access to this relay is equal to SSH access.

Hence, I have decided to switch to SSH tunneling. With SSH tunneling, I am able to use SSH keys for authentication. In this short article I would like
to show you how I have set this up:

1. I moved from Hetzner to Google Cloud, because Google Cloud offers a free tier and I use the VM only as IRC bouncer. No need to pay 40 Euro per year, when I can get something for free.
2. A dedicated user and SSH key pair for weechat reduces the blast radius, if something happens.
3. The SSH access for the weechat user serves only one purpose: Connecting to the Weechat instance.

My `$HOME/.ssh/authorized_keys` file is configured as follows:
```
no-agent-forwarding,no-X11-forwarding,permitopen="127.0.0.1:9001",command="echo 'permission denied'" ssh-ed25519 <redacted> weechat@host
```

The settings before the actual SSH key are SSH options. I do not allow any command execution, thus if I would connect via SSH it would just echo "permission denied".
Via `permitopen="127.0.0.1:9001"` I allow connections to the localhost at port 9001, the port of my Weechat relay.

In the Android Weechat App, I have selected the connection type `SSH tunnel` with relay host `127.0.0.1`, relay port `9001` and the configured relay password in my Weechat.
The Weechat instance on the server is running on a tmux session.

I hope this little article is helpful for someone. Debugging all of this can be very annoying, because the Weechat android app does not support proper debugging log output.
Also, I would prefer a normal Weechat connecting to a Weechat relay, but this feature seems to be work in progress for multiple years now. For now, I am happy with the android app.