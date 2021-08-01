---
title: "Hardening Binaries"
date: 2021-08-01T21:40:03+02:00
draft: false
description:
tags:
 - linux
 - devops
 - ctf
---

Quite a while ago, Arch Linux has turned on many binary security features via
compilation flags (2016)[^1] or turned off options that are known to help
exploit software (debugging symbols, RPATH). Now we have 2021 and Arch Linux made good
experience with the additional security options.

We made good experience on Arch Linux with the following flags so far:

* FULL RELRO (Full Relocation Read-Only)[^2]
* STACK CANARY[^3]</sup>
* NX-Bit[^4]</sup>
* PIE (Position Independent Executable/Code)[^5]
* Setting no RPATH[^6]
* Setting no Symbols
* FORTIFY[^7]

Some of these flags are known to have effects on performance.
A 'call for assistance'[^8] in 2016 tried to measure these effects via running
different operations with binaries that have above flags enabled. The
project[^9] delivered good results[^10] and we decided to enable these flags.

For validating EFI binaries we use the tool checksec.sh.
The follows snippet shows the example output of `check-sec --file=/usr/bin/kubectl`
with kubectl version 1.21.3-1 on Arch Linux:

```
RELRO           STACK CANARY      NX            PIE             RPATH      RUNPATH      Symbols         FORTIFY Fortified       Fortifiable     FILE
Full RELRO      Canary found      NX enabled    PIE enabled     No RPATH   No RUNPATH   No Symbols        Yes   2               3               /usr/bin/kubectl
```

We achieved a fully hardened kubectl binary via the following methods:

1. We set CGO flags for passing enhanced security flags to the compiler:

```
export CGO_CPPFLAGS="${CPPFLAGS}"
export CGO_CFLAGS="${CFLAGS}"
export CGO_CXXFLAGS="${CXXFLAGS}"
export CGO_LDFLAGS="${LDFLAGS}"
```

These flags are:

* CPPFLAGS="-D_FORTIFY_SOURCE=2"
* CFLAGS="-march=x86-64 -mtune=generic -O2 -pipe -fno-plt"
* CXXFLAGS="-march=x86-64 -mtune=generic -O2 -pipe -fno-plt"
* LDFLAGS="-Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now"

2. We compile our Go packages with the following GOFLAGS:

```
export CGO_ENABLED=1
export GOFLAGS="-buildmode=pie -trimpath -mod=readonly -modcacherw"
export GOLDFLAGS="-linkmode=external"
```

Explanation for each flag:

* CGO_ENABLED needs to be set to 1 for most of the features.. this can make binary distribution problematic.
* -buildmode=pie enables PIE compilation for binary harderning.
* -trimpath important for Reproducible Builds so full build paths and module paths are not embedded.
* -mod=readonly ensure the module files are not updated in any go actions.
* -modcacherw is not important, but it ensures that go modules creates a write-able path. Default is read-only.
* -linkmode=external ensure we use an external linker, because the Go linker is not capable of all operations that are necessary.

Our full Go package guidelines can be found in our Wiki[^12]. This article has been heavily influenced by and partly copied from
an [issue in the CNCF/tag-security repository](https://github.com/cncf/tag-security/issues/422)

[^1]: https://lists.archlinux.org/pipermail/arch-dev-public/2016-October/028405.html
[^2]: https://www.redhat.com/en/blog/hardening-elf-binaries-using-relocation-read-only-relro
[^3]: https://en.wikipedia.org/wiki/Stack_buffer_overflow#Stack_canaries
[^4]: https://en.wikipedia.org/wiki/NX_bit
[^5]: https://en.wikipedia.org/wiki/Position-independent_code
[^6]: https://en.wikipedia.org/wiki/Rpath
[^7]: https://access.redhat.com/blogs/766093/posts/1976213
[^8]: https://www.archlinux.org/news/test-sec-flags-call-for-assistance/
[^9]: https://github.com/pid1/test-sec-flags
[^10]: https://github.com/pid1/test-sec-flags/wiki
[^11]: https://github.com/slimm609/checksec.sh
[^12]: https://wiki.archlinux.org/index.php/Go_package_guidelines#Flag_meaning
