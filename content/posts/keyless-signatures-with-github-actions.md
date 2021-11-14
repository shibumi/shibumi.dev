---
title: "Keyless signatures with Github Actions"
date: 2021-11-13T23:16:16+01:00
draft: false
description: "Keyless signatures with Github Actions and GoReleaser"
toc: false
images:
tags: 
  - linux
  - devops
---

As Arch Linux package maintainer I heavily rely on a secure upstream and a secure source code distribution process.
I have spent days or maybe even weeks discussing with maintainers why I rely on a secure upstream
and how important signatures on tags, commits or source tarballs are. Many maintainers have started signing
their source tarballs after such a discussion, others mentioned problems with their PGP keys and a minority
saw signing their source tarballs as waste of time.

This article is for every maintainer out there that has trouble with setting up PGP. We all know
that setting up PGP is painful and incredibly difficult to do right, especially when aiming for automated
build pipelines instead of a manual release process with human interaction. Several times, maintainers
forgot the password for their PGP key, lost their PGP key or just changed it, very often without knowing
the implications of these incidents for their downstream. After these incidents, many maintainers stopped
signing their source tarballs at all, because they estimated the process as too difficult and toilsome to maintain.
Altogether, PGP (especially GnuPG) is a horrific software we rely on and it is surprising that nobody tried to
fix this over the last years. Until now...


