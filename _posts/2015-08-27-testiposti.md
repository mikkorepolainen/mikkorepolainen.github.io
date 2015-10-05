---
layout: default
title: Virtual Host Setup With KVM
description: This post describes the installation of a KVM virtualization environment on a Lenovo ThinkServer TS140
modified: 2015-02-26 00:00:00
permalink: virtual-host-setup-with-kvm
relativeroot: ../
---
Virtual Host Setup With KVM
====================

{{ page.description }}

[qemu-system-x86_64](http://manpages.ubuntu.com/manpages/trusty/en/man1/qemu-system-x86_64.1.html)  
[virt-install](http://manpages.ubuntu.com/manpages/trusty/en/man1/virt-install.1.html "test")  
[virsh](http://manpages.ubuntu.com/manpages/trusty/en/man1/virsh.1.html)  
[virt-clone](http://manpages.ubuntu.com/manpages/trusty/man1/virt-clone.1.html)
{: #an_id .a_class .b_class }

Virtual host installation
-------------------------

- BIOS upgrade using a bootable DOS usb stick (otherwise wouldn't boot with an USB FDD attached)
- Booted to BIOS (There's not much use for EasySetup disk unless installing a windows OS or VMware ESXi)
- Enabled virtualization extensions in CPU setup (VT)
- Enabled VT-d as well in case want to try something (direct exclusive device assignment to guests, see http://www.linux-kvm.org/page/How_to_assign_devices_with_VT-d_in_KVM)

- Install Ubuntu Server 14.04 (14.10 installed but wouldn't boot on old hardware so using the LTS version now even though hardware upgraded)
- Selected Basic Ubuntu Server, OpenSSH server, Gnome Desktop (turns out should have selected xfce instead of gnome)
- Left kvm unselected to see if there's a difference when installing through apt-get

Basic connectivity
------------------

- apt-get install ssh (if OpenSSH server not selected in install phase).
- apt-get install xrdp, connect from windows machine using Remote Desktop Connection (Module sesman-Xvnc)
- Apparently xrdp to 14.04 doesn't work with any other window manager but xfce, so followed these instructions http://www.tweaking4all.com/software/linux-software/use-xrdp-remote-access-ubuntu-14-04/
{% highlight bash linenos %}
	apt-get install xfce4
	modified /etc/xrdp/startwm.sh to start xfce4 session instead of gnome
		#!/bin/sh

		if [ -r /etc/default/locale ]; then
			. /etc/default/locale
			export LANG LANGUAGE
		fi

		startxfce4
{% endhighlight %}
--- No need to modify ~/.xsession (local X session) to get remote desktop connection to work
- Xrdp key map is not picked up by default from the server (at least not the Finnish layout), following instructions here http://askubuntu.com/questions/290453/xrdp-with-finnish-keyboard
{% highlight bash linenos %}
	cp /etc/xrdp/km-041d.ini /etc/xrdp/km-040b.ini
{% endhighlight %}
---	This copies the swedish keyboard layout as the finnish layout. Logging out and back in with remote desktop gives the correct key mappings.
---	No need to run "setxkbmap -layout fi" on local X session if correct layout set when installing (don't know how to get this working for purchased cloud servers though)
- If tab autocomplete doesn't work in xterm in an xfce session over xrdp, then edit the following file
{% highlight bash linenos %}
	~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
	Change <property name="&lt;Super&gt;Tab" type="string" value="switch_window_key"/>
	to <property name="&lt;Super&gt;Tab" type="empty"/>
{% endhighlight %}
	
KVM Installation & host configuration
-------------------------------------

http://www.linux-kvm.org/page/HOWTO1
https://help.ubuntu.com/community/KVM/Installation
http://xmodulo.com/use-kvm-command-line-debian-ubuntu.html
http://www.dedoimedo.com/computers/kvm-intro.html
http://fedoraproject.org/wiki/How_to_debug_Virtualization_problems

Checking hardware virtualization support
	egrep '(vmx|svm)' --color /proc/cpuinfo --> should display vmx or svm in red
	egrep -c '(vmx|svm)' /proc/cpuinfo --> should give non-zero result
	kvm-ok --> should give message saying
		INFO: /dev/kvm exists
		KVM acceleration can be used
	virt-host-validate --> should give message
		QEMU: Checking for hardware virtualization		: PASS
		QEMU: Checking for device /dev/kvm				: PASS
		QEMU: Checking for device /dev/vhost-net		: PASS
		QEMU: Checking for device /dev/net/tun			: PASS
		 LXC: Checking for Linux >= 2.6.26				: PASS
	lsmod | grep kvm --> should list either kvm_intel or kvm_amd
KVM and command line management tools (http://xmodulo.com/use-kvm-command-line-debian-ubuntu.html)
	ubuntu-virt-server
		qemu-kvm
		libvirt-bin
		openssh-server
	current user is added to libvirtd group -> use "adduser <user> libvirtd" to add other users if necessary (log out and back in)
Additional packages
	bridge-utils to manage bridged networking(brctl etc.)
	ubuntu-vm-builder (one option for building virtual machines)
	ubuntu-virt-mgmt
		virt-viewer (for viewing vms)
		virt-manager (GUI for VM management)
	virtinst (included in some of the packages before?)
Setup bridge for VM networking
	KVM networking in https://help.ubuntu.com/community/KVM/Networking
	and http://www.linux-kvm.org/page/Networking
	TODO bridge.png from http://hzqtc.github.io/2012/02/kvm-network-bridging.html
	apt-get install bridge-utils if not installed
	If network manager is in use, you may want to disable it (not necessary though).
		http://xmodulo.com/disable-network-manager-linux.html
		check: nmcli dev status --> device name in this case is em1 (this was a surprise but it seems biosdevname naming for network interfaces has changed so that mobo integrated interfaces are named from em1 upwards)
		stop network-manager --> don't do this unless on a local session, kills the network connectivity entirely
		echo "manual" | sudo tee /etc/init/network-manager.override
	edit /etc/network/interfaces --> disable primary interface (eth0/em1) unless controlled by network manager (no problem if it is), add bridge (with primary interface as bridged port)
		auto br0
		iface br0 inet dhcp
				bridge_ports em1
				bridge_stp off
				bridge_fd 0
				bridge_maxwait 0
	restart networking and check results
		/etc/init.d/networking restart
		ifconfig --> should show br0 with a valid ip address
		brctl show --> should show br0 connected to interface em1 and another bridge virbr0 (kvm private networking bridge, none of our concern here)
		nmcli dev status should show em1 as unmanaged (even without disabling network manager)
					--> after starting a guest vm, a virtual interface should show on the bridge as well (e.g. vnet0)
		
----------------------

Creating KVM Guests (domains)

http://www.linux-kvm.org/page/HOWTO1
http://www.dedoimedo.com/computers/kvm-intro.html
http://xmodulo.com/use-kvm-command-line-debian-ubuntu.html

Debian based systems have the script /usr/bin/kvm by default, that executes "qemu-system-x86_64 -enable-kvm <parameters>". Use the latter if the kvm command is not available.
About guest images
	http://www.linux-kvm.org/page/Tuning_KVM
	Processor features: use "-cpu host" with qemu to pass all host processor features to quest (don't use if need to have portable image)
	Use virtio for networking if available (rtl8139 and e1000 have better guest support but virtio has better performance)
	Use virtio for storage if available (best performance, but IDE has better support for guests)
	Easiest storage formats for images are qcow2 and raw. The latter gives better performance but reserves all allocated space when created. Disable cache when using raw.
	libvirtd logs from kvm commands are written into /var/log/libvirtd/qemu/<guest name>.log
	/var/lib/libvirt/images is the default location for both installation images and vm images in vmm. The directory and its contents are labeled with "virt_image_t" for SELinux compatibility (mandatory if using SELinux)
Bridged Networking	
	Each guest needs a separate mac address, below script can be used to generate https://help.ubuntu.com/community/KVM/Networking
		MACADDR="52:54:00:$(dd if=/dev/urandom bs=512 count=1 2>/dev/null | md5sum | sed 's/^\(..\)\(..\)\(..\).*$/\1:\2:\3/')"; echo $MACADDR
		virt-install and VMM autogenerate a valid mac address if not explicitly specified
	Virsh domain xml: https://help.ubuntu.com/community/KVM/Networking
		<interface type='bridge'>
		  <mac address='00:11:22:33:44:55'/>
		  <source bridge='br0'/>
		</interface>
	virt-install parameters: --network bridge=br0,model=virtio,[mac=<predefined mac address>]
Console access from host https://help.ubuntu.com/community/KVM/Access
	virsh ttyconsole <name> --> should give e.g. /dev/pts/<number>
	virt-install and VMM should create the following in domain xml by default
		<console type='pty'>
			<target port='0'/>
		</console>
	Use "echo $TERM" output on host to determine which terminal to use in the command (xterm below)
	On guest:
		Create file /etc/init/ttyS0.conf with contents:
			start on stopped rc RUNLEVEL=[2345]
			stop on runlevel [!2345]
			respawn
			exec /sbin/getty -L 115200 ttyS0 xterm
		start ttyS0
	On host:
		virsh connect <domain>
		Press enter to get login prompt
		use Ctrl + ] or Ctrl + 5 or Ctrl + "^¨~" to exit the console (depends on key map which escape key works http://superuser.com/questions/637669/how-to-exit-a-virsh-console-connection)
TODO kvm -usb -usbdevice tablet for libvirtd managed machines
	In VMM add new input device
	domain config xml:
		<input type='tablet' bus='usb'>
			<alias name='input0'/>
		</input>
	TODO virt-install options to get this??
TODO Share a disk/directory on host
Creating and installing a guest OS
	Need to have an X session on the host (because of the installation window)
	Creating a new image with qemu-img
		qemu-img create -f qcow2 vdisk.img 10G
		kvm -hda vdisk.img -cdrom /path/to/boot-media.iso -boot d  -m <memory megabytes>
		headless environment, additional steps http://www.oneunified.net/blog/Virtualization/HeadlessConsole.article
			add parameters "-vnc :2 -no-reboot"
			connect to TCP port 5902 of the host machine with a vnc viewer to complete the installation
		
	With VMM
		virt-manager or Virtual Machine Manager from system menu on xfce
		wants to install package qemu-system (not sure what for since all tools already installed)
		creating the image in /var/lib/libvirt/images/ by default (TODO can this be changed?)
		virsh list --> see image now running under virsh
		look in /var/log/libvirtd/qemu/<guest name>.log to see the kvm command used (here kvm-spice for some reason, though exact same script as kvm)
		TODO openshare/Temp/lab/UbuntuServer1_qemu.txt
		virsh dumpxml GuestName > filename.xml --> dump virsh definition xml
		TODO openshare/Temp/lab/ubuntuserver1.xml
		http://www.dedoimedo.com/computers/kvm-intro.html
	Import an image to virsh (https://www.redhat.com/archives/libvirt-users/2010-July/msg00033.html)
		install package virtinst if not installed
		virt-install --name UbuntuServer2 --ram 1024 --vcpus 2 --disk path=/kvm/UbuntuServer2.img,bus=virtio,format=qcow2 --import --noautoconsole --network bridge=br0,model=virtio --os-type=linux --os-variant=ubuntutrusty
		parameters:
			--name UbuntuServer2
			--ram 1024
			--vcpus 2
			--disk path=/kvm/UbuntuServer2.img,bus=virtio,format=qcow2
				add cache=none if using raw instead of qcow2
				add size=GB if creating new image and sparse=false to allocate full space
			--import (skips installation phase)
			--noautoconsole (prevents automatically connecting to console)
			--network bridge=br0,model=virtio,[mac=<predefined mac address>]
			--os-type=linux --os-variant=ubuntutrusty (use --os-variant list to get list of values)
		ttyconsole should be automatically created, check with virsh ttyconsole <name>
		set new host name if importing a copied image
			connect with virsh console <name>, VMM or stop the host on virsh and run the image using kvm
			edit both /etc/hostname and /etc/hosts on guest, set new host name in both files
			restart (can also change hostname
		shows up in virsh list and VMM
	See https://www.howtoforge.com/virtualization-with-kvm-on-ubuntu-12.10 for vmbuilder, LVM-based virtual machines
	TODO virt-install create new vm directly in one step, e.g. https://www.howtoforge.com/installing-kvm-guests-with-virt-install-on-ubuntu-12.04-lts-server
	TODO test with xp image (rebooting necessary)
	TODO test with a recent windows server image
TODO cloning images 
	gets new MAC and UUID
	VMM clone option
	virt-clone http://manpages.ubuntu.com/manpages/trusty/man1/virt-clone.1.html
Running an image
	Need to have an X session on the host to run graphical
	use -nographics for running in terminal (exit with Ctrl-A X)
	kvm vdisk.img -m <memory megabytes>
		-usb -usbdevice tablet (not much difference with xp at least)
	kvm
		-hda xp-curr.img
		-m 512
		-soundhw es1370
		-no-acpi
		-snapshot
		-localtime -boot c -usb -usbdevice tablet 
		-net nic,vlan=0,macaddr=00:00:10:52:37:48 -net tap,vlan=0,ifname=tap0,script=no
	TODO find ip of new guest https://rwmj.wordpress.com/2010/10/26/tip-find-the-ip-address-of-a-virtual-machine/

----------------------

Managing KVM Guests

TODO kvm management tools http://www.linux-kvm.org/page/Management_Tools
http://xmodulo.com/use-kvm-command-line-debian-ubuntu.html
http://www.dedoimedo.com/computers/kvm-intro.html
https://help.ubuntu.com/community/KVM/Virsh

Virsh commands
	virsh list --all --> shows all virtual images managed by virsh
	virsh define <guest domain xml> --> define a new guest / update existing
	virsh start GuestName
	virsh create <guest domain xml> --> define and start a new guest
	virsh dumpxml GuestName > filename.xml
	virsh destroy <guest name> --> hard power off a guest
	virsh shutdown <guest name> --> send shutdown signal
	virsh suspend <guest name> --> send suspend signal
	virsh resume <guest name> --> send resume signal
	virsh console <guest name> [devname] --> connect to console on guest (optional device name)
	virsh autostart <guest name> --> set guest to autostart on host start
	virsh dominfo <guest name> --> basic domain info
	TODO virsh save/restore and other stuff https://www.centos.org/docs/5/html/5.2/Virtualization/chap-Virtualization-Managing_guests_with_virsh.html
	use "--connect qemu:///system" argument to explicitly target the local (sometimes necessary)
	
	
