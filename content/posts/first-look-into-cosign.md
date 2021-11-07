---
title: "Keyless signatures for blobs with cosign"
date: 2021-11-07T04:09:03+01:00
draft: false
description: "First look into cosign and rekor for signing and validating binaries"
tags: 
  - linux
  - devops
---

While reading the [cosign-installer](https://github.com/sigstore/cosign-installer) I have stumbled upon these
lines in the documentation:

```yaml
      - name: Sign the images with GitHub OIDC **not production ready**
        run: cosign sign -oidc-issuer https://token.actions.githubusercontent.com ${TAGS}
        env:
          TAGS: ${{ steps.docker_meta.outputs.tags }}
          COSIGN_EXPERIMENTAL: 1
```

The shown lines are a step of a Github Action and are still experimental, but very interesting.
It allows to sign a docker image via making use of the OpenID Connect standard.
OpenID Connect can be summarized as follows: If you login into Github, Github will create a number of tokens.
These tokens are then associated with your Github Action and with these tokens you can sign any artifact.
The `run` line above utilizes this feature and signs a docker image.

This whole process is called "keyless" signature or ambient credentials via workload identities. The word keyless can be a little bit misleading.
It does and does not refer to the existence of a cryptographic key. Implementation-wise, there is a key. Otherwise,
the whole private/public procedure would not work. But, on the same time you do not have to provide
a secret for generating this key. The process is secretless; at least on the first look. On the second look
you will realize that your Identity has become the secret. [Dan Lorenc summarizes this as follows](https://dlorenc.medium.com/a-bit-of-ambiance-comes-to-sigstore-f80d1d6b1c30):


> 1. A person logs into their Identity Provider (think Google, or Facebook).
> 2. The person requests an Identity Token from their provider.
> 3. The person hands that token to the other system (called the Relying Party) they want to login to (think, Sigstore)!
> 4. The relying party can verify this token, using data it knew about the Identity Provider ahead of time.


This whole story leads us to the actual topic of my article. I wanted to do the same, just without Github Actions.
I wanted to know if it is possible to sign an arbitrary binary large object (blob) with my identity via OIDC.
The answer is: **yes**. The process is undocumented and it took me a while to understand it.

First of all we need a file. Let us create a simple hello-world text file (it should work with real blobs, too):

```bash
$ echo "hello world" > hello-world.txt
$ sha256sum hello-world.txt
a948904f2f0f479b8f8197694b30184b0d2ed1c1cd2a1ec0fb85d299a192a447  hello-world.txt
```

Next, we will use the public sigstore instance to generate a new signature via our OpenID and upload it to a public rekor instance.
This feature is still experimental. I hope they will release it soon. During the process your browser will pop-up, forward you
to the public sigstore instance and ask you for a login. If you login, cosign will use your OpenID to sign the file.

```bash
$ COSIGN_EXPERIMENTAL=1 cosign sign-blob -rekor-url https://rekor.sigstore.dev -oidc-issuer https://oauth2.sigstore.dev/auth hello-world.txt
Using payload from: hello-world.txt
Generating ephemeral keys...
Retrieving signed certificate...
Your browser will now be opened to:
https://oauth2.sigstore.dev/auth/auth?access_type=online&client_id=sigstore&code_challenge=Z2gsH9r-KorQ1lYpQLKz2Wjm-zE8vNB6s25yCEuN6wo&code_challenge_method=S256&nonce=20ZeevJ6RR6a4c4jgagE3HQ43ZR&redirect_uri=http%3A%2F%2Flocalhost%3A5556%2Fauth%2Fcallback&response_type=code&scope=openid+email&state=20ZeesbrPq3piRsUbLquOaUGI5Y
Successfully verified SCT...
signing with ephemeral certificate:
-----BEGIN CERTIFICATE-----
MIICojCCAimgAwIBAgITfeMurY7QyH3CVPjAuhCLS1ifKTAKBggqhkjOPQQDAzAq
MRUwEwYDVQQKEwxzaWdzdG9yZS5kZXYxETAPBgNVBAMTCHNpZ3N0b3JlMB4XDTIx
MTEwNzAzNDQwMloXDTIxMTEwNzA0MDQwMVowADBZMBMGByqGSM49AgEGCCqGSM49
AwEHA0IABHlCpBR9fYSgplx+k5dOgoiWBLG51xJQOrys+h0dTKP3LRVQpmGSW7S+
HeMjPICrFv+9fLLuf6qhiZDaNDNLAZKjggFWMIIBUjAOBgNVHQ8BAf8EBAMCB4Aw
EwYDVR0lBAwwCgYIKwYBBQUHAwMwDAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQU52CM
yuCMjYUDleSMbSQzYGdL8sowHwYDVR0jBBgwFoAUyMUdAEGaJCkyUSTrDa5K7UoG
0+wwgY0GCCsGAQUFBwEBBIGAMH4wfAYIKwYBBQUHMAKGcGh0dHA6Ly9wcml2YXRl
Y2EtY29udGVudC02MDNmZTdlNy0wMDAwLTIyMjctYmY3NS1mNGY1ZTgwZDI5NTQu
c3RvcmFnZS5nb29nbGVhcGlzLmNvbS9jYTM2YTFlOTYyNDJiOWZjYjE0Ni9jYS5j
cnQwHwYDVR0RAQH/BBUwE4ERY2hyaXNAc2hpYnVtaS5kZXYwLAYKKwYBBAGDvzAB
AQQeaHR0cHM6Ly9naXRodWIuY29tL2xvZ2luL29hdXRoMAoGCCqGSM49BAMDA2cA
MGQCMFSPoC87yJ9vzbA9r/axlCoUwM7seSTRjd/AofdbkIhu+PnKuVjy157iRPyF
ioPCFAIwaVl6esuRLALWBSU4ePbTDssEAwyn7X5XS+oHmyET/Ba9IGRxq+Mce20B
Wc4CreCB
-----END CERTIFICATE-----

tlog entry created with index: 832324
MEQCICKv+6N4KTrTkcV3Sc3E1ydvemWr+siTVcgtG5GPG6w7AiAbQnwgwR8tmy7XAOCx0Xox5inc3rj8v8a02U7bpSsXQw==
```

The output can be broken up in the following parts. First there is the generated ephemeral certificate:
```
-----BEGIN CERTIFICATE-----
MIICojCCAimgAwIBAgITfeMurY7QyH3CVPjAuhCLS1ifKTAKBggqhkjOPQQDAzAq
MRUwEwYDVQQKEwxzaWdzdG9yZS5kZXYxETAPBgNVBAMTCHNpZ3N0b3JlMB4XDTIx
MTEwNzAzNDQwMloXDTIxMTEwNzA0MDQwMVowADBZMBMGByqGSM49AgEGCCqGSM49
AwEHA0IABHlCpBR9fYSgplx+k5dOgoiWBLG51xJQOrys+h0dTKP3LRVQpmGSW7S+
HeMjPICrFv+9fLLuf6qhiZDaNDNLAZKjggFWMIIBUjAOBgNVHQ8BAf8EBAMCB4Aw
EwYDVR0lBAwwCgYIKwYBBQUHAwMwDAYDVR0TAQH/BAIwADAdBgNVHQ4EFgQU52CM
yuCMjYUDleSMbSQzYGdL8sowHwYDVR0jBBgwFoAUyMUdAEGaJCkyUSTrDa5K7UoG
0+wwgY0GCCsGAQUFBwEBBIGAMH4wfAYIKwYBBQUHMAKGcGh0dHA6Ly9wcml2YXRl
Y2EtY29udGVudC02MDNmZTdlNy0wMDAwLTIyMjctYmY3NS1mNGY1ZTgwZDI5NTQu
c3RvcmFnZS5nb29nbGVhcGlzLmNvbS9jYTM2YTFlOTYyNDJiOWZjYjE0Ni9jYS5j
cnQwHwYDVR0RAQH/BBUwE4ERY2hyaXNAc2hpYnVtaS5kZXYwLAYKKwYBBAGDvzAB
AQQeaHR0cHM6Ly9naXRodWIuY29tL2xvZ2luL29hdXRoMAoGCCqGSM49BAMDA2cA
MGQCMFSPoC87yJ9vzbA9r/axlCoUwM7seSTRjd/AofdbkIhu+PnKuVjy157iRPyF
ioPCFAIwaVl6esuRLALWBSU4ePbTDssEAwyn7X5XS+oHmyET/Ba9IGRxq+Mce20B
Wc4CreCB
-----END CERTIFICATE-----
```

Then you have the tlog index number: `832324`. And the last line is the generated signature, encoded in base64.
The tlog index number is interesting, because this number refers to the transparency log entry in the public rekor instance.
The transparency log of rekor will store any signature operation. You can take a more detailed look on such an entry with the
rekor-cli tool:

```bash
$ rekor-cli get --log-index 832324 --format json | jq
```
```json
{
  "Attestation": "",
  "AttestationType": "",
  "Body": {
    "RekordObj": {
      "data": {
        "hash": {
          "algorithm": "sha256",
          "value": "a948904f2f0f479b8f8197694b30184b0d2ed1c1cd2a1ec0fb85d299a192a447"
        }
      },
      "signature": {
        "content": "MEQCICKv+6N4KTrTkcV3Sc3E1ydvemWr+siTVcgtG5GPG6w7AiAbQnwgwR8tmy7XAOCx0Xox5inc3rj8v8a02U7bpSsXQw==",
        "format": "x509",
        "publicKey": {
          "content": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNvakNDQWltZ0F3SUJBZ0lUZmVNdXJZN1F5SDNDVlBqQXVoQ0xTMWlmS1RBS0JnZ3Foa2pPUFFRREF6QXEKTVJVd0V3WURWUVFLRXd4emFXZHpkRzl5WlM1a1pYWXhFVEFQQmdOVkJBTVRDSE5wWjNOMGIzSmxNQjRYRFRJeApNVEV3TnpBek5EUXdNbG9YRFRJeE1URXdOekEwTURRd01Wb3dBREJaTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5CkF3RUhBMElBQkhsQ3BCUjlmWVNncGx4K2s1ZE9nb2lXQkxHNTF4SlFPcnlzK2gwZFRLUDNMUlZRcG1HU1c3UysKSGVNalBJQ3JGdis5ZkxMdWY2cWhpWkRhTkROTEFaS2pnZ0ZXTUlJQlVqQU9CZ05WSFE4QkFmOEVCQU1DQjRBdwpFd1lEVlIwbEJBd3dDZ1lJS3dZQkJRVUhBd013REFZRFZSMFRBUUgvQkFJd0FEQWRCZ05WSFE0RUZnUVU1MkNNCnl1Q01qWVVEbGVTTWJTUXpZR2RMOHNvd0h3WURWUjBqQkJnd0ZvQVV5TVVkQUVHYUpDa3lVU1RyRGE1SzdVb0cKMCt3d2dZMEdDQ3NHQVFVRkJ3RUJCSUdBTUg0d2ZBWUlLd1lCQlFVSE1BS0djR2gwZEhBNkx5OXdjbWwyWVhSbApZMkV0WTI5dWRHVnVkQzAyTURObVpUZGxOeTB3TURBd0xUSXlNamN0WW1ZM05TMW1OR1kxWlRnd1pESTVOVFF1CmMzUnZjbUZuWlM1bmIyOW5iR1ZoY0dsekxtTnZiUzlqWVRNMllURmxPVFl5TkRKaU9XWmpZakUwTmk5allTNWoKY25Rd0h3WURWUjBSQVFIL0JCVXdFNEVSWTJoeWFYTkFjMmhwWW5WdGFTNWtaWFl3TEFZS0t3WUJCQUdEdnpBQgpBUVFlYUhSMGNITTZMeTluYVhSb2RXSXVZMjl0TDJ4dloybHVMMjloZFhSb01Bb0dDQ3FHU000OUJBTURBMmNBCk1HUUNNRlNQb0M4N3lKOXZ6YkE5ci9heGxDb1V3TTdzZVNUUmpkL0FvZmRia0lodStQbkt1Vmp5MTU3aVJQeUYKaW9QQ0ZBSXdhVmw2ZXN1UkxBTFdCU1U0ZVBiVERzc0VBd3luN1g1WFMrb0hteUVUL0JhOUlHUnhxK01jZTIwQgpXYzRDcmVDQgotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
        }
      }
    }
  },
  "LogIndex": 832324,
  "IntegratedTime": 1636256643,
  "UUID": "ee4b2e80cef72f8d4e3f00d695bd796ffd9e17b9cfd18ba96947493c4ee19f62",
  "LogID": "c0d23d6ad406973f9559f3ba2d1ca01f84147d8ffc5b8445c224f98b9591801d"
}
```

The transparency log entry stores everything what you need for validating my signature. There is the sha256 checksum of my file, the signature and
the public key for validating the signature.

I could not find an easy way to use this rekor transparency log as input for cosign, hence I have extracted the information manually as follows:
```bash
$ rekor-cli get --log-index 832324 --format json | jq -r '.Body.RekordObj.signature.content'  > hello-world.txt.sig
$ rekor-cli get --log-index 832324 --format json | jq -r '.Body.RekordObj.signature.publicKey.content' | base64 -d > pub.crt
```

The above commands will extract a signature file and the public certificate. Next, we can use both to validate the file:
```bash
$ COSIGN_EXPERIMENTAL=1 cosign verify-blob -cert pub.crt -signature hello-world.txt.sig hello-world.txt
No TUF root installed, using embedded CA certificate.
Certificate is trusted by Fulcio Root CA
Email: [chris@shibumi.dev]
Verified OK
tlog entry verified with uuid: "ee4b2e80cef72f8d4e3f00d695bd796ffd9e17b9cfd18ba96947493c4ee19f62" index: 832324
```

The line `Verified OK` states that the signature is fine. We will also see our transparency log entry again. Cosign magically
detects the signature and the certificate and knows that both can be found at index 832324 in the public rekor instance (I have no clue
how this works.. My guess is: more information embedded in the certificate).

If you do not know TUF... well.. this is a story for another day.