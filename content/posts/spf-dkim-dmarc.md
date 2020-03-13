---
title: "SPF, DKIM and DMARC"
date: 2020-03-13T16:14:28+01:00
draft: true
description: "How to configure your own domain with mailbox.org with respect to DKIM, DMARC and SPF"
tags:
  - linux
---

If you had a closer look on my domain you've might checked my MX records:

```
❯ resolvectl query -t mx shibumi.dev
shibumi.dev IN MX 10 mxext2.mailbox.org
shibumi.dev IN MX 10 mxext1.mailbox.org
shibumi.dev IN MX 20 mxext3.mailbox.org
```

Yes, I have to admit I don't host my own mail infrastructure.  I think this is
too toilsome and I have better things to do, like writing this blog article.

In this article I want to explain to you how I've configured the SPF, DKIM and
DMARC settings for my domain. This leads me to my first question: Why do I need
SPF, DKIM or DMARC at all?

It's dead simple. If I wouldn't have these settings (at least for SPF) big mail
providers would classify my mails as spam. So at least SPF is a must-have for me.

But what is SPF? SPF stands for *Sender Policy Framework*. It permits the
receiving mail infrastructure to detect forging of sender addresses. So it
makes sure that the mail comes from an IP address that is associated with the
domain mentioned in the mail's FROM header.

In relation to my domain, this means, that if I want to be able to send mails
via an external mail provider like mailbox.org with my own domain in the mail's
FROM header, I need to setup SPF. Otherwise other domains could classify my
mails as spam. This is how my SPF record looks like:

```
TXT v=spf1 include:mailbox.org ~all
```

For SPF you need to use the TXT DNS record. Then you simply specify the SPF
version via `v=spf1`.  For me a simple `include:mailbox.org ~all` is enough,
because I just want to include the SPF record of mailbox.org (my mail
provider). The `~all` mechanism is a test that always matches. The `~` operator
in front of the all specifies a *softfail*. The [SPF
RFC](https://tools.ietf.org/html/rfc7208#section-5.1) says about *softfail* the
following:

> A "softfail" result is a weak statement by the publishing ADMD that
> the host is probably not authorized.  It has not published a
> stronger, more definitive policy that results in a "fail".

NOTE: ADMD means Administrative Management Domain.

So a *softfail* means that mails can be allowed through, but should be tagged
as spam or suspicious.  I have been unsure about this and I thought about it a
lot. But after a closer look on how other mail providers are handling this I
have decided to use the `~` operator instead of `-`. `-` would be a strict
handling of mails. If you want to know the other operators, have a look on the
excellent RFC.

You may ask yourself now: 'OK, you are doing an include, but how is mailbox.org doing'?
We can have a look at mailbox's SPF record:

```
❯ resolvectl query -t txt mailbox.org
mailbox.org IN TXT "v=spf1 ip4:213.203.238.0/25 ip4:195.10.208.0/24 ip4:91.198.250.0/24 ip4:80.241.56.0/21 ip6:2001:67c:2050::/48  mx ~all
```

This SPF record is a little bit more difficult to read, but let's examine it.
The `ip4` mechanism are specifying IPv4 ranges. Mails that come from these ranges are considered valid.
The `mx` mechanism automatically approves the mailbox.org mail servers specified in the MX DNS record.

SPF is a little bit difficult to understand at beginning. If you have more questions don't hesitate to have a look on the RFC or at some other blog articles. I can totally recommend this one here:

[https://postmarkapp.com/blog/explaining-spf](https://postmarkapp.com/blog/explaining-spf)

Let's talk about DKIM next. DKIM stands for *DomainKeys Identified Mail*.  DKIM
tries to achieve the same as SPF. It tries to help validating mails.  The
difference with DKIM is that DKIM does this via attaching a digital signature,
linked to a domain name, to every outgoing mail message. So instead of relying
on a remote SPF record, we are adding another cryptographic layer here.

For DKIM I am just using the standard mailbox.org public key. You can find that key here: [https://kb.mailbox.org/display/MBOKBEN/Using+e-mail+addresses+of+your+domain](https://kb.mailbox.org/display/MBOKBEN/Using+e-mail+addresses+of+your+domain).

The DKIM DNS record looks like this:

```
MBO0001._domainkey TXT v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2K4PavXoNY8eGK2u61LIQlOHS8f5sWsCK5b+HMOfo0M+aNHwfqlVdzi/IwmYnuDKuXYuCllrgnxZ4fG4yVaux58v9grVsFHdzdjPlAQfp5rkiETYpCMZwgsmdseJ4CoZaosPHLjPumFE/Ua2WAQQljnunsM9TONM9L6KxrO9t5IISD1XtJb0bq1lVI/e72k3mnPd/q77qzhTDmwN4TSNJZN8sxzUJx9HNSMRRoEIHSDLTIJUK+Up8IeCx0B7CiOzG5w/cHyZ3AM5V8lkqBaTDK46AwTkTVGJf59QxUZArG3FEH5vy9HzDmy0tGG+053/x4RqkhqMg5/ClDm+lpZqWwIDAQAB
```

The record consists of the host name `MB00001._domainkey` and the attribute field with the DKIM version, the used crypto algorithm (`k=rsa`) and the public key. If you want to learn more, I can recommend this blog article here: [https://help.returnpath.com/hc/en-us/articles/222438487-DKIM-signature-header-detail](https://help.returnpath.com/hc/en-us/articles/222438487-DKIM-signature-header-detail)

So, now we that we have DKIM and SPF, we can have a look at DMARC
(*Domain-based Message Authentication, Reporting and Conformance*). DMARC is
nice addition to DKIM and SPF, because with DMARC we can publish a policy that
recommends how other mail servers should treat our incoming mails. Moreover we
are even able to get reports. This is useful for debugging. My DMARC DNS record
looks like this:

```
_dmarc TXT v=DMARC1; p=none; sp=quarantine; rua=mailto:postmaster@shibumi.dev
```

It will match on the domain: `_dmarc.shibumi.dev` and specifies the following
attributes for DMARC:

* The version as specified in `v=`
* `p` is the policy for the domain. In this case `none`, so our mails should go
  through.
* `sp` is the policy for subdomains. I chose `quanrantine` here, because I
  don't plan to send mails from a subdomain. If you want to be more strict, you
  can choose `reject` instead of `quanrantine`. `quarantine` will suggest mail
  servers to move mails from subdomains of your domain to the spam folder.
  `rua` specifies the reporting URI for aggregate reports (this is nice for
  debugging). If you want even more information you can also send the `ruf`
  attribute for forensic reports. If you want to know more, have a look at:
  [https://dmarc.org/overview/](https://dmarc.org/overview/)

  So that's it. This article got a little bit longer when I've planned it. If
  you have further questions, feel free to write me an email. You should
  definitely have a look on the corresponding RFCs and the linked blog
  articles. They helped me in understanding all of this.
