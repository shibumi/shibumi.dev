---
title: "Zsh Performance"
date: 2019-07-21T21:45:05+02:00
draft: false
---

I use `zsh` for a pretty long time now. It began with `zsh` + `grml`
configuration, went over the famous `powerlevel9k` (where I helped implementing
a few features like `svn` support) and currently ended with my own `zsh`
configuration: ![Hikari-ZSH](https://github.com/shibumi/hikari-zsh)

I have to admit I have been quite happy with `powerlevel9k`. It had a rich
feature set and I have been in love with all these shiny `UTF-8` icons and
powerline graphics. Just one thing bothered me: **performance**. It has been an
absolutly no-go for me, that I had to wait for my zsh between inputs. I am not
a speed fetishist, but I expect a good shell to give feedback at a pace of
`<400ms`. This is called the `Doherty Threshold` and ensures a good user
experience (UX). Everything above this threshold will let the user wait and
waiting means frustration. So I developed the idea of a new `zsh` configuration
that fits my needs. In the end I landed on a few snippets of the `grml`
configuration flavored with own functions, an own prompt and a few unique
keyboard shortcuts, like surround features for quotes. But how do we measure
`zsh` performance? Well, it's quite easy just put this line before **all** zsh
configuration: `zhmod zsh/zprof`. Another way to measure startup time is: `time
zsh -i -c exit`.
