---
title: "Login via Yubikey on Linux (U2F)"
date: 2019-09-29T00:06:57+02:00
draft: false
---

I was very happy with my HMAC challenge-response solution for my Yubikey, but when I wanted to configure my i3 status bar to show the current state of the key I ran into issues.
The problem was that I couldn't see the state for the HMAC challenge. Watching the state (shall I press a button now to activate the key) for GPG worked fine, but I had trouble with the HMAC challenge.
Even the tool [yubikey-touch-detector](https://github.com/maximbaz/yubikey-touch-detector) didn't do what I wanted. So I opened an issue and Maxim (the maintainer of the project) lead me in the right direction: [pam-u2f](https://support.yubico.com/support/solutions/articles/15000011356-ubuntu-linux-login-guide-u2f).

It's possible to use `U2F` for authenticating!

To summarize this. There are two pam modules from Yubico:

* `yubico-pam`: This module is for HMAC challenge-response and maybe more stuff (I didn't look in detail into it)
* `pam-u2f`: This module is the official Yubico module for `U2F`, `FIDO`, `FIDO2`. And it has a few advantages, but more about them later.

The `yubico-pam` module needs a second configured slot on the Yubikey for the HMAC challenge. Therefore one whole slot on the Yubikey is blocked only for this purpose. A slot where you could do other fancy stuff with (a static password as master password for your disk encryption for example). Also HMAC uses `SHA1` as hash function for the challenge, we all know that `SHA1` is broken already, but I would say it's secure for the challenge (because the hashed message M is always different for every challenge, I am wrong, please correct me). Another problem is that `yubico-pam` hasn't seen a release for over a year now (last release is from April 2018).

So I have configured my laptop for `pam-u2f`. With this module I have the following advantages:

* A free second slot to use (maybe as static password for my hard drive encryption or I just leave it blank).
* The module is actually maintained and developed (last release from June 2019).
* The `U2F` is a broader known standard. HMAC challenge-response has been created for applications asking for authentication.
* I can use the `yubikey-touch-detector` to visualize the `U2F` challenge request in my i3 status bar (for this I use [barista](https://github.com/soumya92/barista))

The next big question is: How have I configured `U2F` for logins on my device?

It's not so different. I have created for both users (my daily user "chris" and my administrator account "root") the following file in the home directory:

```bash
$ pamu2fcfg > ~/.config/Yubico/u2f_keys
```

In case of the root user, I need to create the `~/.config/Yubico/` directory first. For my daily user the directory was already there, because Yubico-Manager saved configuration in it.

If you want to attach a second key as backup you can do:

```bash
$ pamu2fcfg -n >> ~/.config/Yubico/u2f_keys
```

After each operation you need to **short** press the Yubikey. With HMAC you needed to **long** press here, because the configuration for it was on the second slot.

Next you need to modify `/etc/pam.d/system-auth` again (remove the old `yubico-pam` line there):
```
[..]
auth      sufficient pam_u2f.so
auth      required  pam_unix.so     try_first_pass nullok
[..]
```

Same as with `yubico-pam`, you can use the keyword `sufficient` here to use the Yubikey **or** the password to login. If you want **true** 2FA experience use the keyword `required`, then you will need both for the login.

The whole process is explained on the official Yubico page ([https://support.yubico.com/support/solutions/articles/15000011356-ubuntu-linux-login-guide-u2f](https://support.yubico.com/support/solutions/articles/15000011356-ubuntu-linux-login-guide-u2f)) as well. The only difference is that I've modified `/etc/pam.d/system-auth` instead of `/etc/pam.d/sudo` (for sudo) and `/etc/pam.d/common-auth` for common logins. I guess `common-auth` is important for graphical logins via loginmanager, but I am not sure about it, because I just use the TTY to login.



