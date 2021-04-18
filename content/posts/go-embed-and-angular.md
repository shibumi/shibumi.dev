---
title: "Go Embed and Angular"
date: 2021-04-18T20:51:18+02:00
draft: false
description: "How to embed an Angular app into a Go binary"
tags:
 - linux
 - devops
---

Hi, there. Today's article will be a rather short article. In this article I would like to showcase
Go 1.16 new `embed` package. If you are familiar with Go you might know embedding functionality already from
famous other libraries like `go-bindata`. The problem with `go-bindata` has been that upstream vanished one day
and then multiple forks appeared and every company or person was doing their own thing with embedding assets
into Go programs. With the new `embed` package this shall be changed **and** embedding files shall be officially
supported and more easy in the future.

For this article I have picked a github project: [https://github.com/Shpota/go-angular](https://github.com/Shpota/go-angular).
Sasha's project is an excellent example on how we can make use of the new `embed` package.

The project consists of two important directories:

* server: includes all Go code
* webapp: includes the Angular App

Getting more into frontend development has been one of my main goals with this article, hence
forgive me if I write something wrong about it. The Angular app can be build with the following commands:

```
$ cd webapp
$ npm install
$ ./node_modules/.bin/ng build --prod
```

On default, this will produce a `dist` directory storing the 'compiled' Angular project.
In Sasha's version Sasha served this assets via a `http.Fileserver`:
```go
func (a *App) start() {
	a.db.AutoMigrate(&student{})
	a.r.HandleFunc("/students", a.getAllStudents).Methods("GET")
	a.r.HandleFunc("/students", a.addStudent).Methods("POST")
	a.r.HandleFunc("/students/{id}", a.updateStudent).Methods("PUT")
	a.r.HandleFunc("/students/{id}", a.deleteStudent).Methods("DELETE")
	a.r.PathPrefix("/").Handler(http.FileServer(http.Dir("./webapp/dist/webapp/")))
	log.Fatal(http.ListenAndServe(":8080", a.r))
}
```

The disadvantage of this approach is that you will end up with a Go binary and a separate, dedicated
`webapp/dist/webapp` directory with all static asset files. This might does not matter if you plan to serve
your application in a Docker image anyway, but a single Go binary can be useful sometimes for other deployment
scenarios.

Therefore I made a few modifications to use the new Go 1.16 `embed` package with this project.
If you like to skip directly to my changes feel free to check out the following link: [https://github.com/shibumi/go-angular](https://github.com/shibumi/go-angular).

First of all I have changed the output path for the Angular generated assets in the `angular.json` file via setting `"outputPath": "../server/static"`.
With this change Angular will move the static assets to a new `static` directory inside of the server directory.
Why do we need this? We need this, because the `embed` package does not support `../`, `./` or leading slashes, hence we cannot
import data from the webapp (one possible solution is to place a Go file in the webapp directory, but I have not tried this).

The next change I made was a slightly modification of the `app.go` file:
```go
// first I introduced a new global variable
//go:embed static
var static embed.FS

// .....

// Then I modified the start() function accordingly:

func (a *App) start() {
	a.db.AutoMigrate(&student{})
	a.r.HandleFunc("/students", a.getAllStudents).Methods("GET")
	a.r.HandleFunc("/students", a.addStudent).Methods("POST")
	a.r.HandleFunc("/students/{id}", a.updateStudent).Methods("PUT")
	a.r.HandleFunc("/students/{id}", a.deleteStudent).Methods("DELETE")
	// We need to strip the static directory from our path
	// for serving files in the index folder via the http.Fileserver()
	webapp, err := fs.Sub(static, "static")
	if err != nil {
		fmt.Println(err)
	}
	// We need to use Gorilla Mux' PathPrefix function here, because the Pathprefix
	// adds a wildcard to the route eg: /*, otherwise we would only route to "/"
	// Hence the error with 404-returning JS files before got thrown, because
	// Gorilla Mux had no route to these JS files.
	a.r.PathPrefix("/").Handler(http.FileServer(http.FS(webapp)))
	log.Fatal(http.ListenAndServe(":8080", a.r))
}
```

What is happening here? First I introduced a new global variable called `static` with type `embed.FS`. The important
part about this change is the go preprocessor-like statement before the variable declaration. With `//go:embed static`
we explain the Go compiler to embed the `static` directory in the current directory via the `embed` package. Note:
the missing space between `//` and `go` is important here! The next modification is the `start()` function.
We are now serving content from a directory, for example: `static/index.html`, thus we need to strip the `static`
directory name from it. This happens via the `fs.Sub` method. The last change is the use of `http.FS` instead of `http.Dir`.
We are dealing with a filesystem now, not a local directory anymore. If we now compile the Angular app and compile our Go binary
the Angular generated assets will get included into our Go binary and we have a single binary for deployment.

A few other changes I made were replacing the postgres driver against a sqlite (because i was lazy and just wanted a DB) and a new Dockerfile.
The new Dockerfile makes use of Google's distroless docker image. Distroless images are basically like docker scratch images, with the difference
that they provide tzdata and ca-certificates and other data applications might need. Everything else (libraries, shells, busybox utils, etc) is missing in these images. The final Dockerfile looks like this:

```Dockerfile
FROM node:12.11 AS ANGULAR_BUILD
RUN npm install -g @angular/cli@8.3.12
COPY webapp /webapp
WORKDIR webapp
RUN npm install && ng build --prod

FROM golang:1.16 as GO_BUILD
WORKDIR /go/src/app
ADD server /go/src/app
COPY --from=ANGULAR_BUILD /server/static /go/src/app
RUN go build -o /go/bin/app

FROM gcr.io/distroless/base
COPY --from=GO_BUILD /go/bin/app /
CMD ["/app"]
```
