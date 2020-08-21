---
title: "Google Summer of Code 2020"
date: 2020-08-08T16:40:20+02:00
draft: false
description:
tags:
 - linux
---

![in-toto logo](/img/in-toto-horizontal-color-white.png)

I spent the last three to four months working on the open source project [in-toto](https://in-toto.io) as part
of my Google Summer of Code stipend at the Cloud Native Computing Foundation (CNCF).
Followers of my blog might have read already about in-toto. If you do not know the project, I
suggest you have a look on my [introduction to in-toto](/posts/introduction-to-in-toto/).
The introduction article has been written as part of my Google Summer of Code stipend and gives
a good overview about the project and what its objectives are.

The main objective of my Google Summer of Code stipend has been to port in-toto run functionality
from the in-toto Python reference implementation to the Go implementation. The in-toto run functionality
is responsible for generating in-toto link data. In-toto links are files, that represent a step
in a software supply chain. Each of these steps can be signed and later verified.
Adding in-toto run functionality to the Go implementation has been tracked in the following Github issues:

*  [https://github.com/in-toto/in-toto-golang/issues/54](https://github.com/in-toto/in-toto-golang/issues/54)
*  [https://github.com/in-toto/in-toto-golang/issues/30](https://github.com/in-toto/in-toto-golang/issues/30)
*  [https://github.com/in-toto/in-toto-golang/issues/27](https://github.com/in-toto/in-toto-golang/issues/27)

The following key results must have been achieved:

* Signing generated link data via signature algorithms as specified in the [in-toto specification](https://github.com/in-toto/docs/blob/master/in-toto-spec.md)
* Full support for RSA-PSS, ED25519 and ECDSA.
* Generating link files

My merged pull request, that addresses these key results can be found here: [https://github.com/in-toto/in-toto-golang/pull/56](https://github.com/in-toto/in-toto-golang/pull/56)

During my journey I did a lot more than that. Implementing the above requirements lead us (my mentors and me) to a few other issues.
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

The in-toto Go implementation is in direct relationship to the [in-toto Python implementation](https://github.com/in-toto/in-toto) and the [in-toto specification](https://github.com/in-toto/docs/blob/master/in-toto-spec.md). Therefore it is not surprising, that I have also addressed a few inconsistencies
in the specification and the Python implementation.

* Fixing over-importing in the in-toto Python implementation:
	* Issue [#378](https://github.com/in-toto/in-toto/issues/378)
	* PR [#379](https://github.com/in-toto/in-toto/pull/379)
* Fixing key word inconsistencies in the in-toto specification:
	* PR [#29](https://github.com/in-toto/docs/pull/29)
* Fixing a wrong data type for the return-value in the in-toto specification:
	* PR [#36](https://github.com/in-toto/docs/pull/36)


Additionally, the following issues have been uncovered during the development process:

* key format inconsistency in securesystemslib: Issue [#251](https://github.com/secure-systems-lab/securesystemslib/issues/251)
* compare the way we store symlinks in our link metadata to the reference implementation: Issue [#57](https://github.com/in-toto/in-toto-golang/issues/57)
* Test clean up does not work due to deferring functions not being called: Issue [#60](https://github.com/in-toto/in-toto-golang/issues/60)
* Hardware Security Module (HSM) support: Issue [#61](https://github.com/in-toto/in-toto-golang/issues/61)
* Moving to Github Actions for CI: Issue [#62](https://github.com/in-toto/in-toto-golang/issues/62)
* Test interoperability with the Python implementation via subprocess calls: Issue [#63](https://github.com/in-toto/in-toto-golang/issues/63)
* Go 1.15 support: Issue [#64](https://github.com/in-toto/in-toto-golang/issues/64)
* ecdsa curve sanity checks: Issue [#65](https://github.com/in-toto/in-toto-golang/issues/65)
* subsetCheck function as part of our Set implementation: Issue [#66](https://github.com/in-toto/in-toto-golang/issues/66)
* ecdsa-sha2-nistp384 support: Issue [#67](https://github.com/in-toto/in-toto-golang/issues/67)
* validate functions, specifically key validations: Issue [#68](https://github.com/in-toto/in-toto-golang/issues/68)
* In-toto record functionality: Issue [#69](https://github.com/in-toto/in-toto-golang/issues/69)
* Do not share state in test functions: Issue [#71](https://github.com/in-toto/in-toto-golang/issues/71)
* Use Go Linter for CI: Issue [#74](https://github.com/in-toto/in-toto-golang/issues/74)

A few of these issues have first drafts, already. I have worked on this drafts during my Google Summer of Code stipend, too:

* [Move subsetCheck to Set Interface](https://github.com/in-toto/in-toto-golang/pull/73)
* [Add Github Actions Support](https://github.com/in-toto/in-toto-golang/pull/72)
* [Go 1.15 Support](https://github.com/in-toto/in-toto-golang/pull/70)

My plan is to address the other issues in the future, but more about this later.
