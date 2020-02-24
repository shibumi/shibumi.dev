---
title: "Traefik BasicAuth"
date: 2019-12-05T22:47:59+01:00
draft: false
description: "How to setup basicAuth for Traefik"
---

In this short blog article we revisit traefik and add password authentication to our reverse proxy example.Password authentication means we use a (user,password) tuple for the login. We don't want to safe our password in clear text, therefore we need to encrypt it.

At this moment, traefik supports three hash algorithms: MD5, SHA1, BCrypt. Two of them are considered to be broken, hence you should use BCrypt:

```sh
$ htpasswd -nbB myName myPassword
myName:$2y$05$c4WoMPo3SXsafkva.HHa6uXQZWr7oboPiC2bT/r7q1BB8I2s0BRqC
```

Next you can stick the `basicAuth` middleware in front of your dashboard router.

```yaml
http:
  routers:
    api-router:
      rule: "PathPrefix(`/api`) || PathPrefix(`/dashboard`)"
      service: api@internal
      entryPoints:
        - web-secure
      tls: {}
      middlewares:
        - dashboard-login
middlewares:
  dashboard-login:
    basicAuth:
      users:
        - "myName:$2y$05$c4WoMPo3SXsafkva.HHa6uXQZWr7oboPiC2bT/r7q1BB8I2s0BRqC"
```
