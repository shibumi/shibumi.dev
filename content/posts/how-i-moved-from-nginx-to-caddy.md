---
title: "How I moved from Nginx to Caddy"
date: 2020-01-18T12:57:34+01:00
draft: false
description: "How to move your nginx webserver configuration to a more modern webserver called caddy. Caddy has several advantages like automated TLS"
---

Nginx has been my webserver of choice for several years now. But I had always
some issues with nginx that bothered me for quite a while:

* Weak defaults (no TLS on default, weak ciphers, no OSCP stapling on default, ...)
* The configuration is very verbose (this doesn't need to be something bad)
* New technologies like (QUIC or zstd compression need ages until their are available in downstream)
* Dealing with Let's Encrypt / certificates has always been an error-prone process (I never got that working for a longer period of time without issues).


Let me show you how complex an Nginx configuration can get for something as simple as serving two static websites with sane TLS configuration. If we have a look on the **tls.conf**, there are many things I would expect from a webserver to be default in the year 2020. First there are the `ssl_protocols`, second there are the `ssl_ciphers` and `ssl_ecdh_curve`, third there is `ssl_stapling`. I expect all of these to be enabled on default and neither Nginx nor Apache do this with standard settings.

**/etc/nginx/tls.conf:**
```nginx
ssl_protocols  TLSv1.2 TLSv1.3;
ssl_certificate      cert.pem;
ssl_certificate_key  key.pem;
ssl_session_cache    shared:SSL:1m;
ssl_session_timeout  5m;
ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
ssl_ecdh_curve secp384r1;
ssl_session_tickets off;
ssl_prefer_server_ciphers  off;
ssl_early_data on;
proxy_set_header Early-Data $ssl_early_data;
ssl_dhparam /etc/nginx/dhparam.pem;
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
add_header Public-Key-Pins 'pin-sha256="sRHdihwgkaib1P1gxX8HFszlD+7/gTfNvuAybgLPNis="; pin-sha256="YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg="; pin-sha256="C5+lpZ7tcVwmwQIMcRtPbsQtWLABXhQzejna0wHFr8M="; max-age=2629746;';
add_header X-Frame-Options "SAMEORIGIN";
add_header X-Content-Type-Options "nosniff";
add_header X-XSS-Protection "1; mode=block";
add_header Content-Security-Policy "default-src 'none'; base-uri 'self'; form-action 'none'; img-src 'self'; script-src 'self'; style-src 'self'; font-src 'self'; worker-src 'self'; object-src 'self'; media-src 'self'; frame-ancestors 'none'; manifest-src 'self'; report-uri https://shibumi.report-uri.com/r/d/csp/enforce";
add_header Referrer-Policy "strict-origin";
add_header Feature-Policy "geolocation 'none';midi 'none'; sync-xhr 'none';microphone 'none';camera 'none';magnetometer 'none';gyroscope 'none';speaker 'none';fullscreen 'self';payment 'none';";
add_header Expect-CT "max-age=604800";
ssl_stapling on;
ssl_stapling_verify on;
ssl_trusted_certificate /etc/nginx/isrg-root-ocsp-x1.pem;
```

The actual website configuration is very verbose, too. I need to configure a redirect for every specific domain for port 80 to 443. Furthermore, I need to explicitly enable `http2` (quite ironic if you ask me, if you know that `http3` has been published already). Another problem is setting a directory for the `ACME` challenges manually (I know that there are modules for nginx for this, but I never really tested it, because I always had the feeling that it's too much hassle). The configuration for the second website is the same, just substitute the server names and directories.

**/etc/nginx/conf.d/nullday.de.conf**
```nginx
server {
    listen       80;
    listen	[::]:80;
    server_name  nullday.de kurisu.nullday.de www.nullday.de;
    return 301 https://nullday.de;
}
server {
    listen       443 ssl http2;
    listen	[::]:443 ssl http2;
    server_name  nullday.de kurisu.nullday.de www.nullday.de;
    server_tokens off;
    root /usr/share/nginx/html/nullday.de/public/;
    location / {
	    index  index.html;
    }
    location ^~ /.well-known/acme-challenge/ {
    	default_type "text/plain";
    	root /usr/share/nginx/html/letsencrypt;
    }
    # Expire rules for static content

    # cache.appcache, your document html and data
    location ~* \.(?:manifest|appcache|html?|xml|json)$ {
      expires -1;
    }
    
    # Feed
    location ~* \.(?:rss|atom)$ {
      expires 1h;
      add_header Cache-Control "public";
    }
    
    # Media: images, icons, video, audio, HTC
    location ~* \.(?:jpg|jpeg|gif|png|ico|cur|gz|svg|svgz|mp4|ogg|ogv|webm|htc)$ {
      expires 1M;
      add_header Cache-Control "public";
    }
    
    # CSS and Javascript
    location ~* \.(?:css|js|woff2|woff)$ {
      expires 1y;
      add_header Cache-Control "public";
    }
    include /etc/nginx/ssl.conf;
}
```

I think you agree with me, that Nginx is a monster regarding sane defaults and supporting state of the art technologies like `QUIC` or `ACME`. Therefore I've decided to switch to Caddy (to be more accurate: the beta of Caddy2). With Caddy I've been able to shrink the configuration, get support for `QUIC` and use Caddys internal `ACME` implementation for renewing my certificates. Let's have a look on the configuration:

**/etc/caddy/Caddyfile:**
```yaml

# This rule matches on www.nullday.de and www.nspawn.org and strips off the www
# part. I need this for Hugo (my static website generator). Otherwise Hugo will
# generate wrong sitemap.xml files. You might ask your self what {http.request.host.labels.1} mean.
# These are templates. This way you can access various internal Caddy variables.
# For example the host name in the incoming HTTP request.
www.nullday.de, www.nspawn.org {
	redir * https://{http.request.host.labels.1}.{http.request.host.labels.0}{path}
}


# This part is the actual server configuration. I match on my domains nullday.de and nnspawn.org.
# First I activate the file_server for serving static files.
nullday.de, nspawn.org {
	file_server
	# Here I use Caddys templates again to set the right path for the website.
	root * /srv/www/{http.request.host}/public/
	# And here I set all headers, that Caddy doesn't set on default.
	# TLS settings are not necessary, because Caddy has strong TLS defaults.
	headers {
		Strict-Transport-Security "max-age=31536000; includeSubDomains; preload; always"
		Public-Key-Pins "pin-sha256=\"sRHdihwgkaib1P1gxX8HFszlD+7/gTfNvuAybgLPNis=\"; pin-sha256=\"YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg=\"; pin-sha256=\"C5+lpZ7tcVwmwQIMcRtPbsQtWLABXhQzejna0wHFr8M=\"; includeSubdomains; max-age=2629746;"
		X-Frame-Options "SAMEORIGIN"
		X-Content-Type-Options "nosniff"
		X-XSS-Protection "1; mode=block"
		Content-Security-Policy "default-src 'none'; base-uri 'self'; form-action 'none'; img-src 'self'; script-src 'self'; style-src 'self'; font-src 'self'; worker-src 'self'; object-src 'self'; media-src 'self'; frame-ancestors 'none'; manifest-src 'self'"
		Referrer-Policy "strict-origin"
		Feature-Policy "geolocation 'none';midi 'none'; sync-xhr 'none';microphone 'none';camera 'none';magnetometer 'none';gyroscope 'none';speaker 'none';fullscreen 'self';payment 'none';"
		Expect-CT "max-age=604800"
	}
	# Lastly we just enable zstd and gzip compression.
	# Note: zstd compression is not yet supported by browsers.
	# You may ask yourself why I don't enable brotli.
	# The brotli impementation in caddy performs surprisingly bad.
	# I hope the caddy devs are going to fix this..
	encode {
		zstd
		gzip
	}
}
```
