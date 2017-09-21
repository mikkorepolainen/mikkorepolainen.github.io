---
layout: document
title: Installing docker
description: Docker installation instructions
modified: 2017-04-15 23:59:00
relativeroot: ../../
permalink: documents/docker-install
type: document
tags:
- Docker
category: documents
published: true
hidden: false
---

Overview
======

## Editions

TODO CE and EE differences (no private image repos on CE?!! based on feature comparison)

## Operating Systems

TODO Linux vs Windows Containers, switching etc.

Linux
====

TODO This section is outdated! Current official way is to download from Docker Store: <https://www.docker.com/docker-ubuntu>

Quick install: `curl -sSL https://get.docker.com/ | sh`

Add user to docker group for use without sudo:

- `sudo usermod -aG docker <user>`
- Restart the docker service (e.g. `sudo service docker restart` on Ubuntu)
- Log out and back in again.

Removing:

{% highlight bash %}
apt-get purge docker-engine
apt-get autoremove --purge docker-engine
rm -rf /var/lib/docker
{% endhighlight %}

Note that the last command removes also all volumes and configuration data from containers.

Additional tools must be installed separately, e.g. docker-compose, docker-machine.

Desktops
======

## Docker for Windows

Docker for Windows uses built-in virtualization technology (Hyper-V) under the hood, but requires Microsoft Windows 10 Professional or Enterprise 64-bit.
For older systems, try [docker toolbox](https://www.docker.com/products/docker-toolbox) that can run on VirtualBox.

 - Documentation: <https://docs.docker.com/docker-for-windows/>
 - Download: <https://www.docker.com/docker-windows>
 - Community forum: <https://forums.docker.com/c/docker-for-windows>

TODO enable virtualization extensions in BIOS for Hyper-V to function.

To install, download and run the installer `InstallDocker.msi`.
This installs the command line tools, sets up a VM (named MobyLinuxVM) on Hyper-V and installs a shell for controlling the VM (whale icon in status bar).

The whale icon on the status bar can be used to access virtual machine settings (CPUs, Memory, automatic startup)
and to shut down the virtual machine (exit).
The VM can be started again by running the tool from the menu.

The installation also sets up a DNS service that forwards the `docker` address to the VM (e.g. you can use  `http://docker:<port>` on the host to access a website running in a container).

The command line environment will point to the local VM by default.

Uninstalling the software also removes the automatically created virtual machine from Hyper-V.

## Docker for Mac OS X

Docker for Mac requires OSX Yosemite 10.10.3 or above.
For older systems, try [docker toolbox](https://www.docker.com/products/docker-toolbox) that can run on VirtualBox.

 - Documentation: <https://docs.docker.com/docker-for-mac/>
 - Download: <https://www.docker.com/docker-mac>
 - Community forum: <https://forums.docker.com/c/docker-for-mac>

## Docker Toolbox

TODO This section is probably outdated!

Download and install [docker toolbox](https://www.docker.com/products/docker-toolbox).
The toolbox contains the docker tools (including docker-machine and docker-compose), Kitematic (an UI for managing containers) and Oracle VirtualBox installer.

If you don't plan to run containers on top of a local VirtualBox instance, then you can leave VirtualBox unchecked in the installer (e.g. if you plan to use Hyper-V on windows).

### Local Container Host for Development

Running Kitematic spins up a new local VM called `default` on top of VirtualBox.
At the time of writing, the Kitematic UI only supports the VirtualBox driver and a local VM called `default`
(you can have a stab at the kitematic source code and compile it yourself though, see [here](http://agup.tech/2015/08/14/hacking-at-kitematic-with-hyper-v-on-windows-10/))).

Alternatively, you can run `docker-machine create --driver <driver name> <vm-name>` on the command line followed by `docker-machine start <vm-name>`.

Read [Docker Hosts]({% post_url /documents/2016-05-15-docker-hosts %}) for information on creating local hosts using docker-machine (e.g. creating a host on Hyper-V instead of VirtualBox on windows).

Servers
=====

TODO Separate packages now for different server OS brands: <https://www.docker.com/get-docker>.

Running Disposable Test Containers
============================

To get a container up with bash, run for example `docker run -it --rm ubuntu bash`. For an image with basic networking tools (e.g. `curl`) not included in the ubuntu image, run `docker run -it --rm joffotron/docker-net-tools`.

This should pull the image (may take a while) and start a container with the bash shell.
Type `exit` to stop the container.

Specifying the `--rm` flag causes the container to be removed automatically when the main process exits.

## More examples

### Nginx

To get a container up with a web server, run for example `docker run -d -p 8080:80 --name webtest nginx`.
This should start a blank nginx web server accessible on port 8080 of the docker host machine.
Then run `docker stop webtest` and `docker rm webtest` to kill and remove the container.

TODO --rm flag does not work in this example when running without `-d` because `Ctrl-C` does not stop the process and the stop command does not terminate the main process gracefully either.
Signaling the container with SIGQUIT stops the container but it still does not get removed.
