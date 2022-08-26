---
title: "Day in the life of a package maintainer: Reproducible Go packages"
date: 2022-08-24T17:30:12+02:00
draft: false
description: "Today, we want fix one non-reproducible Go package in Arch Linux"
toc: false
images:
tags:
  - linux
---

In this new blog series, I would like to introduce you to the daily adventures of an Arch Linux
package maintainer.

This time, we will have a look at reproducible package builds. Reproducible package builds are
very important for us, as package maintainers, because reproducible package builds create an independently-verifiable
path from source to the final package. This means, every Arch Linux user can verify that noone tampered with the
Arch Linux package build process. Technically spoken, this means that we can build the same package on different systems
and get an exact identical package (identical as in: they share the same SHA256 checksum).

At Arch Linux, we have an instance that automatically tries to reproduce every package we build. If a package is not reproducible
we are getting informed via mail and the package will be flagged on the Arch Linux website:

![https://archlinux.org/packages/community/x86_64/cosign/](/img/cosign-not-reproducible.png)


When we have identified a non reproducible package, we try to investigate the reason behind this and attempt to fix it.
First we download the package tarball and then we use our development tool `makerepropkg` to attempt to reproduce a given package.
`makerepropkg` downloads all packages with the exact version number that were necessary to build the given package tarball.
This ensures that we have the same build environment. After running `makerepropkg` another packate tarball will get created
and stored locally on our work machine.

Now, we can compare both packages via running `diffoscope` on them. `diffoscope` compares both archives for binary reproducibility.It does this via comparing files and metadata bit by bit. `diffoscope` returns a diff view of both archives, highlighting the differences:

```diff
--- cosign-1.10.1-2-x86_64.pkg.tar.zst
+++ /var/lib/archbuild/reproducible/chris/build/pkgdest/cosign-1.10.1-2-x86_64.pkg.tar.zst
├── cosign-1.10.1-2-x86_64.pkg.tar
│ ├── .MTREE
│ │ ├── .MTREE-content
│ │ │ -./usr/bin/cosign time=1661356248.0 size=68372464 md5digest=e0bb95d657084647718199fa6f9df48e sha256digest=8d92d291f338fa0b26534927e3bc98e78818df1127a08637e05f0bded1160663
│ │ │ +./usr/bin/cosign time=1661356248.0 size=68372464 md5digest=f2cf1351d8203110f7f165ec2124d14c sha256digest=edf97964206642911677711aef5352c6ba30f498057a09a056338a7cf85274b2
│ ├── usr/bin/cosign
│ │┄ File has been modified after NT_GNU_BUILD_ID has been applied.
│ │ │  Displaying notes found in: .note.gnu.build-id
│ │ │    Owner                Data size 	Description
│ │ │ -  GNU                  0x00000014	NT_GNU_BUILD_ID (unique build ID bitstring)	    Build ID: c2849cac6c9ffd3e4319ea6bd7e7a0939921717b
│ │ │ +  GNU                  0x00000014	NT_GNU_BUILD_ID (unique build ID bitstring)	    Build ID: 4c4f2c7126e4bf02fabc668a9ce1d3c445dd3353
│ │ │  Displaying notes found in: .note.go.buildid
│ │ │    Owner                Data size 	Description
│ │ │ -  Go                   0x00000053	GO BUILDID	   description data: 4a 64 79 44 6e 75 67 66 72 59 35 43 39 66 38 64 55 48 69 52 2f 44 71 62 70 7a 5a 61 47 4a 44 43 69 55 71 72 47 54 67 53 69 2f 62 56 62 4d 66 56 64 4b 63 6c 58 79 52 30 34 51 2d 78 71 46 2f 77 64 34 71 48 73 76 76 41 52 31 57 52 6f 70 5f 74 6b 76 57
│ │ │ +  Go                   0x00000053	GO BUILDID	   description data: 78 30 65 54 62 4c 6e 63 7a 41 5f 69 52 36 72 51 5f 79 39 39 2f 44 71 62 70 7a 5a 61 47 4a 44 43 69 55 71 72 47 54 67 53 69 2f 62 56 62 4d 66 56 64 4b 63 6c 58 79 52 30 34 51 2d 78 71 46 2f 73 57 73 61 4a 63 70 67 78 6e 47 4e 36 61 65 5f 42 58 41 43
│ │ ├── strings --all --bytes=8 {}
│ │ │ -JdyDnugfrY5C9f8dUHiR/DqbpzZaGJDCiUqrGTgSi/bVbMfVdKclXyR04Q-xqF/wd4qHsvvAR1WRop_tkvW
│ │ │ +x0eTbLnczA_iR6rQ_y99/DqbpzZaGJDCiUqrGTgSi/bVbMfVdKclXyR04Q-xqF/sWsaJcpgxnGN6ae_BXAC
```

The above `diffoscope` output is trimmed down to make it more readable, but it highlights one of the issues with the cosign binary.
In the `MTREE` file, we can clearly see that the checksums for cosign are different. This can be explained via the different GNU Build IDs
and the different Go BuildID. Moreover, there is a different string in each of the binaries. What is the Go BuildID? According to Filippo Valsorda
the build ID is "..a hash of the filenames of the compiled files, plus the version of the compiler (and other things in zversion.go, like the default GOROOT)".

The different build ID for every build seems to have something to do with the linker and the use of CGO.
At Arch Linux, we do not compile binaries statically, because of additional security features like FULL RELRO and PIE.
One solution to fix this issue is via building it statically, but this time we prefer to fix this via setting an empty build ID.
Be aware that setting an empty build ID will disable debug packages. I hope the Go team will fix this issue on the long run.
Let us use the following GOFLAGS line for the `cosign` package:

`export GOFLAGS="-buildmode=pie -trimpath -mod=readonly -modcacherw -ldflags=-linkmode=external -ldflags=-buildid=''"`

The last `ldflag` sets the build ID to an empty string. Now, we can rebuild the package and then run `makerepropkg` again:

`makerepropkg cosign-1.10.1-2-x86_64.pkg.tar.zst`

Voila! `makerepropkg` reports that the package is now reproducible:
```
...
==> Leaving fakeroot environment.
==> Finished making: cosign 1.10.1-2 (Wed Aug 24 18:35:43 2022)
  -> built succeeded! built packages can be found in /var/lib/archbuild/reproducible/chris/build/pkgdest
==> comparing artifacts...
  -> Package 'cosign-1.10.1-2-x86_64.pkg.tar.zst' successfully reproduced!
```
