---
title: "Share your Wifi via QR code"
date: 2020-04-07T00:34:02+02:00
draft: false
description: "How to create a QR code for sharing Wifi credentials"
tags:
 - linux
---

Hey, this is going to be a short blog article. A few days ago I had a friend at my place who asked for the Wifi password.
So I presented my 32 char WPA2 key and we all got very frustrated, because we had to type it in manually.
After typing the key in, I thought there must be a better solution for tackling this problem, like generating a QR code.
This actually works. The only requirement is that you follow a specific format:

`WIFI:S:{SSID name of your network};T:{security type - WPA or WEP};P:{the network password};;`

For example:

`WIFI:S:MySweetSSID;T:WPA;P:mysecretpassword;;`

On Linux you can directly convert this string via `qrencode` to a QR code:

`qrencode -o - -t utf8 'WIFI:S:MySweetSSID;T:WPA;P:mysecretpassword;;`

This command will directly draw a QR code via UTF8 in your terminal (I hope your terminal and font support UTF-8)
