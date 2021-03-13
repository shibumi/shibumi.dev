---
title: "Kubernetes on Hetzner in 2021"
date: 2021-01-25T21:24:59+01:00
draft: false
description: How to create a Kubernetes Cluster with Kubermatic's KubeOne on Hetzner Cloud
tags:
 - linux
 - devops
---

Hello and welcome to my little Kubernetes on Hetzner tutorial for the first half of 2021.
This tutorial will help you bootstrapping a Kubernetes Cluster on Hetzner with [KubeOne](https://github.com/kubermatic/kubeone).
I am writing this small tutorial, because I had some trouble to bootstrap a cluster on Hetzner with KubeOne.
But first of all let us dive into the question why we even need KubeOne and how does KubeOne helps.
KubeOne is a small wrapper around [kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).
Kubeadm is **the** official tool for installing Kubernetes on VMs or bare-metal nodes, but it has one major disadvantage: It is very toilsome.
KubeOne tries to solve this with providing you a wrapper around Kubeadm and various other provisioning tools like [Terraform](https://www.terraform.io/).
Terraform lets you manage your infrastructure as code. The advantage is that you can easily destroy, deploy or enhance your infrastructure
via a few config file changes. You may ask yourself why you even need this tutorial. There is already at [least one tutorial](https://community.hetzner.com/tutorials/install-kubernetes-cluster) that guides you through the process of setting up a Kubernetes cluster on Hetzner. This is correct, but I felt it is unnecessary complicated,
takes too much manual steps and is not really automatable (although there are solutions like [kubespray](https://github.com/kubernetes-sigs/kubespray) that intend to solve this).

I hope you will give this tutorial a chance and I promise that you will not regret it. You will definitely learn something from it.
For the beginning you need the following ingredients for mixing your first Kubernetes cluster with Hetzner flavor:

* A Hetzner Cloud account
* [KubeOne](https://github.com/kubermatic/kubeone)
* [Terraform](https://www.terraform.io/)
* Basic understanding of Kubernetes and Linux

The first and the last is something I assume that you already have. Installing KubeOne and Terraform should be easy on Arch Linux.
You can just install it from the repositories (I am maintaining them hrhr):

```bash
$ pacman -Syu terraform kubeone
```

Furthermore I suggest that you clone the KubeOne repository. It has some great examples for Hetzner and gives you a first insight on what you can do
with it and what not:

```bash
$ git clone https://github.com/kubermatic/kubeone
```

If you are in the Hetzner Cloud console I suggest that you create a new project for playing around (Just in case we screw things up).
For this new project you need a new API token. Again, I assume that you know how to do this. The token needs read **and** write permissions.
First we move in the freshly cloned repository and investigate the files in it:

```bash
$ cd kubeone/examples/terraform/hetzner
$ ls
.rw-r--r-- 2.6k chris 17 Dec  2020 main.tf
.rw-r--r-- 2.4k chris 17 Dec  2020 output.tf
.rw-r--r-- 1.8k chris 17 Dec  2020 README.md
.rw-r--r-- 1.9k chris 25 Jan 22:01 variables.tf
.rw-r--r--  131 chris 17 Dec  2020 versions.tf
```

The `README.md` file gives us a brief explanation about inputs and outputs and gives us hints about loadbalancers.
The `versions.tf` file tells us the required Terraform version and the required providers. In our case the cloud provider is hcloud.
The `variables.tf` file defines all variables for our new cluster infrastructure.
The `output.tf` file defines the output of Terraform. This will get important later, because we will use the output as direct input
for KubeOne. The `main.tf` file hides the core logic behind all of this. The `main.tf` file is reponsible for bootstrapping the infrastructure.
In this file we see networks, ssh keys, loadbalancers and virtual machines defined. I do not want to explain Terraform in detail here.
If you are interested in this I suggest you have a look on the excellent [terraform registry](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs) documentation. It gives you a nice introduction
for each resource. You do not have to edit one of these files. They are ready to go as they are.

For provisioning the infrastructure we can do the following:
```bash
$ export HCLOUD_TOKEN="<YOUR HCLOUD TOKEN>"
$ terraform init
$ terraform apply
```

`terraform apply` will ask you for a cluster name and will prompt you for confirmation later. After only a few seconds (wow),
you should see a JSON configuration in green letters. This means everything has been successfuly and the infrastructure is
starting right now. You might have noticed the `terraform.tfstate` file already.
Do not lose it, it stores the status quo of your infrastructure configuration. Next we can create our first `kubeone.yaml` configuration
file as input for KubeOne:

```yaml
apiVersion: kubeone.io/v1beta1
kind: KubeOneCluster

versions:
  kubernetes: '1.19.3'

cloudProvider:
  hetzner: {}
  external: true
```

Pretty simple, isn't it? If this is done we save our json output into a json file via: `terraform output -json > output.json`.
Now we get to our final line: `kubeone apply --manifest kubeone.yaml --tfjson output.json`. This line will apply the
KubeOne configuration to our current Terraform configuration and install the cluster in our infrastructure.
Your output should be similar to this one here:
```log
INFO[22:38:58 CET] Determine hostname...
INFO[22:38:59 CET] Determine operating system...
INFO[22:39:00 CET] Running host probes...
The following actions will be taken:
Run with --verbose flag for more information.
	+ initialize control plane node "avency-control-plane-1" (192.168.0.4) using 1.19.3
	+ join control plane node "avency-control-plane-2" (192.168.0.3) using 1.19.3
	+ join control plane node "avency-control-plane-3" (192.168.0.5) using 1.19.3
	+ ensure machinedeployment "avency-pool1" with 1 replica(s) exists

Do you want to proceed (yes/no): yes

INFO[22:43:14 CET] Determine hostname...
INFO[22:43:14 CET] Determine operating system...
INFO[22:43:14 CET] Installing prerequisites...
INFO[22:43:14 CET] Creating environment file...                  node=116.203.150.238 os=ubuntu
INFO[22:43:14 CET] Creating environment file...                  node=116.203.202.241 os=ubuntu
INFO[22:43:14 CET] Creating environment file...                  node=116.203.225.170 os=ubuntu
INFO[22:43:14 CET] Configuring proxy...                          node=116.203.202.241 os=ubuntu
INFO[22:43:14 CET] Installing kubeadm...                         node=116.203.202.241 os=ubuntu
INFO[22:43:14 CET] Configuring proxy...                          node=116.203.225.170 os=ubuntu
INFO[22:43:14 CET] Installing kubeadm...                         node=116.203.225.170 os=ubuntu
INFO[22:43:14 CET] Configuring proxy...                          node=116.203.150.238 os=ubuntu
INFO[22:43:14 CET] Installing kubeadm...                         node=116.203.150.238 os=ubuntu
....
INFO[22:49:54 CET] Installing machine-controller...
INFO[22:49:57 CET] Installing machine-controller webhooks...
INFO[22:49:58 CET] Waiting for machine-controller to come up...
INFO[22:50:34 CET] Creating worker machines...
```
KubeOne could take a few minutes for setting everything up, but in the end you should be greeted with a `*-kubeconfig` file
in the current directory. I suggest you setup a `configs` directory in `$HOME/.kube/configs`. This way you can store
every Kubernetes config for multiple clusters in one directory. Additionally you should set this environment variable
in your `zshrc` or `bashrc` configuration: `KUBECONFIG="$(find ~/.kube/configs/ -type f -exec printf '%s:' '{}' +)"`.
It will load all Kubernetes configuration files and construct a path from them. Big thanks to my friend Morre for the tip.

If you moved the config file to the right direction and restarted your shell you should be able to list all nodes: `kubectl get nodes`.
The biggest advantage of KubeOne over the previous mentioned method is that you can easily scale your cluster up and down.
This works, because KubeOne ships a `machine-controller` for deploying or deleting worker nodes.
For scaling your cluster up and down just modify the `machinedeployment` resource in the `kube-system` namespace or
use the `kubectl scale` command: `kubectl scale -n kube-system machinedeployment <machinedeployment-name> --replicas=5`.
You are even able to scale your cluster to zero: `kubectl scale -n kube-system machinedeployment <machinedeployment-name> --replicas=0`.

Take in mind that you need modify your `output.tf` or KubeOne configuration manifest if you scale up or down, otherwise you might end up
deleting/adding resources you do not want. Apropos deleting, if you want to get rid of everything and this article sucks just do a `terraform destroy`.
This should destroy all configured resources that got created via Terraform. Playing around with this for multiple hours cost me around 20 cent.
I hope you do not forget to delete your resources after playing around. Luckily Hetzner is not that expensive and you should not wake up with a €2000 bill
the next day (not looking at you Amazon AWS...).

Next time we will dive into bootstrapping our first Kubernetes cluster without machine-controller and static worker nodes.

Here are some additional links that were helpful:

* [https://docs.kubermatic.com/kubeone/v1.0/](https://docs.kubermatic.com/kubeone/v1.0/)
* [https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs](https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs)
* [https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
* [https://www.kubermatic.com/blog/kubeone-oidc-authentication-audit-logging/](https://www.kubermatic.com/blog/kubeone-oidc-authentication-audit-logging/)
