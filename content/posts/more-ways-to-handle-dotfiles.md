---
title: "More ways to handle dotfiles"
date: 2020-03-02T00:31:49+01:00
draft: false
description: "In this article I mention more ways to handle your dotfiles"
---

I've received plenty of feedback for my last blog article on how I handle
dotfiles, hence I've decided that I want to give a glimpse on how others are
managing their dotfiles.

Another way of handling dotfiles is using GNU stow as explained here:
[http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html](http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html)

With GNU stow it's possible to store your dotfiles in a separate directory and then symlink to the files in this directory via invoking `stow <directory name>`. Imagine the following structure:

```
home
`-- chris
    `-- dotfiles
        |-- sway
        |   `-- .config
        |       `-- sway
        |           `-- config
        `-- vim
            |-- .vim
            `-- .vimrc
```

Now you can do the following:
```
$ cd ~/dotfiles
$ stow sway
$ stow vim
```

Your resulting structure will look like this (the added files are symlinks):
```
home
`-- chris
    |-- .config
    |   `-- sway
    |       `-- config
    |-- dotfiles
    |   |-- sway
    |   |   `-- .config
    |   |       `-- sway
    |   |           `-- config
    |   `-- vim
    |       |-- .vim
    |       `-- .vimrc
    |-- .vim
    `-- .vimrc
```

Pretty nice and clean approach, if you ask me. Disadvantage is that you need
stow as additional program though.

The next approach is also interesting. It's described here:
[https://medium.com/toutsbrasil/how-to-manage-your-dotfiles-with-git-f7aeed8adf8b](https://medium.com/toutsbrasil/how-to-manage-your-dotfiles-with-git-f7aeed8adf8b)

This approach is not so different from mine (using git + gitignore as
whitelist). Here the author is using some features of git I did not know about.
First you create a bare git repository, then you set an alias for git with that
git directory as git-dir and your $HOME as work-tree. Next you set
`status.showUntrackedFiles` to no for this git repository and you are able to
manage your $HOME directory with git.

```
$ git init --bare $HOME/.dotfiles
$ alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
$ dotfiles config --local status.showUntrackedFiles no
$ dotfiles status
$ dotfiles add .vimrc
$ dotfiles commit -m "new vimrc"
```

If you want to setup your environment on a new computer, you can do the following:
```
$ git clone --bare https://github.com/USERNAME/dotfiles.git $HOME/.dotfiles
$ alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
$ dotfiles checkout
```

I actually prefer this approach over the one with stow. You don't need an
additional program and you don't end up with too much symlinks.  If I wouldn't
have managed my $HOME already, I would give this definitely a try, although I
would be afraid that I could add files to my repository that I don't want.
`showUntrackedFiles` is disabled, but you can still add new files or
directories. So if you use this approach make sure to use `git add -p` or `git
commit -v` for checking your chunks, before you add/commit/push them.

Last but not least, one of my readers told me about
[yadm](https://github.com/TheLocehiliosan/yadm).  Yadm is just another dotfiles
manager and supports GPG. Encryption is something that is missing in my current
approach (I sometimes miss it). Nevertheless it's another program, so I don't
want to get into too much details about yadm.
