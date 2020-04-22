---
title: "Changing the expiration date of your Yubikey"
date: 2020-04-22T02:58:36+02:00
draft: false
description:
tags:
 - linux
---

In this, hopefully short, article I want to summarize what I've did for changing the expiration date of my GPG key on my Yubikey.
This tutorial is for all people who has generated their GPG key on their laptop and then transferred it to the Yubikey. If you've
generated the GPG key pair on the Yubikey, you will not need this.


We need to differentiate between two cases: Changing the expiration date of a subkey or changing the expiration date of your GPG master key.
In case of the subkeys you can just go call `gpg --edit-key <your key ID>` and edit the expiration date. This should just work out of the box.
If you've made the mistake and set an expiration date for your master key (like me), then welcome in the club! This is more difficult.

For changing the expiration date of your GPG master key, you'll need two things first:

* a backup of your master key (in my case the key with `SC` label or just your public key)
* a backup of your secret key

We'll start with unplugging the yubikey, then we need to delete the GPG stubs of our key. The stubs are the interface for GPG, this way GPG knows that it needs to look on another location for the keys. We don't need them anymore, because we'll import the backups.

For removing the stubs do the following:

`gpg --delete-secret-and-public-keys <your key ID>`

Then restart your gpg-agent to get rid of any potential cache: `systemctl restart --user gpg-agent` (This is maybe different for you).
With a clean gpg-agent we can start importing the backups, we'll start with the master key (this should be your public key):

`gpg --import backup-master-key.gpg`

Next we'll import the secret key:

`gpg --import secret-key.gpg` (make sure that you know your password for it. I nearly forgot mine...)

Ok, now your key should look like this if you call `gpg -K`:

```
sec  rsa4096 2015-07-16 [SC]
      6DAF7B808F9DF25139620000D21461E3DFE2060D
      Card serial no. = 0006 09716835
uid           [ unknown] Christian Rebischke <chris@shibumi.dev>
ssb  rsa4096 2015-07-16 [E] [expires: 2022-04-22]
ssb  rsa4096 2019-04-12 [A] [expires: 2022-04-22]
```

Make sure that the `>` behind `sec` is missing. If you see `sec>` instead of `sec` you are still working on a stub.
If you are sure, that you are not working on a stub anymore, you can edit the key normally now. I suggest you change the
expiration date for your master key to infinite, this way you will always be able to change the expiration date of your subkeys.
And most importantly: You will not have hassle like this anymore. If you've forgot how to change the expiration date, here is a short summary:

```
gpg --edit-key <your key ID>
gpg> expire
gpg> key 1 (this is your first subkey)
gpg> key 2 (this selects additionally your second subkey)
gpg> expire
gpg> save
```

Then, you'll need to export your new pubkey:

`gpg --export --armor <your key ID> > /tmp/pubkey.asc`

Next restart your gpg-agent again, then plugin your yubikey, then call `gpg --edit-key`. Now you can start sending the new keys to the Yubikey (yes, we need to overwrite the keys on the Yubikey, it's the only way, sorry):

```
gpg --edit-key <your key ID>
gpg> keytocard (select the signature slot)
gpg> key 1 (select the right slot)
gpg> (do the same for the other subkeys)
```

If done, we are going to test our new yubikey. Pull out the Yubikey, delete the keys again via `gpg --delete-secret-and-public-keys <your key ID>`, then import your public key and plugin your Yubikey. It should work now as expected and you should see the stubs again if you call `gpg -K`.
Make sure to change the `url` field in the Yubikey via `gpg --card-edit`. I also suggest you enable sign/encrypt/authenticate on touch (if you are doing this already, you'll need to reconfigure this, because the key has changed on your Yubikey):

```
ykman openpgp set-touch enc on
ykman openpgp set-touch sig on
ykman openpgp set-touch aut on
ykman openpgp info
```

When you want to upload your new key on a WKD server, make sure to use `--no-armor` and compare the WKD hashes.


