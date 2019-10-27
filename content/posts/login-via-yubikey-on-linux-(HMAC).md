---
title: "Login via Yubikey on Linux (HMAC)"
date: 2019-09-27T18:03:17+02:00
draft: false
---

In this small article I want to explain how to use your Yubikey as 2-factor device for logins on Linux.
I used the "Yubikey 5" for this article. If you use an older one, some option will maybe not work.
Make sure to read [https://developers.yubico.com/yubikey-personalization/Manuals/ykpersonalize.1.html](https://developers.yubico.com/yubikey-personalization/Manuals/ykpersonalize.1.html) before reading further.

You need the following Arch Linux packages for this tutorial:

* yubico-pam
* yubikey-manager
* yubikey-personalization
* yubico-c

If you have a fresh Yubikey, the second slot or second configuration should be free, but you can verify this with using the following command:

```bash
$ ykinfo -1 -2
slot1_status: 1
slot2_status: 1
```

If both slots show the number 1, both slots are configured. If one of them shows 0, the slot is not configured. Normally it should look like this with a fresh key:

```bash
$ ykinfo -1 -2
slot1_status: 1
slot2_status: 0
```

The first slot is for Yubico OTP. Yubico OTP needs internet access for connecting to the Yubikey Servers for verifying the challenge, you mostly use this for FIDO/FIDO2 logins on websites. We can't guarantee internet access on our laptop, so we will use the slot 2 instead.

The following command will configure the slot 2 for a challenge: `ykpersonalize -2 -ochal-resp -ochal-hmac -ohmac-lt64 -oserial-api-visible -ochal-btn-trig`.

Let's analyze the command, so we know what's going on:

* `ykpersonalize`: Is the the Yubico tool for configuring your Yubikey.
* `-2`: Means that we want to configure the second slot.
* `-ochal-resp`: Refers to "challenge-response" mode, the mode we want to configure for logins.
* `-ochal-hmac`: This is our "message authentication code" for the challenge. Message authentication codes are used for providing integrity to a message. HMAC uses a hash function (for example SHA-1) for calculating a hash of our message and an outer and inner pad. The outer and inner pads are just constants, that are added to the stream on different moments during the hash calculation. If you want to read more about HMAC, you can do this here: [https://tools.ietf.org/html/rfc2104](https://tools.ietf.org/html/rfc2104)
* `-ochmac-lt64`: This means we calculate the HMAC on less than 64 bytes input.
* `-oserial-api-visible`: The Yubikey will allow its serial number to be read using an API call.
* `-ochal-btn-trig`: The Yubikey will ask for confirmation on every challenge via button pressing.

If you have triggered this command, you can verify if the second slot has been configured via: `ykinfo -2`.
Then you need to create a `.yubico` directory in the home directories of the users you want to auth via Yubikey (for example: `mkdir /home/chris/.yubico`). For the challenge we generate a challenge and store it in the yubico directory via: `ykpamcfg -2 -v`.

The last step is configuring `/etc/pam.d/system-auth`. You should see this line in your `/etc/pam.d/system-auth` file (**you want to open a root shell while editing pam, in case you lock yourself out**):

```
[..]
auth      required  pam_unix.so     try_first_pass nullok
[..]
```

You need to add the following line before this line: `auth sufficient pam_yubico.so mode=challenge-response`. Therefore it should look like this:

```
[..]
auth      sufficient pam_yubico.so mode=challenge-response
auth      required  pam_unix.so     try_first_pass nullok
```

With the keyword `sufficient` we specify that either one of our authentication elements are sufficient. Hence we can use our normal password for authentication **or** or yubikey with long pressing on the button.
If you prefer real 2-factor authentication you can substitute this keyword with the keyword `required`. Then you will need **both** for logging in, the password **and** the Yubikey.
