---
title: "How to trace Linux signals"
date: 2019-09-26T23:10:42+02:00
draft: false
description: "How to find out which process kills another process"
tags:
  - linux
---

Did you ever run into the problem, that a random process on your hosts is running amok and killing other processes? If so, you know how painful it is to find the process. But there is a solution for it: **systemtap**.

Just install **systemtap** on your system, write a small **stap** script for it and run it, and it will show you the evil process:

```bash
#!/usr/bin/stap
# sigkill.stp
# Copyright (C) 2007 Red Hat, Inc., Eugene Teo <eteo@redhat.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# /usr/share/systemtap/tapset/signal.stp:
# [...]
# probe signal.send = _signal.send.*
# {
# 	sig=$sig
# 	sig_name = _signal_name($sig)
# 	sig_pid = task_pid(task)
# 	pid_name = task_execname(task)
# [...]

probe signal.send {
  if (sig_name == "SIGKILL")
    printf("%s was sent to %s (pid:%d) by %s uid:%d\n",
           sig_name, pid_name, sig_pid, execname(), uid())
}
```

Run it with: `stap sigkill.stp`.
