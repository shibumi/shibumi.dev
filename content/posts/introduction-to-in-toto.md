---
title: "Introduction to in-toto"
date: 2020-05-08T14:06:23+02:00
draft: false
description: "This article gives a brief introduction to in-toto"
tags:
 - devops
---

Today I would like to talk about supply chains. I am participating as package
maintainer for several years for now and supply chains are one of the key
factors that were on my mind the most. As package maintainer I try to ensure,
that all users can be certain, that they are actually using what the project
owners had in their minds. This only works with a secure supply chain.  This
secure supply chain seems to be a big problem for many devs. At least I can't
explain on my own why many projects are lacking standards like signed tarballs.
Even if a signed tarball exists, there are so many other key factors that
ensure a secure supply chain and only because the developer or project owner
signs their tarballs this doesn't mean that the final product is really the
product that was in the project owners mind. A secure supply chain begins with the first
letter of code and ends with the deployment of the product on a target system.
Managing all of these steps is indeed difficult and I can fully understand why
devs have so much problems with it.  Especially if you have to deal with
various different artifacts on each step of your supply chain, like input and
output of compilation or code verification.

This is where **in-toto** jumps into place. **in-toto** specifies how a supply
chain can be secured and validated. The difference to the usual approach of just signing a tarball is,
that **in-toto** makes it possible to sign and validate every step of a supply chain.
The **in-toto** specification lists three main actors:

* The product owner
* The functionaries
* The client

The product owner describes the supply chain and enumerates all steps necessary
for the final product.  The functionaries are taking part in the supply chain,
they are usually developers or packagers or an automated system for
continuous integration.  The client is usually the person or system who
wants to use the final product and needs to validate each step for
making sure that the final product is the desired product and has not
been maliciously altered.

Each role is related to one **in-toto** component. The product owner writes the supply chain layout file.
The functionaries use the **in-toto** runtime for creating link metadata for each step of software "production".
The **in-toto** verify component will then be used to verify the final product.

On default **in-toto** specifies JSON as metadata format. The supply chain layout file looks as follows:

```json
    { "_type" : "layout",
       "expires" : "EXPIRES",
       "readme": "README",
       "keys" : {
           "KEYID" : "KEY",
            "...":"..."
        },
       "steps" : [
           {"...":"..."}
       ],
       "inspections" : [
           {"...": "..."}
       ]
    }
```

Each element should be self-descriptive. The `_type` just specifies, the type
of file. In this case a "layout".  The `expires` element sets an expiration
date. The `readme` can be used for documentation.  The list `keys` holds all
necessary public keys, that are needed for each supply chain step.  The element
`inspections` lists restrictions for each step within a link. This is going to
be used for validation by the client.

A step is declared as follows:

```json
    {
      "_name": "NAME",
      "threshold": "THRESHOLD",
      "expected_materials": [
         ["ARTIFACT_RULE"],
         "..."
      ],
      "expected_products": [
         ["ARTIFACT_RULE"],
         "..."
      ],
      "pubkeys": [
         "KEYID",
         "..."
      ],
      "expected_command": "COMMAND"
    }
```

Each step has a name and a threshold. The threshold is an integer stating how
many links of metadata must be provided to verify this step. This means, that
the threshold specifies how many different keys/functionaries are required to
sign off a step.  The number of link metadata stays in direct relationship to
the number of different keys/functionaries.  A step also consists of expected
materials and expected products (like input and output files), a list of
pubkeys and an expected command.  The expected materials and expected products
are needed for ensuring that a supply chain step has no missing or additional
content. The expected command declares the command that has been invoked in
this step. `artifact rules` are more complicated, these are rules, that can be
used for connecting steps and authorizing certain operations on an artifact
(for example the README can only be created in the create-documentation step).

This is how an inspection looks like:

```json
    {
      "_name": "NAME",
      "expected_materials": [
         ["ARTIFACT_RULE"],
         "..."
      ],
      "expected_products": [
         ["ARTIFACT_RULE"],
         "..."
      ],
      "run": "COMMAND"
    }
```

An inspection is not so different to a step. It comes with a name, expected artifacts and a command to run.
The `run` field will be used to spawn a new process in the validation system for creating link metadata.

This link metadata is structured as:

```json
 { "_type" :  "link",
   "_name" :  "NAME",
   "command" : "COMMAND",
   "materials": {
      "PATH": "HASH",
      "...": "..."
   },
   "products": {
      "PATH": "HASH",
      "...": "..."
   },
   "byproducts": {
        "stdin": "",
        "stdout": "",
        "return-value": ""
    }
 }
 ```

The link metadata provides a name, a command that gets executed by the functionary, the needed input/output artifacts and several byproducts.
The byproducts are interesting though. The byproducts specify a return value, stdin and stdout. The byproducts are not verified on default,
but they can be useful for further validation in the inspection step.

These are many different components and this may sound rather complicated, but actually it isn't. You can think about **in-toto** as a specification
and framework for validating each node in a graph. Each node needs a `link metadata` file that exactly states what happened and by whom. The layout file
declares the way through this graph and ensures that the exact way is being followed and by the right person. The inspection is the end step performed by the client, where the client validates, that the way has been used for generating this final product, while using the layout or way description of the trusted product owner.

The **in-toto** specification has much more than this. There exist sub layouts for allowing trusted actors to do a certain step and we haven't even talked about the artifact rules. I hope I could ignite a spark of interest in **in-toto**. If you want to read more about it, I really recommend the specification and the demo:

* [https://github.com/in-toto/docs/blob/v0.9/in-toto-spec.md](https://github.com/in-toto/docs/blob/v0.9/in-toto-spec.md)
* [https://github.com/in-toto/demo](https://github.com/in-toto/demo)

If you are interested in secure updates, you should also have a look on the **TUF** (The Update Framework). This is an excellent addition to **in-toto** and maybe a nice topic for another article. With **TUF** and **in-toto** together you can achieve complete end-to-end security.

* [https://theupdateframework.io/](https://theupdateframework.io/)

I would also really encourage to have a look on the blog article of one of my friends:

* [https://badhomb.re/ci/security/2020/05/01/tuf-in-toto.html](https://badhomb.re/ci/security/2020/05/01/tuf-in-toto.html)
