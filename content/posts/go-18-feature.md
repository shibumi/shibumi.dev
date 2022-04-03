---
title: "Go 1.18 debug/buildinfo features"
date: 2022-04-03T18:31:24+02:00
draft: false
description: debug/buildinfo vcs information with Go 1.18
tags:
 - linux
 - devops
---

Hello and welcome to another blog article. Today, I would like to discuss one feature of Go 1.18, that I am interested in.
No, this will not be another article about generics. The feature I would like to write about is something that might be under the
radar for most people, but it still might be useful.

If you ever wrote a CLI app in Go you are very familiar with injecting information during the build process into global variables.
For instance:

```go
package main

import "fmt"

var Version string

func main() {
	fmt.Println("Version: ", Version)
}
```
```
❯ go build -ldflags="-X 'main.Version=v1.0.0'"
❯ ./test 
Version:  v1.0.0
```

Go 1.18 introduced support for version control systems for the `debug/buildinfo` package. Therefore, instead of using a global variable
and injecting the information during the build process, you can just let Go handle this:

```go
package main

import (
	"fmt"
	"runtime/debug"
)

func main() {
	info, _ := debug.ReadBuildInfo()
	fmt.Println(info)
}
```
```
❯ git tag v1.0.0
❯ go build .
❯ ./test
go	go1.18
path	github.com/shibumi/test
mod	github.com/shibumi/test	(devel)	
build	-compiler=gc
build	CGO_ENABLED=1
build	CGO_CFLAGS=
build	CGO_CPPFLAGS=
build	CGO_CXXFLAGS=
build	CGO_LDFLAGS=
build	GOARCH=amd64
build	GOOS=linux
build	GOAMD64=v1
build	vcs=git
build	vcs.revision=7e22e19e829d84170072d2459e5870876df495ed
build	vcs.time=2022-04-03T16:59:50Z
build	vcs.modified=false
```

Isn't this cool?! Go will automatically detect the version control system and will automatically add the current revision and time to it.
With this revision we are now able to get the version back:
```
❯ git describe --contains 7e22e19e829d84170072d2459e5870876df495ed
v1.0.0
```

The disadvantage of the new feature is that it is less customizable, but I don't really think this is an issue to be honest.
Moreover, there is no need to explicitly use `debug.ReadBuildInfo()` in your code, it is also possible to see the same information via:
```
❯ go version -m ./test 
./test: go1.18
	path	github.com/shibumi/test
	mod	github.com/shibumi/test	(devel)	
	build	-compiler=gc
	build	CGO_ENABLED=1
	build	CGO_CFLAGS=
	build	CGO_CPPFLAGS=
	build	CGO_CXXFLAGS=
	build	CGO_LDFLAGS=
	build	GOARCH=amd64
	build	GOOS=linux
	build	GOAMD64=v1
	build	vcs=git
	build	vcs.revision=7e22e19e829d84170072d2459e5870876df495ed
	build	vcs.time=2022-04-03T16:59:50Z
	build	vcs.modified=false
```

Another interesing side note: If your project uses external dependencies, these dependencies will get listed as well:
```
❯ go version -m ./embedmd 
./embedmd: go1.18
	path	github.com/campoy/embedmd
	mod	github.com/campoy/embedmd	v1.0.0	h1:V4kI2qTJJLf4J29RzI/MAt2c3Bl4dQSYPuflzwFH2hY=
	dep	github.com/pmezard/go-difflib	v1.0.0	h1:4DBwDE0NGyQoBHbLQYPwSUPoCMWR5BEzIk/f1lZbAQM=
	build	-compiler=gc
	build	CGO_ENABLED=1
	build	CGO_CFLAGS=
	build	CGO_CPPFLAGS=
	build	CGO_CXXFLAGS=
	build	CGO_LDFLAGS=
	build	GOARCH=amd64
	build	GOOS=linux
	build	GOAMD64=v1
```

By the way, this information survives if you decide to strip the binary!

To summarize this little article: 

* Go 1.18 provides fancy new build information
* VCS are automatically identified and used
* If you only care for revision and build date, you can stop injecting values.