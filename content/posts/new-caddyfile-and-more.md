---
title: "New Caddyfile and more"
date: 2020-02-26T12:18:37+01:00
draft: false
description: "In this article I write about SEO changes for my blog and changes on my Caddyfile"
---

I made a few significant changes on my blog. First, I have a new Caddyfile for Caddy:

```yaml
{
	experimental_http3
}

www.nullday.de, www.nspawn.org, www.shibumi.dev {
	redir * https://{http.request.host.labels.1}.{http.request.host.labels.0}{path}
}

nullday.de {
	redir * https://shibumi.dev{path}
}

nspawn.org, shibumi.dev {
	file_server
	root * /srv/www/{host}/public/
	header {
		Strict-Transport-Security "max-age=31536000; includeSubDomains; preload; always"
		Public-Key-Pins "pin-sha256=\"sRHdihwgkaib1P1gxX8HFszlD+7/gTfNvuAybgLPNis=\"; pin-sha256=\"YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg=\"; pin-sha256=\"C5+lpZ7tcVwmwQIMcRtPbsQtWLABXhQzejna0wHFr8M=\"; includeSubdomains; max-age=2629746;"
		X-Frame-Options "SAMEORIGIN"
		X-Content-Type-Options "nosniff"
		X-XSS-Protection "1; mode=block"
		Content-Security-Policy "default-src 'none'; base-uri 'self'; form-action 'none'; img-src 'self'; script-src 'self'; style-src 'self'; font-src 'self'; worker-src 'self'; object-src 'self'; media-src 'self'; frame-ancestors 'none'; manifest-src 'self'; connect-src 'self'"
		Referrer-Policy "strict-origin"
		Feature-Policy "geolocation 'none';midi 'none'; sync-xhr 'none';microphone 'none';camera 'none';magnetometer 'none';gyroscope 'none';speaker 'none';fullscreen 'self';payment 'none';"
		Expect-CT "max-age=604800"
	}
	header /.well-known/openpgpkey/* {
		Content-Type application/octet-stream
		Access-Control-Allow-Origin *
	}
	encode {
		zstd
		gzip
	}
}
```

The new Caddyfile enables experimental HTTP3 support. Also I've added a few
redirects to my new domain.  All www prefix requests get redirected to their
version without www prefix.  My old domain nullday.de redirects now to my new
domain shibumi.dev.  Also I had to add `connect-src 'self'` to my CSP, because
Google Lighthouse seems to have problems with `defalt-src 'none'`. If just
`default-src 'none'` is being set, Google Lighthouse can't access your
robots.txt. This seems to be an issue in the Google Lighthouse implementation,
the Google Search Bot is not affected. You can test your robots.txt via:

```javascript
await fetch(new URL('/robots.txt', location.href).href)
```

Feel free to follow this issue here:
[https://github.com/GoogleChrome/lighthouse/issues/4386](https://github.com/GoogleChrome/lighthouse/issues/4386)

The second change I has been adding a meta description for my blog and my blog
articles. As you might know, I use [hugo](https://gohugo.io/) as static site
generator and [Hermit](https://github.com/Track3/hermit) as Hugo theme. For
Hermit I have submitted a patch that should fix the meta description issue. It
looks as follows:

```diff
From 8b888604a401c60c2021c9dc771e20640a359baa Mon Sep 17 00:00:00 2001
From: Christian Rebischke <chris@shibumi.dev>
Date: Sun, 23 Feb 2020 22:48:16 +0100
Subject: [PATCH] add meta description for google lighthouse

---
 archetypes/default.md        | 1 +
 archetypes/posts.md          | 1 +
 layouts/_default/baseof.html | 1 +
 3 files changed, 3 insertions(+)

diff --git a/archetypes/default.md b/archetypes/default.md
index 63c1c63..c98b02a 100644
--- a/archetypes/default.md
+++ b/archetypes/default.md
@@ -2,6 +2,7 @@
 title: "{{ replace .Name "-" " " | title }}"
 date: {{ .Date }}
 draft: true
+description:
 comments: false
 images:
 ---
diff --git a/archetypes/posts.md b/archetypes/posts.md
index fe05261..cade919 100644
--- a/archetypes/posts.md
+++ b/archetypes/posts.md
@@ -2,6 +2,7 @@
 title: "{{ replace .Name "-" " " | title }}"
 date: {{ .Date }}
 draft: true
+description:
 toc: false
 images:
 tags: 
diff --git a/layouts/_default/baseof.html b/layouts/_default/baseof.html
index 7f09c90..9a8302f 100644
--- a/layouts/_default/baseof.html
+++ b/layouts/_default/baseof.html
@@ -9,6 +9,7 @@
 	<meta name="theme-color" content="{{.}}">
 	<meta name="msapplication-TileColor" content="{{.}}">
 	{{- end }}
+	<meta name="description" content="{{.Description | default .Site.Params.Description}}">
 	{{- partial "structured-data.html" . }}
 	{{- partial "favicons.html" }}
 	<title>{{.Title}}</title>
```

It adds a new `description` variable to all blog templates and adds the `<meta
name="description">` HTML tag to the base HTML file. It sets the websites
default description if no description has been set.  Feel free to have a look
on the PR status here:
[https://github.com/Track3/hermit/pull/121](https://github.com/Track3/hermit/pull/121)
