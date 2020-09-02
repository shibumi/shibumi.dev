---
title: "Google Summer of Code 2020"
date: 2020-08-31T02:03:00+02:00
draft: false
description:
tags:
 - linux
---

![in-toto logo](/img/in-toto-horizontal-color-white.png)

## Intro

I spent the last three to four months working on the open source project [in-toto](https://in-toto.io) as part
of my Google Summer of Code stipend at the Cloud Native Computing Foundation (CNCF).
Followers of my blog might have already read about in-toto. If you do not know the project, I
suggest you have a look on my [introduction to in-toto](/posts/introduction-to-in-toto/).
The introduction article has been written as part of my Google Summer of Code stipend and gives
a good overview about the project and what its objectives are.

## My challenge

The main objective of my Google Summer of Code stipend has been to port in-toto run functionality
from the in-toto Python reference implementation to the Go implementation. The in-toto run functionality
is responsible for generating in-toto link data. In-toto links are files, that represent a step
in a software supply chain. Each of these steps can be signed and later verified.
Adding in-toto run functionality to the Go implementation has been tracked in the following Github issues:

*  [https://github.com/in-toto/in-toto-golang/issues/54](https://github.com/in-toto/in-toto-golang/issues/54)
*  [https://github.com/in-toto/in-toto-golang/issues/30](https://github.com/in-toto/in-toto-golang/issues/30)
*  [https://github.com/in-toto/in-toto-golang/issues/27](https://github.com/in-toto/in-toto-golang/issues/27)

The following key results were to be achieved:

* Signing generated link data via signature algorithms as specified in the [in-toto specification](https://github.com/in-toto/docs/blob/master/in-toto-spec.md)
* Full support for RSA-PSS, ED25519 and ECDSA.
* Generating link files

My merged pull request, that addresses these key results can be found here: [https://github.com/in-toto/in-toto-golang/pull/56](https://github.com/in-toto/in-toto-golang/pull/56)

During my journey I did a lot more than that. Implementing the above requirements led us (my mentors and me) to a few other issues.
These issues were so significant that we decided to solve these issues, while working on the actual in-toto run implementation.
The following listing shall give a brief insight on what I have worked on additionally.

* Cleanup code indentation and multi-line comments:
	* Issue [#18](https://github.com/in-toto/in-toto-golang/issues/18)
	* PR [#51](https://github.com/in-toto/in-toto-golang/pull/51)
* Handling unhandled errors:
	* PR [#52](https://github.com/in-toto/in-toto-golang/pull/52)
* Reviving the in-toto symlink functionality PR and finishing it (this was a dependency for our in-toto run functionality):
	* Issue [#32](https://github.com/in-toto/in-toto-golang/issues/32)
	* PR [#55](https://github.com/in-toto/in-toto-golang/pull/55)
* Handling excess data returned by `pem.Decode`:
	* Issue [#14](https://github.com/in-toto/in-toto-golang/issues/14)
	* PR (fixied within the main objective PR [#56](https://github.com/in-toto/in-toto-golang/pull/56))
* Keeping OS interoperability via using the decoded PEM block, instead of raw PEM bytes:
	* Issue [#75](https://github.com/in-toto/in-toto-golang/issues/75)
	* PR [#76](https://github.com/in-toto/in-toto-golang/pull/76)

The in-toto Go implementation is in direct relationship to the [in-toto Python implementation](https://github.com/in-toto/in-toto) and the [in-toto specification](https://github.com/in-toto/docs/blob/master/in-toto-spec.md). Therefore it is not surprising, that I have also addressed a few inconsistencies
in the specification and the Python implementation.

* Fixing over-importing in the in-toto Python implementation:
	* Issue [#378](https://github.com/in-toto/in-toto/issues/378)
	* PR [#379](https://github.com/in-toto/in-toto/pull/379)
* Fixing key word inconsistencies in the in-toto specification:
	* PR [#29](https://github.com/in-toto/docs/pull/29)
* Fixing a wrong data type for the return-value in the in-toto specification:
	* PR [#36](https://github.com/in-toto/docs/pull/36)

## Additional work

Additionally, the following issues have been uncovered during the development process:

* key format inconsistency in securesystemslib: Issue [#251](https://github.com/secure-systems-lab/securesystemslib/issues/251)
* compare the way we store symlinks in our link metadata to the reference implementation: Issue [#57](https://github.com/in-toto/in-toto-golang/issues/57)
* Hardware Security Module (HSM) support: Issue [#61](https://github.com/in-toto/in-toto-golang/issues/61)
* Test interoperability with the Python implementation via subprocess calls: Issue [#63](https://github.com/in-toto/in-toto-golang/issues/63)
* ecdsa curve sanity checks: Issue [#65](https://github.com/in-toto/in-toto-golang/issues/65)
* validate functions, specifically key validations: Issue [#68](https://github.com/in-toto/in-toto-golang/issues/68)
* In-toto record functionality: Issue [#69](https://github.com/in-toto/in-toto-golang/issues/69)
* Do not share state in test functions: Issue [#71](https://github.com/in-toto/in-toto-golang/issues/71)
* Use Go Linter for CI: Issue [#74](https://github.com/in-toto/in-toto-golang/issues/74)

These issues are already fixed or are on the verge of being fixed:

* Moving our subSetCheck function to the utils.Set interface
	* Issue [#66](https://github.com/in-toto/in-toto-golang/issues/66)
	* PR [#73](https://github.com/in-toto/in-toto-golang/pull/73)
* Support for Go 1.15 (moving to ecdsa.SignASN1 + fixing testMain)
	* Issue [#60](https://github.com/in-toto/in-toto-golang/issues/60) and [#64](https://github.com/in-toto/in-toto-golang/issues/64)
	* PR (not merged yet) [#70](https://github.com/in-toto/in-toto-golang/pull/70)
* Add Logo + fix Readme (because who does not like fancy logos?!)
	* PR [#77](https://github.com/in-toto/in-toto-golang/pull/77)
* Add Github Actions support
	* Issue [#62](https://github.com/in-toto/in-toto-golang/issues/62)
	* PR (not merged yet) [#72](https://github.com/in-toto/in-toto-golang/pull/72)
* Implement multi hash support
	* Issue [#31](https://github.com/in-toto/in-toto-golang/issues/31) and [#67](https://github.com/in-toto/in-toto-golang/issues/67)
	* PR (draft) [#78](https://github.com/in-toto/in-toto-golang/pull/78)
* Gitignore like exclude patterns
	* Issue [#33](https://github.com/in-toto/in-toto-golang/issues/33)
	* PR (draft) [#53](https://github.com/in-toto/in-toto-golang/pull/53)

## My personal highlights

During the Google Summer of Code my personal highlights were [finding and submitting a patch for a tiny bug in Go's crypto/rsa library](https://go-review.googlesource.com/c/go/+/240008) and attending the Kubecon 2020.

## What did I learn?

During Google Summer of Code I had a lot of fun working on the CNCF project
in-toto, but did I also learn something? The answer is clearly **yes**.  Before
Google Summer of Code I have contributed already to open source projects, but
these contributions were mostly small bug fixes, reporting bugs or my very
system and security focused work at Arch Linux.  It has been a dream since long
to contribute more than just a few lines of code to a project, but in the past
I had difficulties to get into such a project. The Google Summer of Code was my
first successful try to deep-dive into a foreign code base and to contribute
more than just a few lines of code. This experience definitely increased my
skills in reading foreign code, getting faster familiar with a foreign
code-base and communicating with project developers. Furthermore, in-toto
challenged my security skills and lead to a much wider understanding of signing
algorithms such like ED25519, RSA-PSS or ECDSA and key formats such like PKCS1,
PKCS8 or PEM. This project increased my security awareness in terms of
cryptography significantly.

## Plans for the future

Well, I think I totally fell in love with the project. Not only did I never
join such a welcoming and interesting community, I also finally found a
project that I think is important, interesting and challenging at the same
time. Moreover I really think, that my future career goals will come one step
closer with this project. The Go implementation and the near to the CNCF will
definitely help me in increasing my Site Reliability Skills.

## Special thanks

I do not want to finish, before honouring my four mentors Lukas Pühringer,
Justin Cappos, Santiago Torres-Arias and Trishank Karthik Kuppusamy. They
always reacted quickly when needed and they always gave me the right hints,
when I had difficulties understanding the specification or the code base.
Especially the work with Lukas was very enjoyable and I look forward to a lot
more interesting discussions in future pull requests and issues. Santiago has
been always there for me, when I did a few hours too much and slipped into a
different timezone. The timezone difference was definitely a bonus and not a
malus this time. Trishank was a person I could always count on. He supported me
in many ways and gave me hints when I have encountered a problem. Furthermore
we had a few interesting discussions around the in-toto specification, the
securesystemslib and their relationship to TUF. I am pretty sure, this will be
not the last discussions we had about the in-toto specification.
