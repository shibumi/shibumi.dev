---
title: "Terraforming my blog"
date: 2020-02-18T16:11:06+01:00
draft: false
---

I've just pushed a first step for managing my infrastructure via Hashicorps
Terraform.  In this article I want to speak about this first step and I want to
give a glimpse into the future for it.

My infrastructure is hosted in Hetzner Cloud (there is luckily a terraform
provider for it). DNS will be talked about in a later blog article.

I usually store my passwords in a gopass password store, hence I've wanted to
let Terraform retrieve the Hetzner Cloud API key magically.

The solution is the use of the `external` Terraform module:

```hcl
data "external" "hetzner_cloud_api_key" {
	program = ["${path.module}/fetch-key.sh"]
}
```

This snippet will call a wrapper script called `fetch-key.sh`, that basically
just calls gopass and translates the output to a JSON structure:

```sh
#!/bin/bash

hetzner_cloud_api_key=$(gopass api/hetzner.com/motoko)
echo "{ \"hetzner_cloud_api_key\": \"${hetzner_cloud_api_key}\" }"
```

It's important to use the key  `hetzner_cloud_api_key` here!  In the next part
I am going to set the `hetzner_cloud_api_key` and call the `hcloud` provider
(this is going to download a go binary):

```hcl
provider "hcloud" {
  token = data.external.hetzner_cloud_api_key.result.hetzner_cloud_api_key
}
```

Then we are setting the actual server resource and an rdns entry for the server:

```hcl
resource "hcloud_server" "kurisu" {
  name        = "kurisu"
  server_type = "cx11-ceph"
  location    = "fsn1"
  image       = "fedora-31"
  lifecycle {
    ignore_changes = [image]
  }
}

resource "hcloud_rdns" "kurisu" {
  server_id  = hcloud_server.kurisu.id
  ip_address = hcloud_server.kurisu.ipv4_address
  dns_ptr    = "kurisu.shibumi.dev"
}
```

Interesting is the last part of the `hcloud_server` resource:
```hcl
  image       = "fedora-31"
  lifecycle {
    ignore_changes = [image]
  }
}
```

The image variable is actually never used. I have created my server with
Fedora-28 years ago. When Hetzner introduces a new Fedora image the last one
gets deprecated and the Hetzner Cloud API links that value against `null` or
`No Image`. Therefore any import of an existing server will fail, because you
can't set the `null` value to the image variable (it's a requirement for the
`hcloud_server` resource). And if you set any other string, the Hetzner Cloud
API will think it's a valid image value and will try to destroy your image and
create a new one. To go around this issue, just add a lifecycle for it and set
`ignore_changes = [image]`.  This will ignore any changes to the image variable
on Hetzner Cloud API side.

If you want to have a look on all files go and checkout:

[https://github.com/shibumi/infra](https://github.com/shibumi/infra)

I will definitely work further on this. On my todo list are:

* DNS via [inwx.de](https://inwx.de)
* rDNS entries for IPv6
* Provisioning of the actual image (not sure if I will use Ansible or rely on this for Terraform too).
