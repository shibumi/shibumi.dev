---
title: "Google Summer of Code 2020"
date: 2020-08-08T16:40:20+02:00
draft: false
description:
tags:
 - linux
---

![in-toto logo](/img/in-toto-horizontal-color-white.png)

tl;dr Just give me the link to the PR: [https://github.com/in-toto/in-toto-golang/pull/56](https://github.com/in-toto/in-toto-golang/pull/56)


## Intro
This blog post tracks my accomplishments during my Google Summer of Code 2020 Stipend
at CNCF. I have spend around three months on working on [https://in-toto.io](https://in-toto.io).

For tracking I am using the goal-setting framework [OKR](https://en.wikipedia.org/wiki/OKR) (objectives and key results).
My main objective has been to implement in-toto-run functionality in the in-toto Go implementation. However, I have also fixed a few other issues
on this journey and [wrote a blog post about in-toto](https://shibumi.dev/posts/introduction-to-in-toto/). The blog post worked as my entrypoint into
the project. After reading the in-toto specification and creating a blog post I slowly climbed my way up to the main objective, while constantly
fixing minor issues I encountered on my way. This was a good experience for me, because I never donated code to such a big and important project.


## Objectives

### in-toto-run functionality (main objective)
In-toto-run functionality has been my main objective during the Google Summer of Code stipend.

* Objective description and key results: [https://github.com/in-toto/in-toto-golang/issues/54](https://github.com/in-toto/in-toto-golang/issues/54)
* Changelist (Pull-Request): [https://github.com/in-toto/in-toto-golang/pull/56](https://github.com/in-toto/in-toto-golang/pull/56)

### in-toto symlink functionality
When I have on-boarded on the project, the project had a few stalling CLs/PRs. Implementing symlink functionality was one of them.
Symlink functionality is necessary for handling symlinks while using the in-toto run functionality. Therefore, we have decided to
finish this CL/PR first:

* Objective description and key results: [https://github.com/in-toto/in-toto-golang/issues/32](https://github.com/in-toto/in-toto-golang/issues/32)
* Changelist (Pull-Request): [https://github.com/in-toto/in-toto-golang/pull/55](https://github.com/in-toto/in-toto-golang/pull/55)


### handling unhandled errors
While working on the objective `cleanup code indentation and multi-line comments` I got my eyes on a few unhandled errors.
I fixed these errors in a separate CL/PR:

* Objective description and key results: [https://github.com/in-toto/in-toto-golang/pull/52](https://github.com/in-toto/in-toto-golang/pull/52)
* Changelist (Pull-Request): [https://github.com/in-toto/in-toto-golang/pull/52](https://github.com/in-toto/in-toto-golang/pull/52)


### cleanup code indentation and multi-line comments
While reading the project code for the first time and setting up my IDE GoLand, I encountered a few warnings.
Therefore I have decided to clean this up before I start working on my main objective. This ensures I start with a clean code base.

* Objective description and key results: [https://github.com/in-toto/in-toto-golang/issues/18](https://github.com/in-toto/in-toto-golang/issues/18)
* Changelist (Pull-Request): [https://github.com/in-toto/in-toto-golang/pull/51](https://github.com/in-toto/in-toto-golang/pull/51)

### Fixing over-importing in the Python implementation
During one of my Slack sessions with my mentors, one contributor posted minor issues in the in-toto Python implementation.
These issues seem easy to fix, hence I embraced the opportunity and helped fixing these issues.

* Objective description and key results: [https://github.com/in-toto/in-toto/issues/378](https://github.com/in-toto/in-toto/issues/378)
* Changelist (Pull-Request): [https://github.com/in-toto/in-toto/pull/379](https://github.com/in-toto/in-toto/pull/379)

### Fixing inconsistencies in the in-toto specification
As preparation for my work I have read the in-toto specification. In the in-toto specification I have found a few minor issues.

* Objective description and key results: [https://github.com/in-toto/docs/pull/29](https://github.com/in-toto/docs/pull/29)
* Changelist (Pull-Request): [https://github.com/in-toto/docs/pull/29](https://github.com/in-toto/docs/pull/29)

This objective includes a minor CL/PR, that fixes a few backslashes: [https://github.com/in-toto/docs/pull/31](https://github.com/in-toto/docs/pull/31)

### Fixing wrong return values in the specification
When impleenting in-toto link file dumping/loading, I catched an inconsistency in the in-toto specification.
The implementation used JSON.INTEGERS as objects for the return-value of a command, while the specification
specified these return-values as strings.

* Objective description and key results: [https://github.com/in-toto/docs/pull/36](https://github.com/in-toto/docs/pull/36)
* Changelist (Pull-Request): [https://github.com/in-toto/docs/pull/36](https://github.com/in-toto/docs/pull/36)


## Additional contributions

The following section lists additional contributions I made. Additional
contributions are: opened issues or CL/PR reviews, that do not have a CL/PR yet, blog posts, etc.

### Issues

* [https://github.com/secure-systems-lab/securesystemslib/issues/251](https://github.com/secure-systems-lab/securesystemslib/issues/251)
* [https://github.com/in-toto/in-toto-golang/issues/64](https://github.com/in-toto/in-toto-golang/issues/64)
* [https://github.com/in-toto/in-toto-golang/issues/63](https://github.com/in-toto/in-toto-golang/issues/63)
* [https://github.com/in-toto/in-toto-golang/issues/61](https://github.com/in-toto/in-toto-golang/issues/61)
* [https://github.com/in-toto/in-toto-golang/issues/60](https://github.com/in-toto/in-toto-golang/issues/60)
* [https://github.com/in-toto/in-toto-golang/issues/57](https://github.com/in-toto/in-toto-golang/issues/57)

### CL/PR reviews

* [https://github.com/secure-systems-lab/securesystemslib/pull/262](https://github.com/secure-systems-lab/securesystemslib/pull/262)

### Blog posts

* [https://shibumi.dev/posts/introduction-to-in-toto/](https://shibumi.dev/posts/introduction-to-in-toto/)
