---
layout: document
title: Docker Images
description: Notes about docker image management with docker tools.
modified: 2016-05-15 23:59:00
relativeroot: ../../
permalink: documents/docker-images
type: document
tags:
- Docker
- Images
category: documents
published: true
hidden: true
---

Dockerfile & Image Fundamentals
===============================

TODO

- Use slim base image for smaller disk usage.
- Combine multiple commands in single RUN commands to minimize number of layers
- If the application startup command self-daemonizes (spawns a daemon process and quits), you must either configure the application not to self-daemonize (e.g. `nginx -g 'daemon off'`) so that the main process does not exit or find an alternative workaround. Otherwise the container will also exit.

Building the Image
==================

- `docker build -t <image-name> <build-context-path>` Build an image. Build context path is where the Dockerfile is located (e.g. `.` if in current directory) <sub>[reference](https://docs.docker.com/engine/reference/commandline/build/)</sub>.

TODO On windows, you get the following message when building images for non-windows hosts: SECURITY WARNING: You are building a Docker image from Windows against a non-Windows Docker host. All files and directories added to build context will have '-rwxr-xr-x' permissions. It is recommended to double check and reset permissions for sensitive files and directories.

Managing Images
===============

- `docker images` List available images <sub>[reference](https://docs.docker.com/engine/reference/commandline/images/)</sub>.
- `docker rmi <image-name>` Remove image <sub>[reference](https://docs.docker.com/engine/reference/commandline/rmi/)</sub>.

### Dangling Images

In some situations, the image build process can leave untagged and unreferenced images behind. These images are shown in the image list with both repository and tag set to `<none>`. These dangling images can be pruned with the command `docker rmi $(docker images -f "dangling=true" -q)`.
[See here](http://www.projectatomic.io/blog/2015/07/what-are-docker-none-none-images/) for more info.

The equivalent command in a windows shell is `@FOR /f "tokens=*" %i IN ('docker images -f "dangling=true" -q') DO docker rmi %i`.

TODO repos & naming
===================
