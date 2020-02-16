---
title: "How to setup your own WKD server"
date: 2020-02-16T20:02:28+01:00
draft: false
---

You may have heard about the
[problems](https://gist.github.com/rjhansen/67ab921ffb4084c865b3618d6955275f)
with recent PGP key server implementations. I don't want to reiterate the
technical challenges with recent PGP key server implementations. I think there
are enough explanations for this in the Web.

So let us focus on preventing the problems. One possible solution around this
problem is self-hosting your own WKD server. WKD stands for Web Key Directory.
It's a new standard for hosting PGP keys via using existing infrastructure
(webservers and HTTPS). You can find the current draft for the standard here:

[https://tools.ietf.org/html/draft-koch-openpgp-webkey-service-09https://tools.ietf.org/html/draft-koch-openpgp-webkey-service-09](https://tools.ietf.org/html/draft-koch-openpgp-webkey-service-09)

The draft is long, so let me summarize this for you.
You need the following components for a successful WKD server:

* A webserver (Nginx,Apache,Caddy whatever you want)
* An own domain
* A valid TLS certificate (Let's Encrypt to the rescue!)

A WKD server is the wrong solution for you, if:

* You have no webserver
* You have no domain
* You have no key ID with your domain

The magic behind a WKD server is simple. The client (this can be either GPG or
even Thunderbird) will look up your key ID, then it will resolve the domain in
your key ID and will try to retrieve your public key via your domain and
webserver. Let us have a look on an example. This is my key with my various key IDs:

```
sec>  rsa4096 2015-07-16 [SC] [expires: 2020-06-25]
      6DAF7B808F9DF25139620000D21461E3DFE2060D
      Card serial no. = 0006 09716835
uid           [ultimate] Christian Rebischke (Arch Linux Security Team-Member) <Chris.Rebischke@archlinux.org>
uid           [ultimate] Christian Rebischke <chris@nullday.de>
uid           [ultimate] Christian Rebischke / Shibumi (Milliways) <shibumi@milliways.info>
uid           [ultimate] Christian Rebischke (www.nullday.de) <Chris.Rebischke@gmail.com>
uid           [ultimate] Christian Rebischke (TU-Clausthal) <christian.rebischke@tu-clausthal.de>
uid           [ultimate] Christian Rebischke <christian.rebischke@mailbox.org>
uid           [ultimate] Christian Rebischke (Archlinux Security Team-Member) <chris.rebischke@archlinux.org>
uid           [ultimate] Christian Rebischke <Chris.Rebischke@posteo.de>
uid           [ultimate] Christian Rebischke <chris@shibumi.dev>
ssb>  rsa4096 2015-07-16 [E] [expires: 2020-06-25]
ssb>  rsa4096 2019-04-12 [A] [expires: 2020-06-25]
```

Archlinux.org provides already its own WKD server. This blog article is about providing a WKD server for the uid: `Christian Rebischke <chris@shibumi.dev>`.

First you want to generate your WKD hash for the key. You can do this via the following command:
`gpg --with-wkd-hash --fingerprint chris@shibumi.dev`

The output should look like this:

```
uid           [ultimate] Christian Rebischke <chris@shibumi.dev>
              qrq8871k9z8yxp9doyh415jnrooj7guc@shibumi.dev
```

Now you can create a directory structure on your webserver as follows:

`https://<your domain>/.well-known/openpgpkey/hu/<your WKD hash>`

For my uid `chris@shibumi.dev` this would look like this:

```
https://shibumi.dev/.well-known/openpgpkey/hu/qrq8871k9z8yxp9doyh415jnrooj7guc
```

The last part `qrq8871k9z8yxp9doyh415jnrooj7guc` is just your pubkey with the
filename: `qrq8871k9z8yxp9doyh415jnrooj7guc`. You can generate it via:

```
gpg --no-armor --export chris@shibumi.dev > qrq8871k9z8yxp9doyh415jnrooj7guc
```

For enabling the whole WKD server you need to place a `policy` file (this file
can be empty) in your `openpgpkey` directory. This looks for me as follows:

```
touch /srv/www/shibumi.dev/public/static/.well-known/openpgpkey/policy
```
You can check your setup via using this website:

[https://metacode.biz/openpgp/web-key-directory](https://metacode.biz/openpgp/web-key-directory)

This website may report other constraints:

* It reports if it can't access your key file
* It reports if the key format is invalid
* It reports if you have no policy file
* It reports if you don't set the application type: `application/octet-stream`.
* It reports wrong CORS headers (CORS: Cross-Origin Resource Sharing)

The last point is easy to achieve if you use Nginx or Apache. In Apache you can use the following snippet:

```apache
<Directory "/.well-known/openpgpkey">
   <IfModule mod_mime.c>
      ForceType application/octet-stream
      Header always set Access-Control-Allow-Origin "*"
   </IfModule>
</Directory>
```

In Nginx use this one:

```nginx
location ^~ /.well-known/openpgpkey {
   default_type application/octet-stream;
   add_header Access-Control-Allow-Origin * always;
}
```

Caddy v2 has no `always` parameter for headers yet. So you can just use the following snippet:
```
header /.well-known/openpgpkey/* {
	Content-Type application/octet-stream
	Access-Control-Allow-Origin *
}
```


