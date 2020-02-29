---
title: "How to Handle Dotfiles"
date: 2020-02-29T16:14:00+01:00
draft: false
description: "How to handle your Linux/Mac dotfiles with git"
---

In this article I want to show how I handle my dotfiles and why I think it's the best way to handle them.
I tried different approaches for handling dotfiles in the past:

* puppet
* ansible
* home made shell script magic
* maybe a few more I don't remember, because i didn't use them so much.

So what's wrong with puppet or ansible? Don't get me wrong, I love config
management and I love using both for bigger infrastructure. The intonation lies
on **bigger infrastructure**. While I have to do with bigger infrastructure at
work I don't have that much infrastructure at home. At home I deal with one
Laptop and one Server. For the Server Ansible or Puppet makes sense, because I
want to do more than just dropping a few config files (installing webserver,
configuring sshd, etc).

Why do I not use puppet or ansible for my laptop? I tried it. I really wanted
too, but I find myself writing things twice. It started to be annoying, when
you have to deal with real file on your system and the corresponding templates.
In the end I always found myself, just editing the files directly, instead of
tweaking with the templates in the Ansible or Puppet repository. Instead of
reducing toil I found myself adding more toil through adding more layers of
abstract software, that I actually don't need. This applies for home made shell
script magic, too. Home made shell script magic for configuration management is
even more annoying, because instead of relying on standards you build something
on your own.  Some people maybe like this and maybe it's even a good training
for bash beginners, but for me it has been annoying too.

Why? Simply because I found myself fixing bugs that were not necessary, that's
why I changed to proper configuration management like puppet or ansible later
on and from proper configuration management to my current solution. How does my
current solution looks like? It's dead simple.

I use git with a whitelist. My whole home directory is just a big git directory
with a whitelist.  In this whitelist I have all files I want to monitor or
manage. When I move to a new laptop I just initialize my home directory with
this repository and I have all dotfiles where I need them. No templates are
involved nor any scripts that move things around.

The gitignore file can look like this:
```
*
!.gitignore
!.zshrc
!.config
!.config/sway/
!.config/sway/config
```

This small gitignore will only handle the gitignore file, my zshrc and my sway
config. You need to whitelist directories one by one, full paths are not
allowed. Then you can do just add these files to your repository, commit and
push them to one or more remotes. Why more than one remote? Backups. This way, if you push, you automatically push to more than one remote and you have a backup on a second server.

The command for adding a second git remote as backup is the following:
```bash
git remote set-url origin --push --add "${REMOTE}"
```
This is going to add a second remote server to your origin remote.

One last question I want to answer is: How do I setup such a repository from an
existing home directory and will it effect other git directories?  If you want
to set this up from an existing repository, you can create a repository
upstream and then use `git init` in your home directory to initialize a git
repository, then just set your gitignore with the whitelisted files and
directories and your remotes and you should be good. Other git repositories
shouldn't get affected by this, because they are blacklisted.

