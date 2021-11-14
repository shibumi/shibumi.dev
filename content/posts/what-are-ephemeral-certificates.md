---
title: "What are ephemeral certificates?"
date: 2021-11-11T00:27:06+01:00
draft: false
description: "What are ephemeral certificates?"
toc: false
images:
tags: 
  - linux
  - devops
---

This article is a short followup to my [last article](/posts/first-look-into-cosign/) about [cosign](https://github.com/sigstore/cosign).
I received many questions for my last article. The most common one was:

"But wait! If the certificates are only valid for 30 minutes, how are my users supposed to validate my artifacts?"

This is very common misconception and to be honest: I ran into the same trap at first. The terms "ephemeral" or "short-lived"
do not refer to the signature validation. Instead, these terms refer to the certificate generation itself. The goal of short-lived
certificates is to elimate the possible risks of private key leaks. Just imagine, we have a traditional long-lived certificate
and a private key stored on one of our servers. If one attacker manages to steal this certificate and private key, maybe even years
after the signature creation, the attacker will be able to craft a valid signature for their own malware with this certificate and key.
With a short-lived certificate this would not be possible, because even if the attacker has access to both (private key and certificate)
the attacker will not be able to craft a valid signature for the artifact, because the certificate has expired. The users are still able
to validate the originally signed artifact, because the signature of this artifact has been created in the valid time frame of the certificate.

To proof my statement, we can have a look on the signature of my latest blog article. First let us print the current date:

```
$ date
Thu Nov 11 12:41:08 AM CET 2021
```

Then, let us create the artifact from my last article again. This is a simple "hello world" text file:

```
$ echo "hello world" > hello-world.txt
```

Next, we need the rekor transparency log of my last blog post. Feel free to manually check it. The used log index was: 832324.
With this log index we can download the used certificate and the signature for the artifact:

```
$ rekor-cli get --log-index 832324 --format json | jq -r '.Body.RekordObj.signature.content'  > hello-world.txt.sig
$ rekor-cli get --log-index 832324 --format json | jq -r '.Body.RekordObj.signature.publicKey.content' | base64 -d > pub.crt
```

If we have a closer look on this certificate with openssl we can see that the certificate was only valid for approximately 20 minutes:
```
$ openssl x509 -noout -text -in pub.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            7d:e3:2e:ad:8e:d0:c8:7d:c2:54:f8:c0:ba:10:8b:4b:58:9f:29
        Signature Algorithm: ecdsa-with-SHA384
        Issuer: O = sigstore.dev, CN = sigstore
        Validity
            Not Before: Nov  7 03:44:02 2021 GMT
            Not After : Nov  7 04:04:01 2021 GMT
```

The signing process happened in this timeframe. This is why our signature is valid:

```
$ COSIGN_EXPERIMENTAL=1 cosign verify-blob -cert pub.crt -signature hello-world.txt.sig hello-world.txt
No TUF root installed, using embedded CA certificate.
Certificate is trusted by Fulcio Root CA
Email: [chris@shibumi.dev]
Verified OK
tlog entry verified with uuid: "ee4b2e80cef72f8d4e3f00d695bd796ffd9e17b9cfd18ba96947493c4ee19f62" index: 832324
```

Awesome! We can just look up our past signatures via the rekor transparency log and use the signature + certificate to validate our artifact!
One possible usecase for this is: Ship your artifact + the public certificate + the signature to the user. Then, the user can
validate the artifact with the given public certificate and signature. For additional security, he can check the transparency log for the
given signature and certificate and validate if the certificate has been created by the correct OIDC identifier. In my case, this is my email. 

**Addition from the 14th November 2021**

A few people asked me if it would be possible to fake the system time for creating a signature with a stolen expired certificate.
This is indeed possible for offline verification, but cosign queries the rekor transparency log on default. The rekor transparency
log uses the time-stamp protocol (TSP), also known as [RFC3161](https://www.ietf.org/rfc/rfc3161.txt) for secure timestamps.
Therefore, it is highly recommended to verify all signatures against the rekor transparency log.
Cosign does this on default and cosign v1.3.1 even downloads the certificate from the transparency log on default.