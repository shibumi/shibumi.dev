---
title: "Hetzner Pulumi Intro"
date: 2021-11-21T17:08:36+01:00
draft: false
description: "Tutorial for Hetzner and Pulumi with the Go programming language"
toc: false
images:
tags: 
  - linux
  - devops
---

The full configuration for this article can be visited here: [https://github.com/shibumi/infra/tree/pulumi-migration](https://github.com/shibumi/infra/tree/pulumi-migration)

This weekend I had finally some time to have a longer glimpse on Hetzner and Pulumi. Pulumi sparked
my interest for a pretty long time now after reading [Engin's blog post about pulumi and Microsoft Azure](https://blog.ediri.io/podtato-head-pulumi-and-azure-container-apps).
I tried Pulumi earlier, but I gave up pretty fast, because it had no Netlify support. The missing Netlify support did not change, but I did not want to
invest time in my Terraform configuration, hence I decided to have a look on Pulumi instead.

So, what is Pulumi? Pulumi is just another infrastructure as code tool, but this Pulumi is more serious about the code aspect of it. You may know tools like
Hashicorp Terraform already. Hashicorp states that Terraform is infrastructure as code and although the Hashicorp configuration language (HCL) may be turing complete (is it?!)
I would not really consider it as infrastructure as code. What I always disliked about Terraform was that HCL felt more like a configuration language than a programming language.
For me it always felt like JSON on steroids with lots of syntax sugar and additional templating features. It did not really feel like Code. Pulumi does this all different
by providing a client, an optional web service and real programming libraries. The latter in that list is the game changer. With Pulumi it is possible to use your favorite
programming language and finally do what infrastructure as code should be like: You define in your infrastructure in a high level programming language.
The supported languages are Node.js, Python, Go and .NET Core. Most libraries in Pulumi have been imported from Terraform modules (I wonder how Hashicorp feels about this)
and the bigger libraries are rewritten from scratch as Pulumi native library. Today, I would like to showcase Pulumi a little bit with setting up a server at the Hetzner Cloud. I choose Hetzner, because I think there were enough hyperscaler tutorials.

Let us start with initializing the Pulumi client. Pulumi keeps, similar to Terraform, a state. This state can be stored on your local machine or in the cloud.
If you are very paranoid about your secrets you can enable local storage via executing `pulumi login --local`. This command will initialize the Pulumi state in your home directory
at `$HOME/.pulumi`. You can skip this command if you prefer the Pulumi web service as state storage. In a production environment, I would suggest storing the state within your cloud provider
or within Pulumi.

My favorite programming language is Go, right now. The following lines initialize a new Go pulumi project:

```
❯ pulumi new go
This command will walk you through creating a new Pulumi project.

Enter a value or leave blank to accept the (default), and press <ENTER>.
Press ^C at any time to quit.

project name: (infra) infra
project description: (A minimal Go Pulumi program) my private infrastructure
Created project 'infra'

stack name: (dev)
Created stack 'dev'
Enter your passphrase to protect config/secrets:
Re-enter your passphrase to confirm:

Enter your passphrase to unlock config/secrets
    (set PULUMI_CONFIG_PASSPHRASE or PULUMI_CONFIG_PASSPHRASE_FILE to remember):
Installing dependencies...

Finished installing dependencies

Your new project is ready to go!

To perform an initial deployment, run 'pulumi up'
```

One of the first aspects I like about Pulumi is that the state is encrypted on default. Next, we are going to have a look on our custom layout.
Due to the infrastructure as code philosophy, we can fully customize the layout of our project. My current infrastructure project is as follows:

```
.
├── assets
│  └── cloud-config
│     └── ritsuko.yaml
├── go.mod
├── go.sum
├── internal
│  ├── cloudconfig.go
│  ├── config.go
│  └── helper.go
├── main.go
├── Pulumi.dev.yaml
└── Pulumi.yaml
```

The assets directory has a sub-directory with cloud configuration files. Pulumi.yaml is the main configuration file of the project and
Pulumi.dev.yaml is the configuration file for the stack `dev`. Stacks are different environments (Dev, Stage, Production).
Our goal for this little article is to get a configuration from our Pulumi.dev.yaml file, read all files in the cloud-config
directory and use this cloud-config files to create servers.

After initialization of the project you just have a main.go file and the two Pulumi configuration files. The main.go should look like this:

```go
package main

import (
    "github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

func main() {
    pulumi.Run(func(ctx *pulumi.Context) error {
        return nil
    })
}
```

For further development you just have to extend the `pulumi.Run` method. But, first we are going to add some variables to the dev stack configuration file:
```yaml
encryptionsalt: <REDACTED>
config:
  infra:key:
    id: "chris@motoko"
    publicKey: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHlRfwIYqaqWfh5ObpCV5pA+n+KolK64LZ5VyIi5ZjwtEswkDI6KcGDTGcWYY+/XJ42kj7SbYHSCm4t/HAXHgmKDuQPzq72nVY7G1DjYrArGig9ni0/XCJY64s5oBgW8wVPTnbf/wYo+gHqsXO7ZaJKknW7jybmIiMC9hx+BkGugyT2WdVnI/8fXiR7VBArSfPIT/ieuWi+GR/7nIz6X09d77pY+tZzeOfbm2obU3EsIh8KJzoZeeopqOFnxooTGtk3ifL8Sv154KDzPwRnaGKdwd36aljQharAUkRQS3bVZiRx1Jw19+1XT0a8/D70ilAKMX6ilUa+LO9jObd49pUSitVGN6gHV5LBybbXjdaLe62dN9gRttJ24KjoJer1o2PMRxNxjwGgksPXhcyfBgbxmNOnsGYZ90PFdp3CH3eh9V8wmwj/ATPnX0s7pAVIpJt6lvdMfoZoezWhk/N0e0GpLWc7hmhxmEP0GYp5+oLL4n5wGr39uOsjPeqpx5c+QJPgIk0cJpKW8gVOw5T8e72v6r44APy9+XLTx2rAwfKeTBwyQo/yiGRo+gEdrPROOl9bei+eGFApJLtHPGqMP5PzMpY1A67z3D4tZ8zPoIqDoos5O6k04aXkbHjNCOkbwY29PfqZzqZmEo+FGDAhqwzpfc/7e7vDJTLWusIxxaaOQ== chris@motoko"
  infra:cloudConfigPath: "assets/cloud-config"
```

Keys in the pulumi world always have a namespace and an identifier `namespace:identifier`. `infra` is our default namespace, because our project has the name `infra`.
For Hetzner cloud access we can add the Hetzner cloud token to the configuration and import the pulumi Hetzner package: 
```
$ pulumi config set hcloud:token XXXXXXXXXXXXXX --secret
$ go get github.com/pulumi/pulumi-hcloud/sdk/go/hcloud@latest
```

With this configuration in place we can now continue with our main method and add our first SSH public key to Hetzner:

```go
package main

import (
	"github.com/pulumi/pulumi-hcloud/sdk/go/hcloud"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

func main() {
	pulumi.Run(func(ctx *pulumi.Context) error {
		// read configuration file
		var pubKey internal.SSHPublicKey
		pulumiConf := config.New(ctx, "")                        // namespace "" refers to the default project namespace "infra"
		pulumiConf.RequireObject("key", &pubKey)                 // read infra:key object
		cloudConfigPath := pulumiConf.Require("cloudConfigPath") // read infra:cloudConfigPath string

		// create Hetzner SSH Public Key
		sshKey, err := hcloud.NewSshKey(ctx, pubKey.ID, &hcloud.SshKeyArgs{
			Name:      pulumi.String(pubKey.ID),
			PublicKey: pulumi.String(pubKey.PublicKey),
		})

    return nil
  })
}
```

internal.SSHPublicKey refers to a struct in our `internal` package:
```go
package internal

// SSHPublicKey extends the SSH public key with its ID (comment field)
// This makes handling easier. We just get the key from the pulumi configuration.
// An alternative is parsing the key and reading the comment field.
type SSHPublicKey struct {
	ID        string
	PublicKey string
}
```

Next, we are creating our first cloud config file. I usually name these files in the following pattern `<serverName>.yaml`.
This has the little advantage that we can use these files to bootstrap servers later. Here is a very simplified cloud configuration:

```yaml
#cloud-config

ntp:
  enabled: true
timezone: UTC
fqdn: ritsuko.shibumi.dev
ssh_pwauth: false
ssh_authorized_keys:
  - "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHlRfwIYqaqWfh5ObpCV5pA+n+KolK64LZ5VyIi5ZjwtEswkDI6KcGDTGcWYY+/XJ42kj7SbYHSCm4t/HAXHgmKDuQPzq72nVY7G1DjYrArGig9ni0/XCJY64s5oBgW8wVPTnbf/wYo+gHqsXO7ZaJKknW7jybmIiMC9hx+BkGugyT2WdVnI/8fXiR7VBArSfPIT/ieuWi+GR/7nIz6X09d77pY+tZzeOfbm2obU3EsIh8KJzoZeeopqOFnxooTGtk3ifL8Sv154KDzPwRnaGKdwd36aljQharAUkRQS3bVZiRx1Jw19+1XT0a8/D70ilAKMX6ilUa+LO9jObd49pUSitVGN6gHV5LBybbXjdaLe62dN9gRttJ24KjoJer1o2PMRxNxjwGgksPXhcyfBgbxmNOnsGYZ90PFdp3CH3eh9V8wmwj/ATPnX0s7pAVIpJt6lvdMfoZoezWhk/N0e0GpLWc7hmhxmEP0GYp5+oLL4n5wGr39uOsjPeqpx5c+QJPgIk0cJpKW8gVOw5T8e72v6r44APy9+XLTx2rAwfKeTBwyQo/yiGRo+gEdrPROOl9bei+eGFApJLtHPGqMP5PzMpY1A67z3D4tZ8zPoIqDoos5O6k04aXkbHjNCOkbwY29PfqZzqZmEo+FGDAhqwzpfc/7e7vDJTLWusIxxaaOQ== chris@motoko"
runcmd:
  - "dnf install dnf-automatic -y"
  - "systemctl enable dnf-automatic.timer --now"
```

You might be confused now, because I am adding the SSH key twice and you absolutly can be. Actually, I would like to add the key via the cloud-config file only, but
Hetzner cloud reacts with enabling password authentication for the host and sending you the password via mail if you do not set the SSH key via their API.
I would like to circumvent this and decided to just set it twice. It might make sense to either remove it in the cloud-config file and set it only via Hetzner API
or set it only via cloud-config, while ignoring Hetzner root password mails. The cloud-config file disables ssh_pwauth anyway (shrug).

For reading all cloud-config files I have setup a little helper function:

```go
package internal

import (
	"github.com/pulumi/pulumi-cloudinit/sdk/go/cloudinit"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
	"io/ioutil"
	"path/filepath"
	"strings"
)

// cloudConfigContentType cannot be a constant, because we cannot use pointers to constants in Go
var cloudConfigContentType = "text/cloud-config"

// CloudConfig extends the pulumi cloud-config with an ID
type CloudConfig struct {
	ID          string
	CloudConfig *cloudinit.LookupConfigResult
}

// NewCloudConfigs reads all cloud-config files in a given path and returns
// a slice of CloudConfig
func NewCloudConfigs(ctx *pulumi.Context, path string) ([]CloudConfig, error) {
	var cloudConfigs []CloudConfig

	files, err := ioutil.ReadDir(path)
	if err != nil {
		return nil, err
	}
	for _, f := range files {
		config, err := ioutil.ReadFile(filepath.Join(path, f.Name()))
		if err != nil {
			return nil, err
		}
		cloudConfig, err := cloudinit.LookupConfig(ctx, &cloudinit.LookupConfigArgs{
			Base64Encode: BoolPtr(false),
			Gzip:         BoolPtr(false),
			Parts: []cloudinit.GetConfigPart{
				{
					Content:     string(config),
					ContentType: &cloudConfigContentType,
					Filename:    StringPtr(f.Name()),
				},
			},
		})
		if err != nil {
			return nil, err
		}
		cloudConfigs = append(cloudConfigs, CloudConfig{
			ID:          strings.TrimSuffix(f.Name(), filepath.Ext(f.Name())),
			CloudConfig: cloudConfig,
		})
	}
	return cloudConfigs, nil
}

// BoolPtr needs a bool and returns a pointer to the bool.
// This function is needed for pulumi's cloud-config.
// Pulumi's cloud-config does not seem to support pulumi.Bool or pulumi.BoolPtr :(
func BoolPtr(b bool) *bool {
	return &b
}

// StringPtr needs a string and returns a pointer to the string.
// This function is needed for pulumi's cloud-config.
// Pulumi's cloud-config does not seem to support pulumi.String or pulumi.StringPtr :(
func StringPtr(s string) *string {
	return &s
}
```

The `NewCloudConfigs` function reads all files in the cloud-config directory, creates cloud-config objects from these files and connects
them with their filename as ID. Surprisingly, we have to create two small helper functions here, because I seem to be unable to use
the two Pulumi types for the CloudConfig fields (`pulumi.Bool` and `pulumi.BoolPtr`). The final main.go file can then use this `NewCloudConfigs`
method:

```go
func main() {
	pulumi.Run(func(ctx *pulumi.Context) error {
		// read configuration file
		var pubKey internal.SSHPublicKey
		pulumiConf := config.New(ctx, "")                        // namespace "" refers to the project namespace "infra"
		pulumiConf.RequireObject("key", &pubKey)                 // read infra:key object
		cloudConfigPath := pulumiConf.Require("cloudConfigPath") // read infra:cloudConfigPath string

		// create Hetzner SSH Public Key
		sshKey, err := hcloud.NewSshKey(ctx, pubKey.ID, &hcloud.SshKeyArgs{
			Name:      pulumi.String(pubKey.ID),
			PublicKey: pulumi.String(pubKey.PublicKey),
		})

		// create cloud-configs
		cloudConfigs, err := internal.NewCloudConfigs(ctx, cloudConfigPath)
		if err != nil {
			return err
		}

		// use cloud-configs to initialize virtual machines
		for _, cloudConfig := range cloudConfigs {
			_, err := hcloud.NewServer(ctx, cloudConfig.ID, &hcloud.ServerArgs{
				Image:      pulumi.String("fedora-34"),
				Name:       pulumi.String(cloudConfig.ID),
				ServerType: pulumi.String("cx11"),
				SshKeys: pulumi.StringArray{
					sshKey.Name,
				},
				UserData: pulumi.String(cloudConfig.CloudConfig.Rendered),
			})
			if err != nil {
				return err
			}
		}
		return nil
	})
}
```

With running `pulumi up` we are able to create all resources and with `pulumi destroy` we can destroy all resources, again:
```
❯ pulumi up
Previewing update (dev):
     Type                    Name          Plan       
 +   pulumi:pulumi:Stack     infra-dev     create     
 +   ├─ hcloud:index:SshKey  chris@motoko  create     
 +   └─ hcloud:index:Server  ritsuko       create     
 
Resources:
    + 3 to create

Do you want to perform this update?  [Use arrows to move, enter to select, type to filter]
  yes
> no
  details
```

# Conclusion

I think Pulumi has a huge potential, because it feels much more natural than using the Hashicorp configuration language (HCL).
I do not know how many hours I have wasted into HCL for writing very simple loops and just for finding out later that these loops
do not work that way, because Terraform is a little bit different. With Pulumi these frustrations are gone.

Pulumi provides a very convenient way for teams without any HCL knowledge to manage infrastructure in their favorite programming language.
But, I still see a few problems with Pulumi. Writing the Pulumi code feels a little bit frustrating sometimes, too.
Especially, Pulumi's custom datatypes like `pulumi.String` or `pulumi.Bool` gave me lots of headache, because I had no idea how to fill
these fields in the Pulumi structs at first and then I found out about the Pulumi datatypes I got even more frustrated when I found out
that the Pulumi cloud configuration method had trouble with using these custom data types. This might be just my personal experience.
If you know a way how to fill these fields in the `cloudinit.LookupConfigArgs` struct without using custom helper methods let me know.