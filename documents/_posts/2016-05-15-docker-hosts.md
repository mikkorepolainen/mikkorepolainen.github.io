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
- KVM
- Azure
- Containers
- Docker Hosts
category: documents
published: true
hidden: true
---

TODO Docker Machine, Swarm, OpenStack

Docker Machine
==============

Resources:

- [Official documentation](https://docs.docker.com/machine/)

Docker Machine can be used to quickly provision virtual machines for use as docker hosts.
There is a selection of drivers available for both local and remote virtualization hosts/providers.
Check the [official documentation](https://docs.docker.com/machine/drivers/) for a list of available drivers and driver-specific documentation.

TODO Suitability for production use?

Installation
------------

On linux, the docker-machine binary is a separate install (the docker toolbox and the docker for windows/mac tools both install docker-machine by default).
Check the latest version in [https://github.com/docker/machine/releases](https://github.com/docker/machine/releases) and follow the instructions, e.g.:

{% highlight bash %}
curl -L https://github.com/docker/machine/releases/download/v0.7.0/docker-machine-`uname -s`-`uname -m` >/usr/local/bin/docker-machine
chmod +x /usr/local/bin/docker-machine
{% endhighlight %}

Creating VMs
------------

Docker Machine supports a variety of drivers (local or remote).
The default operating system on the virtual machines depends on the driver.
On local instances, the OS is installed by default from the latest boot2docker.iso from [github](https://github.com/boot2docker/boot2docker/releases/).
A flavor of Ubuntu is installed by default on remote hosts.
Some drivers allow the image to be changed with a `--<driver>-image` flag or similar.

Check the [official documentation](https://docs.docker.com/machine/drivers/) for a list of available drivers and driver-specific documentation.
Run `docker-machine create --driver <driver name> -h` for a list of supported driver-specific parameters.

Examples
--------

#### Creating a local VM on VirtualBox

`docker-machine create --driver virtualbox <vm-name>`

TODO networking (bridged/nat)

For more options, refer to the [documentation](https://docs.docker.com/machine/drivers/virtualbox/).

#### Creating a local VM on Hyper-V

On modern computers running a recent version of windows, you can use the native Hyper-V platform instead of VirtualBox. This requires installing the HyperV virtualization windows features and enabling virtualization extensions in BIOS. Note that VirtualBox won't work while HyperV is enabled. TODO link to instructions.

Full instructions can be found [here](https://stebet.net/installing-docker-tools-on-windows-using-hyper-v/) and [here](https://blogs.technet.microsoft.com/canitpro/2014/03/10/step-by-step-enabling-hyper-v-for-use-on-windows-8-1/). Remember to run all commands in a terminal launched as administrator, including listing containers (hyper-v controlled instances won't show unless running as administrator).

In a nutshell, you must create a virtual network switch in Hyper-V Manager (local machine -> Virtual Switch Manager... -> New virtual network switch). For the switch type, you can select either external (bridge the VM through a NIC on your computer) or internal (accessible only from host). TODO [NAT switch](https://4sysops.com/archives/native-nat-in-windows-10-hyper-v-using-a-nat-virtual-switch/).

- To expose the VM to the surrounding network, select the External virtual switch type. In the switch configuration, select the appropriate External network (physical network adapter). The VM will be visible as <vm-name> in the surrounding network and gets an IP address from the network's dhcp service unless explicitly set. The VM is also vulnerable to changes in the network, e.g. if your computer is a laptop that you use in multiple networks. TODO does shutting down the machine help?
- An internal switch does not expose the machine to the surrounding network but does not permit access outside either by default. You can use internet connection sharing to facilitate outbound network connections [example](https://www.packet6.com/allowing-windows-8-1-hyper-v-vm-to-work-with-wifi/). (Note that if you already have an external virtual switch using the same physical interface, then it seems that you need to share the existing external virtual network interface instead of the physical one.) This way the VM is only accessible from the local machine but is not disturbed by changes in the network, which is likely, for example, on a laptop that you use in multiple networks.

Then run `docker-machine create --driver hyperv --hyperv-virtual-switch <Virtual Switch Name> <vm-name>` as administrator.

Virtual Switch Name defaults to the first virtual switch found.

For more options, refer to the [documentation](https://docs.docker.com/machine/drivers/hyper-v/).

#### Creating a local VM on KVM

Using docker-machine with KVM requires a third party driver, e.g.: [docker-machine-kvm](https://github.com/dhiltgen/docker-machine-kvm).
(For setting up a KVM environment, see [Virtualization With KVM]({% post_url 2015-10-07-virtualization-with-kvm %}).)

{% highlight bash %}
apt-get install libvirt-go
curl -L https://github.com/dhiltgen/docker-machine-kvm/releases/download/v0.6.0/docker-machine-driver-kvm > /usr/local/bin/docker-machine-driver-kvm
chmod +x /usr/local/bin/docker-machine-driver-kvm
{% endhighlight %}

Creating a VM: `docker-machine create --driver kvm --kvm-cpu-count 1 --kvm-disk-size 20000 --kvm-memory 1024 <vm-name>`

To expose the VM to the surrounding network by connecting the VM to an existing host bridge, add `--kvm-network <network name>` to the above command, where `network name` is the name of a host bridge added as a virtual network or reconfigure networking after creating the VM.
See [Virtualization With KVM]({% post_url 2015-10-07-virtualization-with-kvm %}#Bridged_Networking_Create_a_Virtual_Network_Using_the_Existing_Bridge).

The VM created this way has two network interfaces, one in the docker-machines network and the other on the virtual bridge or the specified network. The `docker-machine ip <vm-name>` command returns the ip address in the docker-machines network.
To find out the bridged ip address of the VM, use `docker-machine ssh <vm-name> "ip -one -4 addr show dev eth0|cut -f7 -d' '"`

#### Generic

Use this driver to control hosts with no direct support in docker-machine (or import existing hosts).

TODO example

For more options, refer to the [documentation](https://docs.docker.com/machine/drivers/generic/).

#### Creating a remote VM on Azure

`docker-machine create --driver azure --azure-subscription-id <Subscription ID> --azure-location <Region> --azure-size <Size> --azure-vnet <VNet> --azure-subnet <Subnet> --azure-resource-group <Resource Group> <vm-name>`

...where:

- <Subscription ID> is your Azure Subscription ID. (Search for Subscriptions in the management portal, look under settings in classic portal.)
- <Region> is the name of the azure region, e.g. "northeurope" (default is "westus"). See [available regions](https://azure.microsoft.com/en-us/regions/) TODO list of valid region codes or just need to guess based on region name?
- <Size> is the pricing tier of the VM, e.g. Basic_A1 (default is Standard_A2). See [VM pricing](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/)).
- <VNet> is the name of the virtual network (default is "docker-machine-vnet").
- <Subnet> is the name of the subnet in the virtual network (default is "docker-machine").
- <Resource Group> is the name of the resource group (default is "docker-machine").
- <vm-name> is 3-63 characters long and contains only lower-case alphanumeric characters and hyphens (a hyphen must be preceded and followed by an alphanumeric character). Otherwise creating the virtual hard disk image fails.
You will need to authenticate by opening a url in a browser and entering an authentication code (both are presented by the tool on the command line).

TODO creating a machine in a DevTest Lab. Using the lab VNet (Dtl<LabName>) and Resource Group (<LabName><Random code>) with or without specifying the existing Subnet (Dtl<LabName>Subnet) failed with error "Subnet 'xxx' is not valid in virtual network 'Dtl<LabName>'

TODO errors

Error checking TLS connection: Error checking and/or regenerating the certs: There was an error validating certificates for host "xxx:2376": tls: DialWithDialer timed out
You can attempt to regenerate them using 'docker-machine regenerate-certs [name]'.
Be advised that this will trigger a Docker daemon restart which will stop running containers.

Stored Azure credentials expired. Please reauthenticate.
Error checking TLS connection: Error creating Azure client: Error deleting stale token file: remove ...\xxx.json: The process cannot access the file because it is being used by another process.

For more options, refer to the [documentation](https://docs.docker.com/machine/drivers/azure/).

### Creating a remote VM on AWS

Removing a VM
-------------

`docker-machine rm -f <vm-name>`

This will also attempt to remove related resources such as virtual networking infrastructure that was created along with the virtual machine.
The command works also if the creation of the VM failed for some reason but docker-machine still thinks that the machine exists.

Updating configuration, importing existing machine
--------------------------------------------------

TODO

https://github.com/docker/machine/issues/1328

Interacting With the Docker Host
--------------------------------

Run `docker-machine ls` to view a list of machines managed by the current host.

To find out the ip address of the VM, use `docker-machine ip <vm-name>`.

NOTE: The host name of the VM seems to be `boot2docker` when first created, bridged to a network that uses DHCP for DNS.
Rebooting the VM seems to rectify the issue.

On linux you need to do `eval $(docker-machine env <vm-name>)` to set up the command line environment to point to the correct instance for subsequent docker commands.

On windows the corresponding command is `@FOR /f "tokens=*" %i IN ('docker-machine env <vm-name>') DO @%i` or `& "C:\Program Files\Docker Toolbox\docker-machine.exe" env <vm-name> | Invoke-Expression` on powershell.

Run `docker info` or `docker version` to show information on the host and to verify connectivity. Use `docker-machine ssh <vm-name>` to ssh to the VM.

Commands
--------

- `docker-machine ls` list VMs created using docker-machine on the current host
- `docker-machine ip <vm-name>` get ip address of VM
- `docker-machine ssh <vm-name>` ssh access
- `docker-machine inspect <vm-name>` machine information
- `docker-machine start <vm-name>` start
- `docker-machine stop <vm-name>` stop
- `docker-machine restart <vm-name>` restart
- `docker-machine kill <vm-name>` kill
- `docker-machine rm <vm-name>` remove

See more information in [docker-machine reference](https://docs.docker.com/machine/reference/).
