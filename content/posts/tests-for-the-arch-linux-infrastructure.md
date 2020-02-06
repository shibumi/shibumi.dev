---
title: "Tests for the Arch Linux infrastructure"
date: 2020-02-05T21:57:15+01:00
draft: false
---

The Arch Linux DevOps team uses a combination of Ansible and Terraform to
manage their hosts. If you want to have a look on their infrastructure
repository, you can do so via this link:
[https://git.archlinux.org/infrastructure.git/tree/](https://git.archlinux.org/infrastructure.git/tree/)

The combination of Ansible and Terraform works quite well for Arch Linux, the
only subject we are missing is proper testing. I want to present a small proof
of concept on how we could do tests in the future. My approach uses
[molecule](https://github.com/ansible-community/molecule) for testing.
Molecule utilizes [Vagrant](https://vagrant.io) and [Docker](https://docker.io)
for running the Ansible Playbooks.

Arch Linux provides images for both of them, since quite a while now. These
projects are called [Arch-Boxes](https://github.com/archlinux/arch-boxes) and
[Archlinux-Docker](https://github.com/archlinux/archlinux-docker). Therefore it
makes sense to reuse them infrastructure tests.

The actual tests are written in Python with support of the library
[testinfra](https://testinfra.readthedocs.io/en/latest/).

First of all we need to install the dependencies. You can find most of our
needed tools in our repositories:

* ansible
* python-pip
* python
* flake8
* ansible-lint
* docker
* vagrant

What we are missing right now is molecule. We can install molecule with the
vagrant dependencies via `pip install molecule[vagrant] --user`. Pip will
install all needed packages to our $HOME.


So let us pick a first role we want to test:

`infrastructure/roles/sshd`:
```
❯ ls -la
drwxr-xr-x - chris 15 Dec  2019 handlers
drwxr-xr-x - chris 15 Dec  2019 tasks
drwxr-xr-x - chris 15 Dec  2019 templates
```

We can initialize a molecule test scenario on an already existing Ansible role
via `molecule init scenario --role-name sshd --driver-name vagrant`.
The command is going to create a `molecule` directory for us. The created directory will have this structure:
```
❯ tree molecule 
molecule
└── default
   ├── INSTALL.rst
   ├── molecule.yml
   ├── playbook.yml
   ├── prepare.yml
   └── tests
      ├── __pycache__
      │  ├── test_default.cpython-38-pytest-5.3.5.pyc
      │  └── test_default.cpython-38.pyc
      └── test_default.py
```

The interesting files we will have a look at are `molecule.yml`, `prepare.yml`
and `test_default.py`.  In `molecule.yml` we configure basic molecule behavior.
In `prepare.yml` we can do first preparations with Ansible (we need to do this,
because Arch Linux is slightly different to distributions the molecule team
normally uses). `test_default.py` stores our tests as testinfra functions.

The `molecule.yml` shouldn't be so different for Arch Linux to the one that is usually generated by molecule, but let me highlight the changes:

`infrastructure/roles/sshd/molecule/default/molecule.yml`:
```yaml
---
dependency:
  name: galaxy
driver:
  # We use Vagrant here, because we have other roles that need kernel modules etc
  name: vagrant
  provider:
    name: virtualbox
lint:
  name: yamllint
platforms:
  # Here we specify our official archlinux/archlinux image
  - name: instance
    box: archlinux/archlinux
provisioner:
  name: ansible
  lint:
    name: ansible-lint
  # This option is important. The Ansible infrastructure roles use root on default.
  # So we need to gain privilege via sudo and become root for running all roles.
  connection_options:
    ansible_become: true
verifier:
  name: testinfra
  lint:
    name: flake8
```

`prepare.yml` includes some magic, regarding mirror setup, installing python
and a fresh restart.  We need this mirror setup tasks, because we are just
enabling all mirrors in our Arch Linux Vagrant box right now. This leads to
slow mirrors. I am going to
[fix](https://github.com/archlinux/arch-boxes/issues/81) this in a new
Arch-Boxes release. For now I just set static mirrors from which I know that
they are fast for my location.  In the second `prepare.yml` task we need to
install python for Ansible.  Consider that I use `pacman -Syu` here, because I
**want** a full system upgrade, everything else will lead us into trouble when
playing around with kernel modules (Arch Linux provides still no nice way to
use kernel modules when you've installed a new kernel). Due to the full system
upgrade, we need to reboot for making sure that we boot into the new kernel.


`infrastructure/roles/sshd/molecule/default/prepare.yml`
```yaml
---
- name: Prepare
  hosts: all
  gather_facts: false
  tasks:
    - name: Setup fast mirror
      raw: echo -e "Server = https://mirror.metalgamer.eu/archlinux/\$repo/os/\$arch\nServer = https://mirror.metalgamer.eu/archlinux/\$repo/os/\$arch\nhttps://ftp.spline.inf.fu-berlin.de/mirrors/archlinux/\$repo/os/\$arch" > /etc/pacman.d/mirrorlist
      become: true
    - name: Install python for Ansible
      raw: test -e /usr/bin/python || (pacman -Syu --noconfirm python)
      become: true
      changed_when: false
    - name: Reboot for kernel updates
      reboot:
```

The last important file is `test_default.py`. `test_default.py` stores our unit
tests for the Ansible roles. Right now I am just checking for an installed
`openssh` package and a running and enabled `sshd` daemon. The usage of
testinfra should be self-explanatory, however I didn't make experience with
more complex tasks like comparing templates yet. I can imagine that this will
become very tedious for us. The future will show if the usage of testinfra
suits our demands. If not we either use a different library or we need to stay
with Ansible and YAML linting + tests on clean VMs or Docker containers. Both
of them would be already far better than the current situation with no tests at
all.

`infrastructure/roles/sshd/molecule/default/tests/test_default.py`:
```python
import os

import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']
).get_hosts('all')


def test_openssh_is_installed(host):
    openssh = host.package("openssh")
    assert openssh.is_installed


def test_openssh_is_running_and_enabled(host):
    openssh = host.service("sshd")
    assert openssh.is_running
    assert openssh.is_enabled
```

For running our tests we can trigger `molecule test` from inside of our sshd
role directory. I haven't played around with `molecule converge` yet, but I
guess this is the command you would use for local Ansible development.
`molecule test` will trigger a clean environment on every test (destroying the
VM snapshot etc). This is pretty cost intensive and takes time.

If you are interested in this work, you can follow my branch on github:

[https://github.com/shibumi/infrastructure/tree/shibumi/molecule-tests](https://github.com/shibumi/infrastructure/tree/shibumi/molecule-tests)