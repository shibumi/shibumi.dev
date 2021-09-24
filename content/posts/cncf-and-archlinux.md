---
title: "Cloud Native and Arch Linux"
date: 2021-09-24T19:39:35+02:00
draft: false
description:
tags:
 - linux
 - devops
---

In this article I want to give a short overview over the current state of Arch Linux with respect to cloud native technologies.
I would like to show why I think Arch Linux is perfect as a daily driver in the cloud native ecosystem and how the current
state of cloud native software in Arch Linux looks like. 

## Reason Nr 1: Security

At Arch Linux we take security very seriously. Our newly selected project lead has a strong security background (founding member of the Arch Linux security team)
and member in a CTF group. Another good reason is our strong hardening process. Recently, I have already explained how we harden Go binaries in Arch Linux.
[If you have missed this article, feel free to add it to your bookmarks](/posts/hardening-executables/). We enable the following flags in Arch Linux:

* FULL RELRO (Full Relocation Read-Only)
* STACK CANARY
* NX-Bit
* PIE (Position Independent Executable/Code)
* Setting no RPATH6
* Setting no Symbols
* FORTIFY
* ..... a full explanation can be found in the linked blog article ;)

In my experience you will not find most of these flags enabled in binaries that you download directly from Github or a project website.
As far as I know, these flags are very unique to Arch Linux. Even Fedora does not enable all of them.
Other arguments for Arch Linux in terms of security are:

* Packages are mostly up to date. We ship the newest Go binary as soon as possible
* We re-compile all of our packages with the newest Go binary (if possible and we are not running into weird issues with the new Go version).
* We try to ship the newest version of a software within a week (my personal record is a few minutes after release).
* We release security advisories for our packages via a mailing list and [https://security.archlinux.org](https://security.archlinux.org)
* Many Arch Linux members also contribute to security related projects like [https://reproducible-builds.org/](https://reproducible-builds.org/) or secure supply chains.

## Reason Nr 2: From cloud native developers to cloud native developers

All packages that I maintain are in daily production use. I work as SRE and my laptop runs on Arch Linux. It surprises me
every day again how stable the whole system is. You could consider this as good motivation for keeping everything running and stable.

## Reason Nr 3: Convenience

Arch Linux has built up a very big catalog of cloud native software. Hence, if you are tired of visiting Github project websites
and if you are looking for a convenient way to install your cloud native tools on your laptop, Arch Linux is the go-to solution for you.
You can easily install any of the tools below via executing `sudo pacman -S <package name>`.
Do not consider the following list as 'complete'. The following packages are either maintained or co-maintained by myself. Big shout-out to
my co-maintainers Morten Linderud ([@MortenLinderud](MortenLinderud)) and David Runge:

* [argocd](https://archlinux.org/packages/community/x86_64/argocd/)
* [aws-vault](https://archlinux.org/packages/community/x86_64/aws-vault/)
* [caddy](https://archlinux.org/packages/community/x86_64/caddy/)
* [cloud-init](https://archlinux.org/packages/community/any/cloud-init/)
* [cosign](https://archlinux.org/packages/community/x86_64/cosign/)
* [cri-o](https://archlinux.org/packages/community/x86_64/cri-o/)
* [cue](https://archlinux.org/packages/community/x86_64/cue/)
* [eksctl](https://archlinux.org/packages/community/x86_64/eksctl/)
* [fluxctl](https://archlinux.org/packages/community/x86_64/fluxctl/) **Note: flux2 is WIP for the official repositories**
* [fulcio](https://archlinux.org/packages/community/x86_64/fulcio/)
* [goreleaser](https://archlinux.org/packages/community/x86_64/goreleaser/)
* [hcloud](https://archlinux.org/packages/community/x86_64/hcloud/)
* [helm](https://archlinux.org/packages/community/x86_64/helm/)
* [helmfile](https://archlinux.org/packages/community/x86_64/helmfile/)
* [istio](https://archlinux.org/packages/community/x86_64/istio/)
* [k9s](https://archlinux.org/packages/community/x86_64/k9s/)
* [knative-client](https://archlinux.org/packages/community/x86_64/knative-client/)
* [ko](https://archlinux.org/packages/community/x86_64/ko/)
* [kompose](https://archlinux.org/packages/community/x86_64/kompose/)
* [kubeadm](https://archlinux.org/packages/community/x86_64/kubeadm/)
* [kube-apiserver](https://archlinux.org/packages/community/x86_64/kube-apiserver/)
* [kube-control-manager](https://archlinux.org/packages/community/x86_64/kube-controller-manager/)
* [kubectl](https://archlinux.org/packages/community/x86_64/kubectl/)
* [kubectl-cert-manager](https://archlinux.org/packages/community/x86_64/kubectl-cert-manager/)
* [kubectl-ingress-nginx](https://archlinux.org/packages/community/x86_64/kubectl-ingress-nginx/)
* [kubectx](https://archlinux.org/packages/community/any/kubectx/)
* [kubelet](https://archlinux.org/packages/community/x86_64/kubelet/)
* [kubeone](https://archlinux.org/packages/community/x86_64/kubeone/)
* [kube-proxy](https://archlinux.org/packages/community/x86_64/kube-proxy/)
* [kube-scheduler](https://archlinux.org/packages/community/x86_64/kube-scheduler/)
* [kubeseal](https://archlinux.org/packages/community/x86_64/kubeseal/)
* [kustomize](https://archlinux.org/packages/community/x86_64/kustomize/)
* [minikube](https://archlinux.org/packages/community/x86_64/minikube/)
* [operator-sdk](https://archlinux.org/packages/community/x86_64/operator-sdk/)
* [packer](https://archlinux.org/packages/community/x86_64/packer/)
* [popeye](https://archlinux.org/packages/community/x86_64/popeye/)
* [pulumi](https://archlinux.org/packages/community/x86_64/pulumi/)
* [rekor](https://archlinux.org/packages/community/x86_64/rekor/)
* [restic](https://archlinux.org/packages/community/x86_64/restic/)
* [skaffold](https://archlinux.org/packages/community/x86_64/skaffold/)
* [tanka](https://archlinux.org/packages/community/x86_64/tanka/)
* [tekton-cli](https://archlinux.org/packages/community/x86_64/tekton-cli/)
* [terraform](https://archlinux.org/packages/community/x86_64/terraform/)
* [terragrunt](https://archlinux.org/packages/community/x86_64/terragrunt/)
* [traefik](https://archlinux.org/packages/community/x86_64/traefik/)
* [vals](https://archlinux.org/packages/community/x86_64/vals/)
* [vault](https://archlinux.org/packages/community/x86_64/vault/)

To be honest, I thought the list would be smaller and I hope you are still reading this article. If you are missing
software feel free to drop me a mail. My plans for the future involve a public github repository with all my PKGBUILDs
for nicer collaboration.

Also, I would like to give a short overview about packages I will have a look on next:

* Falco ([Kris Nova is already maintaining a working release in the AUR](https://aur.archlinux.org/packages/falco/))
* More kubectl plugins (imagine we could skip krew and just install every plugin hardened and validated via pacman)
* More projects from the [CNCF landscape](https://landscape.cncf.io/)