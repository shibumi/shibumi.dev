---
title: "Fix PDF Display on Chrome"
date: 2020-05-19T15:55:30+02:00
draft: false
description: "How to fix PDF display issues with Chrome"
tags:
 - linux
---

For many months I had a weird issue with displaying PDFs in chrome on my website.
I always thought this is a browser issue and would be fixed soon, but actually it was
an issue with my Content Security Policy (CSP).

If you ever stumbled upon my CV you might have looked on this:

![screenshot of the PDF, that is not displayed correctly](/img/pdf-issue.png)

Finally I could fix this, after finding this Chrome issue here:

[https://bugs.chromium.org/p/chromium/issues/detail?id=271452](https://bugs.chromium.org/p/chromium/issues/detail?id=271452)


The problem got triggered via my strong CSP. I am setting `style-src 'self'`
and `object-src 'self'` on default.  These CSP settings are altering the
injected CSS by Chrome/Chromium and therefore the PDF content viewer will not
work like it should do. The solution for now is setting `unsafe-inline` for both
CSP settings. However this leads to the problem that I do not want to set this
for my whole website, because it is surprisingly unsafe. Thus
I have been playing around with my Caddyfile and came up with a solution that I am
quite happy with. I am using a pdf matcher now. If you are not familiar with matchers in Caddy,
then you should have a look on this documentation:

[https://caddyserver.com/docs/caddyfile/concepts#matchers](https://caddyserver.com/docs/caddyfile/concepts#matchers)

Matchers are basically like regex for your webserver. You can match on a specific path and apply specific settings
for this path only. Consequently I can apply an unsafe CSP setting for PDF files only via matching on all PDF files:

```yaml
@pdf {
	path *.pdf
}
```

Be aware, that a matcher needs to be placed in the related server block. Global matchers are not possible right now.
For applying the matcher you can use the same syntax as first argument to a new header block:

```yaml
header @pdf {
	Content-Security-Policy "default-src 'none'; base-uri 'self'; form-action 'none'; img-src 'self'; script-src 'self'; style-src 'unsafe-inline'; font-src 'self'; worker-src 'self'; object-src 'unsafe-inline'; media-src 'self'; frame-ancestors 'none'; manifest-src 'self'; connect-src 'self'"
}
```

With this header I am setting a new CSP header with updated `object-src` and `style-src` settings.
}
