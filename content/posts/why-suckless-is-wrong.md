---
title:  "Why suckless is wrong"
date:   2016-10-19T13:13:13+01:00
draft: false
toc: true
---

Many people pointed me to this website [suckless](http://suckless.org/sucks/systemd) when a discussion about systemd
began. Now I got tired of summarizing why this blogpost is so wrong over
and over again. This time I want to write it down that other people have
arguments when they got pointed to this website. This can take a while
so feel free to grab a coffee or a cold mate.  
  
Let us begin with the second abstract:  
  
## What PID 1 Should Do
*When your system boots up the kernel is executing a given binary in its
known namespace. To see what are the only tasks the application running
as pid 1 has to do, see sinit. Just wait for child process to reap and
run some other init scripts.*  
  
First of all: **systemd** was **never**, is **not** and will **never**
be an init system. It is a system-**daemon**. Thats why it's called
system**d**. Moreover we don't live in 1980 anymore. The view and the
purpose of computers had changed completely since this time. We want to
have access on logs in pre-early-boot-time and we want to be sure that
several things are done during the boot process. Computers are not just
a server in some university anymore. Many people use GNU/Linux in their
workstations or notebooks nowadays.  

## systemd does {,U}EFI bootload
*Should systemd’s PID be changed from 1 to a negative, or imaginary,
number? It now exists before the kernel itself, during a bootup. See
also systemd-boot.*  
  
Again. system**d** is not only an init system. Is the same as if I said:
  
*Should grub's PID be changed from 4235 to a negative, or imaginary,
number? It Now exists before the kernel itself, during a bootup. See
also syslinux*  
  
As you see this sentence is absolutly ridiculous. Systemd has a
**module** and this **module** is managing the EFI entries in the EFI
bootloader. **systemd-boot** is not booting the system. It is just a
boot-manager! **EFI** does!  
  
## systemd replaces sudo and su
*Please note the command name, machinectl and its features at the
manpage. In exchange for a program which contains sudo, su and kill (and
does some functions which historically ssh/telnet did), bare metal users
have a tons of bloat and a lot of things to disable, if even possible,
useful only to people which deal with virtual machines.*  
  
First of all: **systemd-machined** or better **machinectl** will never
replace sudo or su. Do not worry. Secondly **machinectl** is totally
different than sudo or su. **machinectl** gets its information from
**polkit** via **dbus**. **polkit** is a much nicer way to define
permissions-rules. **sudo** and **su** has different weak points, one of
them is that **sudo** and **su** can not talk via **dbus** nor any other
IPC daemon. I think you know this moment when you forgot to type
**sudo** in front of a command. With **polkit** you don't have this
situation because the system service will just ask for a permission via
**IPC**. And yes.. you will need this for some stronger security
policies than just kernel-based permissions. You can find more about
this topic here:
[why-polkit](https://www.collabora.com/about-us/blog/2015/06/08/why-polkit-(or,-how-to-mount-a-disk-on-modern-linux))  
  
## systemd-journald can do log-rotate
*Being journal files binaries written with easily corruptable
transactions, does this feature make the log unreadable at times?*  
  
Nope. Sorry. It will not get unreadable. I am running systemd now for
years and I had never an unreadable log.  
  
## Transient units
*Temporary services, because we love to reinvent procps, forking, nohup
and lsof.*  
  
What is so wrong with this feature? I think it is a good idea when an
Administrator can pass environment-variables to a service or set
security features via kernel capabilities.  
  
## systemd does socat/netcat
  
This feature is being used in the socket-activation. Something that is
pretty awesome. Why do you want socket-activation? Think about the boot
process. Let us say we start different services at the same time in
parallel. (This is what systemd does because it is increasing the speed
a lot. What is nicer than a laptop that boots up in 0.5 seconds?). When
we start different services in parallel it can happen that a service is
for example earlier ready when the log daemon. In this case socket
activation rescues your day. Because with socket activation the other
service does not need to wait for the log daemon. Every output from this
service will be buffered in the activated socket and will be forwarded
to the log daemon when the log daemon is ready. 
  
## systemd-logind does sighup and nohup
*Logout is equivalent to shutting off the machine, so you will NOT have
any running program after logout, unless you inform your init system.*
  
Why should it be the other way around? When a user logs out from a
session I want that every process by this user is killed. Especially the
gnome desktop had the problem that even after logouts zombie processes
survived or other artifacts that burn your ram. You do not realize this
on your single-user-system but ask someone who is managing
infrastructure for thousands of users. You don't want to waste any
memory. And even when we say:  
  
*Ok! Let us do your way*
  
We will have one problem. We will allow every program to survive a user
session. You have to see it out of the blacklist-whitelist-view.
What is better a whitelist or a blacklist?
When I have 1000 of programs should I whitelist everyone and blacklist
just a few? What happens when I forgot to blacklist one? Can I blacklist
all programs on this planets via picking every program and analyzing it?
No, I can't and thats why we use a blacklist and whitelist the programs
that are allowed to stay running after logout. This way we can make sure
that only these whitelisted programs will run and not other stuff like
malware, zombie processes or the 16-years-old users porn torrents.  
  
## ystemd-nspawn can patch at will any kind of file in a container
*Paired with transient units and user escalation performable remotely,
this can mean that if you house VPS instances somewhere, your hosting
provider has means and tools to spy, modify, delete any kind of content
you store there. Encrypt everything, read your TOS.*  
  
First of all when I host stuff remotely there is no guarantee that it's
not bugged even with disk-encryption. Even with disk-encryption the guy
with hardware access could do harmful things and modify, delete, spy
your stuff. This feature is necessary if we want to use namespaces in
containers.  
  
## systemd does UNIX nice
  
Let me quote the first sentence from the README there this feature is
mentioned:  
  
*The LimitNICE= setting now optionally takes normal UNIX nice values
in addition to the raw integer limit value.*  
  
What is so wrong about when we can limit a nice level for a specific
service? Imagine a service that starts consuming a lot of memory. This
way we can limit this service when it happens and give the other
processes a better place in the scheduling.  
  
## systemd locks down /etc and makes it read-only
  
This is absolutly out of context. **systemd** uses a capability that is
called **ProtectSystem** with this capability I can reduce the access
for a specific service that doesn't need access to specific areas. This
means for /etc that /etc will be mounted read-only. But **only** for
this service. This way the service is not able to change configuration
files maliciously or unintentionally. I think this is a good feature to
secure your system.  
  
## systemd now does your DNS
  
We are not in North-Korea. DNS is something important nowadays that
every system that wants to do networking need. It was just an amount of
time that this will be included. Moreover you can turn that function off
and still use every other DNS service that you like. It's also important
for the nspawn-containers. They rely on a proper DNS service. And
mostly: The systemd developers can finally enforce DNSSEC everywhere
with this option. That's a good step to a more secure internet.  
  
## systemd hates when you adapt your system (graphics on other than vt1)
  
Support has borders. You can't support everything in a software and
standards are needed. The internet relies on standards because standards
make the world easy.  
  