Today, I would like to present a new process for releasing source tarballs (and any other binary large object) on Github, fully automated on Github Actions
and fully keyless. The little secret behind this new process is the new sigstore stack. If you are a continuous reader of my articles you might read about
[ephemeral keys](/posts/what-are-ephemeral-certificates) or [keyless signatures for blobs](/posts/first-look-into-cosign). Cosign's new version [v1.3.1](https://github.com/sigstore/cosign/releases/tag/v1.3.1) got a little new feature, that makes verifying these source tarballs or blobs much easier. With cosign v1.3.1, cosign is able to download the public certificate from the public
rekor instance (the transparency log, comparable to [crt.sh](https://crt.sh/) just for signatures) automatically. The user just has to provide the artifact and the signature.
I have already prepared a new release of my diceware-alike password generator [mnemonic](https://github.com/shibumi/mnemonic). It is one of my first Go projects, hence the code base kind of sucks, but it is a good example for
presenting the process. If you download the newest version and verify it with cosign v1.3.1 you will see this:

```
$ COSIGN_EXPERIMENTAL=1  cosign verify-blob mnemonic-0.3.1.tar.gz --signature mnemonic-0.3.1.tar.gz.sig
Certificate is trusted by Fulcio Root CA
Email: []
Verified OK
tlog entry verified with uuid: "228527476f82c59641e27b8fb9b32f5fadbe47cf42c544ea97dc798490c4c14e" index: 853327
```

Sadly, cosign does not show all information in the public certificate. The email field is empty, because the certificate pair was not created via the OIDC issuer ([like in my first blog article
about cosign](/posts/first-look-into-cosign)). Instead, the ephemeral certificate key pair has been created through the workload identity Github Actions. Feel free to verify this via downloading
the public certificate and inspecting it with openssl:
```
$ rekor-cli get --uuid 228527476f82c59641e27b8fb9b32f5fadbe47cf42c544ea97dc798490c4c14e --format json | jq -r '.Body.RekordObj.signature.publicKey.content' | base64 -d > pub.crt
$ openssl x509 -noout -text -in pub.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            5e:70:0d:3d:19:66:85:d7:1d:00:41:b8:9f:74:8c:39:ed:bf:d2
        Signature Algorithm: ecdsa-with-SHA384
        Issuer: O = sigstore.dev, CN = sigstore
        Validity
            Not Before: Nov 13 22:11:53 2021 GMT
            Not After : Nov 13 22:31:52 2021 GMT
        Subject:
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:67:4c:43:f5:e1:04:c5:20:ec:f9:28:c0:bf:80:
                    1c:ce:08:5e:f8:14:5d:88:93:50:be:b0:d8:1a:77:
                    aa:8b:16:f6:d4:ca:bb:7a:2c:f2:22:15:22:6c:83:
                    18:37:13:db:31:0b:ca:13:ba:a5:d6:34:9b:85:cc:
                    6e:21:2b:3a:b6
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature
            X509v3 Extended Key Usage:
                Code Signing
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier:
                08:24:98:BE:E1:A6:99:E7:06:D0:1C:F8:38:5C:87:0D:7D:3B:C6:13
            X509v3 Authority Key Identifier:
                keyid:C8:C5:1D:00:41:9A:24:29:32:51:24:EB:0D:AE:4A:ED:4A:06:D3:EC

            Authority Information Access:
                CA Issuers - URI:http://privateca-content-603fe7e7-0000-2227-bf75-f4f5e80d2954.storage.googleapis.com/ca36a1e96242b9fcb146/ca.crt

            X509v3 Subject Alternative Name: critical
                URI:https://github.com/shibumi/mnemonic/.github/workflows/goreleaser.yml@refs/tags/v0.3.1
            1.3.6.1.4.1.57264.1.1:
                https://token.actions.githubusercontent.com
    Signature Algorithm: ecdsa-with-SHA384
         30:65:02:31:00:94:ff:ce:4e:c5:be:ee:29:01:de:0f:7a:9e:
         d1:fd:0a:c3:22:54:c3:a5:17:1c:8c:d2:8d:e6:88:20:1c:67:
         c9:dd:a8:fd:cc:d5:ac:39:1e:3a:d0:b4:24:c2:5a:5a:b7:02:
         30:5c:74:86:87:bc:5d:e3:5a:b7:49:98:17:9e:1a:e5:8c:ce:
         0a:3f:fb:f8:4b:50:67:e2:16:f4:41:0f:9c:7e:66:22:8d:3a:
         0b:a2:9b:45:3d:9f:80:fc:f7:d6:31:6c:fd
```

The interesting part is the subject alternative URI. It is this URI that will show you that the identity of this signature is connected to the github actions workflow
for my repository at the specific tag v0.3.1.

So much about the verification part. Now let us have a look on how to do this. You just need two files for replicating this behavior and I am confident this should work
with every programming language. GoReleaser can just build go binaries, but what stops us from using GoReleaser just for the sake of creating and signing source tarballs?
The benefit is that the github workflows file is pretty much the same for every project. Let us have a look on the .goreleaser.yaml file first:

```yaml
project_name: mnemonic
builds:
  - ldflags:
      - "-s -w"
      - "-extldflags=-zrelro"
      - "-extldflags=-znow"
      - "-X main.version={{.Version}}"
      - "-X main.commit={{.FullCommit}}"
      - "-X main.date={{.CommitDate}}"
    env:
      - "CGO_ENABLED=0"
      - "GO111MODULE=on"
      - "GOFLAGS=-mod=readonly -trimpath"
    goos:
      - linux
    goarch:
      - amd64
    main: .
source:
  enabled: true
signs:
  - cmd: cosign
    signature: "${artifact}.sig"
    args: ["sign-blob", "--oidc-issuer=https://token.actions.githubusercontent.com", "--output=${signature}", "${artifact}"]
    artifacts: all
```

The lines on top are all Go specific. Important for us are the last lines. With `source.enabled: true` we are activating the source tarball creation in GoReleaser.
The signing magic happens in `signs.args`. With the flag `--oidc-issuer` we are commanding cosign to use the Github Actions workload identity. This line works
fully independently. **You do not need to create a key pair, secure it, load it via Github Secrets or creating it on the fly in the pipeline itself**.
The pipeline's identity works as key via creating an ephemeral key pair for signing the artifact just once. The ephemeral certificate will expire after
30min and you do not need to care about long-time storage or anything else. Nobody else can sign a new artifact with this key pair when the key pair has expired.
The related Github workflow is as simple as the GoReleaser configuration above:

```yaml
  release:
    permissions:
      id-token: write
      contents: write
    runs-on: ubuntu-latest
    needs: test
    if: github.event_name == 'push' && contains(github.ref, 'refs/tags/')
    steps:
      - name: Checkout
        uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Set up Go
        uses: actions/setup-go@v2
        with:
          go-version: 1.17
      - name: install cosign
        uses: sigstore/cosign-installer@main
        with:
          cosign-release: 'v1.3.1'
      - name: Run GoReleaser
        uses: goreleaser/goreleaser-action@v2
        with:
          distribution: goreleaser
          version: 'v0.184.0'
          args: release --rm-dist
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          COSIGN_EXPERIMENTAL: 1
```

For this to work, we need two set two permissions for the release pipeline. I suggest enabling these permissions only for the GoReleaser release and not for any testing.
The release pipeline should only start when a trusted maintainer sets a tag. This way, we are preventing other users from creating signed source tarballs via pull requests.
The pipeline installs Go, cosign and GoReleaser. The last two lines set the Github Actions Token and enable cosign's experimental features.

I hope this article is useful for open source project maintainers out there and I hope they will prefer this method over do not signing their code at all.

Some forecasts for the future:

* Cosign will get functionality for piping the created public certificate into a file.
* GoReleaser will get functionality for releasing the public certificate as well (nice for double-checking: offline certificate + rekor transparency log)

The sigstore infrastructure is not yet production ready, but safe to use. As far as I know transparency logs will transition into the new public production ready instance.
The experimental features will hopefully be general available soon.