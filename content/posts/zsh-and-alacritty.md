---
title: "Boost your productivity with ZSH and Alacritty"
date: 2021-05-21T18:32:48+02:00
draft: false
description:
tags:
 - linux
 - devops
---

In today's article I would like to shine some light on my local terminal setup. 
My setup consists of ZSH and [Alacritty](https://github.com/alacritty/alacritty).
ZSH or the Z shell is an extended variant of the Bourne again shell (bash). It comes
with a few useful features and extensions. Many people use the ZSH mostly for 
nice shell prompts or tab completion. This article will be about more advanced features,
like custom shortcuts. Alacritty is a terminal emulator written in Rust. It has
native GPU support. GPU support alone is a dealbreaker (there are not so many GPU supported
terminals in the Linux world besides Alacritty). The other feature I would like to focus on today
is Alacritty's new regex hints.

Let us start with the ZSH features. You can find the full configuration for my Z shell on Github:
[https://github.com/shibumi/hikari](https://github.com/shibumi/hikari).

What problem do I want to solve with my configuration? You might found yourself in a situation where you
wanted to quickly surround a word with single or double quotes. Just imagine a long URL with some
special characters. Of course it is possible to quickly move around with the ctrl+arrow keys or
alt+arrow keys, but there is a even faster solution: The ZSH command line editor (zshzle).

With zshzle you can modify the current ZSH buffer directly. This means that you are able to
define custom shortcuts for custom operations. For example the following snippet will
print the current date directly in the ZSH commandline via pressing ctrl+x and then d:

```bash
function insert-datestamp () { LBUFFER+=${(%):-'%D{%Y-%m-%d}'}; }
zle -N insert-datestamp
bindkey "^xd" insert-datestamp
```

The first line defines a function that modifies the LBUFFER. This is everything left of your cursor.
We use the LBUFFER to extend the LBUFFER with the current date in the format 2021-05-22.
The second line activates the extension and the third line binds the extension to a shortcut.
The shortcut "^xd" means ctrl+x and then d.

I have created the following extensions so far:

* inserting the current date
* adding a `sudo` in front of the command line
* jumping after the first word. Very useful for inserting flags
* surrounding words with single or double quotes
* deleting everything between single or double quotes
* copying the last word. Very useful in situations like: `cp foobar.txt foobar.txt.bak`.
* insert the last modified file. Useful for big folders and finding the last modified file automatically.

My github repository has a few gifs. Go check them out, they give a good feeling for the features.
Additionally, I can totally recommend writing your own ZSH configuration from scratch. You will learn
a lot while doing so and the prompt will react faster, too. Some other features of my ZSH configuration:

* simple prompt that works on every system (no special icons needed)
* loading of ZSH plugins like zsh-syntax-highlighting
* skim support (fuzzy-search for history or directory jumps. I love it)
* Tab completion of course

The next topic is about the new Alacritty regex hints. With Alacritty 0.8.0 you are able to match on custom
regex on your current buffer. The buffer consists of everything what you can see in the terminal.

Just think about how often you copy-pasted an IP address manually with your mouse. You have to take your
hand off from the keyboard.. move with the cursor on it.. click on it.. maybe even copy it (or have it directly in your buffer)
then move back and paste it. With Alacritty's new regex hints this can be done automatically.
The Alacritty configuration for this looks like this:

```yaml
hints:
  enabled:
    - regex: '([0-9a-f]{12,128})|([[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3})'
      action: Copy
      post_processing: false
      binding:
        key: U
        mods: Control|Shift
```

If you reload Alacritty with this configuration and you see an IP address on your buffer, just press ctrl+shift+u and you will
see little flags near the IP addresses. Press the button on your keyboard and you will trigger the defined action. In this case
the IP address will get copied to the clipboard, but you can directly paste it or choose a custom command, too. For
custom commands just replace `action: Copy` with `command: chromium` and it will open the matched word in the browser.

How is this useful? I use this for many cases. My regex consists of the following sub regexes right now:

* Kubernetes Resources (very useful for copying resources and then inspecting them. Pro tip: use `kubectl get resource --show-kind=true`)
* UUIDs
* IP addresses
* long hex strings
* URLs

If you come up with more ideas, feel free to write me. My full Alacritty configuration can be found here:  [https://github.com/shibumi/dotfiles/blob/master/.config/alacritty/alacritty.yml](https://github.com/shibumi/dotfiles/blob/master/.config/alacritty/alacritty.yml)

The screenshot shows a few hints in action (IP addresses, UUIDs, kubernetes resources and hex strings):
![screenshot of alacritty showing the regex feature](/img/img-2021-05-22-02-19-35.png)
