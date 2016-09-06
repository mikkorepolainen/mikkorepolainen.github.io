---
layout: document
title: Docker Hosts
description: Notes about Docker Host management in various ways.
modified: 2016-05-15 23:59:00
relativeroot: ../../
permalink: documents/docker-hosts
type: document
tags:
- Docker
- Docker Hosts
category: documents
published: true
hidden: true
---

TODO Swarm
TODO CoreOS, OpenStack
TODO https://www.kontena.io/

Docker Machine
==============

Resources:

- [Official documentation](https://docs.docker.com/machine/)
- [Docker Machine]({% post_url 2016-09-05-docker-machine %})

Docker Machine can be used to quickly provision virtual machines for use as docker hosts or for controlling existing hosts (using the generic driver).
There is a selection of drivers available for both local and remote virtualization hosts/providers.
Check the [official documentation](https://docs.docker.com/machine/drivers/) for a list of available drivers and driver-specific documentation.

The tool also helps in configuring the command line tools to point to an imported docker host instance (`docker-machine env <vm-name>`) even if provisioning or management is not required.

Not suitable for production use due to the lack of support for moving machine connectivity configurations across workstations.
Only feasible use case is provisioning local machines for dev/test.

Swarm
=====

TODO https://docs.docker.com/engine/swarm/swarm-tutorial/
TODO docker swarm mode, how does "enabling swarm mode" affect the local environment?

Connecting to a Remote Docker Host with the CLI
===============================================

- Obtain the url address of the remote host e.g. `tcp://aa.bb.cc.dd:2376` (default port 2376).
- Obtain the TLS certificates for the host

TODO obtaining certs without docker-machine

After running the following commands you should be able to run docker commands against the remote host:

```
SET DOCKER_TLS_VERIFY=1
SET DOCKER_HOST=<host-url>
SET DOCKER_CERT_PATH=<path-to-cert-directory>
```
