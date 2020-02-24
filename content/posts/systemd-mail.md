---
title: "Systemd Mail"
date: 2019-10-12T15:46:06+02:00
draft: false
description: "How to monitor systemd services with mails or how to send an email with systemd service logs"
---

In this small article I am going to explain how to setup a small systemd service for notifications in case of failing systemd services.

You'll need the following software for it:

* systemd
* a mail transfer agent (postfix, qmail, exim, name your poison)
* sendmail (or any other application that can send mails)

I chose sendmail. First create `/usr/local/bin/systemd-mail`:

```bash
#!/bin/bash

sendmail -i -t <<ERRMAIL
To: <your mail address>
From: systemd <root@$HOSTNAME>
Subject: [$HOSTNAME] $1
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8

$(systemctl status --full "$1")
ERRMAIL
```

Then create this systemd service:

```systemd
[Unit]
Description=status email for %i to user

[Service]
Type=oneshot
ExecStart=/usr/local/bin/systemd-email %i
User=nobody
Group=systemd-journal
```

The parameter `%i` works as variable for the corresponding systemd services.

Now you can add the following Line to every systemd service you like to monitor (the line has to be in the `[Unit]` section): `OnFailure=systemd-email@%n.service`. `%n` contains the name of the service, that way it will be correctly replaced in the subject of the mail.

You can also use other keywords than `OnFailure`. Just checkout the systemd man pages.


