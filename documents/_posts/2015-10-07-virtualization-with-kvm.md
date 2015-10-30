---
layout: document
title: Virtualization With KVM
description: Installing and using a KVM virtualization environment on a Lenovo ThinkServer TS140 with Ubuntu 14.04 LTS
modified: 2015-10-19 01:22:00
relativeroot: ../../
permalink: documents/virtualization-with-kvm
type: document
tags:
- KVM
- QEMU
- Linux
- Virtualization
category: documents
content-links:
- <a href="#hw">Hardware & BIOS Setup</a>
- <a href="#os">Operating System</a>
- <a href="#rdp">Remote Desktop Connectivity</a>
- <a href="#kvm-inst">KVM Installation & Host Configuration</a>
- <a href="#kvm-guests">Creating KVM Guests (Domains)</a>
- <a href="#kvm-management">Managing KVM Guests</a>
- <a href="#references">References & Resources</a>
---
{{ page.title }}
====================

This document contains the steps required for installing and configuring a KVM virtual host server
for use as virtualized development lab environment.
The main requirements were exposing all virtual machines to the local area network (bridged networking)
and being able to connect to the host from windows clients using the Remote Desktop Protocol.
The underlying hardware at the time of writing was a Lenovo ThinkServer TS140
and the chosen operating system was Ubuntu Server 14.04 LTS.

<a name="hw"></a>Hardware & BIOS Setup
--------------
- BIOS upgrade using a bootable DOS usb stick. Without the BIOS upgrade, system boot invariably failed if an external USB FDD was attached.
- Boot to BIOS. There's also an option to use an EasySetup disk, but apparently it's only useful when installing a windows OS or VMware ESXi.
- Enable virtualization extensions in CPU setup (VT)
- Enable VT-d as well if direct exclusive device assignment to guests is needed
(see [here](http://www.linux-kvm.org/page/How_to_assign_devices_with_VT-d_in_KVM)).
{: #an_id .a_class .b_class }

<a name="os"></a>Operating System
-------------------------

Install Ubuntu Server 14.04 LTS

- Basic Ubuntu Server
- OpenSSH server
- Xfce instead of gnome for RDP connectivity (gnome [does not work well](http://www.tweaking4all.com/software/linux-software/use-xrdp-remote-access-ubuntu-14-04/) with RDP on Ubuntu 14.04)
- KVM is left unselected in this phase and installed through apt-get later

**Installing Xfce Manually**

If you have an existing system without xfce, run `apt-get install xfce4`.
Then, modify `/etc/xrdp/startwm.sh` to start xfce4 session instead:

{% highlight bash %}
#!/bin/sh  

if [ -r /etc/default/locale ]; then
  . /etc/default/locale
  export LANG LANGUAGE
fi

startxfce4
{% endhighlight %}

This way there's no need to modify `~/.xsession` (local X session) to get remote desktop connection to work

<a name="rdp"></a>Remote Desktop Connectivity
----------------------

###Remote Desktop Server

Install xrdp:

{% highlight bash %}
apt-get install xrdp
{% endhighlight %}

Connect using a remote desktop client (Module sesman-Xvnc).

###Keyboard Mappings

The Xrdp key map is not picked up by default from the server if using an "exotic" keyboard layout (like finnish) on the server.

For finnish keyboard layout, copy the swedish keyboard layout as the finnish layout:  
`cp /etc/xrdp/km-041d.ini /etc/xrdp/km-040b.ini`.  
Logging out and back in with remote desktop should give the correct default key mappings automatically after this.

If the above does not work automatically, or if using a different keyboard layout than on the server, you need to run `setxkbmap -layout fi` on the local X session each time.
<span class="marker">TODO</span> Can configure in `~/.xsession`? Would be useful for managed cloud servers where server keyboard layout cannot be changed.

More detailed instructions [here](http://askubuntu.com/questions/290453/xrdp-with-finnish-keyboard).

###XTerm Autocomplete

If tab autocomplete doesn't work in xterm in an xfce session over xrdp, then edit the following file:  
`~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml`.

Change  
`<property name="&lt;Super&gt;Tab" type="string" value="switch_window_key"/>`  
to  
`<property name="&lt;Super&gt;Tab" type="empty"/>`

<a name="kvm-inst"></a>KVM Installation & Host Configuration
-------------------------------------

###Checking Hardware Virtualization Support

`egrep '(vmx|svm)' --color /proc/cpuinfo` should display vmx or svm in red.

`egrep -c '(vmx|svm)' /proc/cpuinfo` should give non-zero result.

`kvm-ok` should give message saying:

> INFO: /dev/kvm exists  
> KVM acceleration can be used
{: .terminal}

`virt-host-validate` should give message:

> QEMU: Checking for hardware virtualization		: PASS  
> QEMU: Checking for device /dev/kvm				: PASS  
> QEMU: Checking for device /dev/vhost-net		: PASS  
> QEMU: Checking for device /dev/net/tun			: PASS  
> LXC: Checking for Linux >= 2.6.26				: PASS
{: .terminal}

`lsmod | grep kvm` should list either kvm_intel or kvm_amd

###Installing KVM and Command Line Management Tools

Install the following packages using apt-get:

- `ubuntu-virt-server` metapackage that contains:
	- `qemu-kvm`
	- `libvirt-bin`
	- `openssh-server`
- `bridge-utils` to manage bridged networking (brctl etc.)
- `ubuntu-vm-builder` (one option for building virtual machines)
  - `python`
  - `python-vm-builder`
- `ubuntu-virt-mgmt` metapackage that contains:
	- `virt-viewer` (for viewing vms)
	- `virt-manager` (GUI for VM management)
- `virtinst`
- `qemu-system`

The current user is added to libvirtd group automatically. Use `adduser <user> libvirtd` to add other users if necessary (log out and back in).

###Setup Bridge for VM Networking

Setting up the bridge requires the bridge-utils package installed in the previous section.
The bridge connects the virtual machines' virtual interfaces directly to the local area network
through the host server's primary network interface as if the virtual machines were
physically present in the local area network along with the host.

{% include figure.html id="figure1" url="../images/kvm-virtualization-bridge.png" caption="Figure 1: Network Bridge" description="The bridge binds the network \"taps\" of the VMs to the physical network interface. Image taken from http://hzqtc.github.io/2012/02/kvm-network-bridging.html" %}

Check the device name of the primary network interface using `nmcli dev status`.
The device name in this case is em1 (biosdevname naming for integrated network interfaces).

> If network manager is in use, you may want to [disable it](http://xmodulo.com/disable-network-manager-linux.html) before continuing (not necessary though).
> 
> On a local session, run `stop network-manager` (don't do this unless on a local session, kills the network connectivity entirely)
> and `echo "manual" | sudo tee /etc/init/network-manager.override`
{: .note }

Edit `/etc/network/interfaces` to disable primary interface (eth0/em1) unless controlled by network manager (no problem if it is), add bridge (with primary interface as bridged port)

{% highlight bash %}
auto br0
iface br0 inet dhcp
    bridge_ports em1
    bridge_stp off
    bridge_fd 0
    bridge_maxwait 0
{% endhighlight %}

Restart networking `/etc/init.d/networking restart`

`ifconfig` should show br0 with a valid ip address

`brctl show` should show br0 connected to interface em1 and another bridge virbr0 (kvm private networking bridge, none of our concern here)

`nmcli dev status` should show em1 as unmanaged (even without disabling network manager)

After starting a guest vm, a virtual interface should show on the bridge as well (e.g. vnet0)

<a name="kvm-guests"></a>Creating KVM Guests (Domains)
----------------------

> Debian based systems have the script `/usr/bin/kvm` by default, that executes
> `qemu-system-x86_64 -enable-kvm <parameters>`. Use the latter if the kvm command is not available.
{: .note }

###About Guest Images

- [KVM Tuning]
- Processor features: use `-cpu host` with qemu to pass all host processor features to quest
(don't use if need to have portable image).
- Use virtio for networking if available (rtl8139 and e1000 have better guest support but virtio
has better performance)
- Use virtio for storage if available (best performance, but IDE has better support for guests)
- Easiest storage formats for images are qcow2 and raw. The latter gives better performance but
reserves all allocated space when created. Disable cache when using raw.
- libvirtd logs from kvm commands are written into `/var/log/libvirtd/qemu/<guest name>.log`
- `/var/lib/libvirt/images` is the default location for both installation images and vm images in vmm.
The directory and its contents are labeled with `virt_image_t` for SELinux compatibility (mandatory if
using SELinux)

###Bridged Networking	

Each guest needs a separate mac address. `virt-install` and VMM autogenerate a valid mac address if not explicitly specified.
Otherwise, the below script can be used to generate valid mac addresses ([KVM Networking]).

{% highlight bash %}
MACADDR="52:54:00:$(dd if=/dev/urandom bs=512 count=1 2>/dev/null | md5sum | sed 's/^\(..\)\(..\)\(..\).*$/\1:\2:\3/')"; echo $MACADDR
{% endhighlight %}

Virsh domain xml:

{% highlight xml %}
<interface type='bridge'>
  <mac address='00:11:22:33:44:55'/>
  <source bridge='br0'/>
</interface>
{% endhighlight %}

`virt-install` parameters: `--network bridge=br0,model=virtio,[mac=<predefined mac address>]`

###Console Access to Linux Guest From Host

`virsh ttyconsole <name>` should give e.g. `/dev/pts/<number>`

`virt-install` and VMM should create the following in domain xml by default

{% highlight xml %}
<console type='pty'>
	<target port='0'/>
</console>
{% endhighlight %}

Use `echo $TERM` output on host to determine which terminal to use in the command (xterm below)

See [KVM Access] for more details.

**On Guest**

Create file `/etc/init/ttyS0.conf` with contents:
{% highlight bash %}
start on stopped rc RUNLEVEL=[2345]
stop on runlevel [!2345]
respawn
exec /sbin/getty -L 115200 ttyS0 xterm
{% endhighlight %}

Execute `start ttyS0`

**On Host**

Execute `virsh connect <domain>`. Press enter to get login prompt.  

Use `Ctrl + ]` or `Ctrl + 5` or `Ctrl + [^¨~]` to exit the console (depends on key map which escape
key works, see [here](http://superuser.com/questions/637669/how-to-exit-a-virsh-console-connection)).

###Mouse Integration

<mark>TODO</mark>
http://blog.bodhizazen.net/linux/kvm-mouse-integration/  
https://apps.cndls.georgetown.edu/wikis/people/nje5/wiki/Setup_tablet_for_mouse_for_KVM_virtual_machines  
https://lime-technology.com/forum/index.php?topic=36496.0

kvm -usb -usbdevice tablet for libvirtd managed machines  
In VMM add new input device  
domain config xml:

{% highlight xml %}
<input type='tablet' bus='usb'>
  <alias name='input0'/>
</input>
{% endhighlight %}

<span class="marker">TODO</span> virt-install options to get this??

###Share a disk/directory on host

<mark>TODO</mark>

###Creating a Disk Image and Installing a Guest OS

> Installation of guest OSes from cds, dvds or iso images usually requires that the user is able
> to interact with the operating system console (display, keyboard, mouse).
> The most straightforward way to accomplish this is to have an X session on the host (either physically
> or remotely).
> Guest installation in a headless environment requires a little bit more effort.
{: .note }

**With qemu-img**

{% highlight bash %}
qemu-img create -f qcow2 vdisk.img <disk size gigabytes>G
kvm -hda vdisk.img -cdrom /path/to/boot-media.iso -boot d  -m <memory megabytes>
{% endhighlight %}

In a headless environment, [additional steps are needed](http://www.oneunified.net/blog/Virtualization/HeadlessConsole.article)

- Add the following parameters to the kvm command: `-vnc :XX -no-reboot` where XX is the vnc display number (e.g. 2) which corresponds to a tcp port number in the range 59XX (e.g. 5902). The -no-reboot switch prevents the OS from rebooting automatically after installation.
- Connect to TCP port 59XX of the host machine (e.g. 5902) with a vnc viewer to complete the installation.

The resulting image can be imported to be managed under virsh using `virt-install`
with the parameter `--import` which skips the installation phase. E.g.:

`virt-install --name <domain> --ram 1024 --vcpus 2 --disk path=/kvm/<path-to-image>,bus=virtio,format=qcow2 --import --noautoconsole --network bridge=br0,model=virtio --os-type=linux --os-variant=ubuntutrusty`

See the section for virt-install below for more info.

**With VMM**

Launch `virt-manager` or Virtual Machine Manager from system menu on xfce.
The tool creates images in `/var/lib/libvirt/images/` by default (<span class="marker">TODO</span> can this be changed?)
Execute `virsh list` to see the image now running under virsh.

> VMM wants to install package qemu-system on the first run. packages.ubuntu.com says it contains "QEMU full system emulation binaries."
> <span class="marker">TODO</span> Why not included in metapackages?
{: .note}

Curious people can look in `/var/log/libvirtd/qemu/<guest name>.log` to see the kvm command used for the installation.

{% highlight bash %}
/usr/bin/kvm-spice -name UbuntuServer1
	-S
	-machine pc-i440fx-trusty,accel=kvm,usb=off
	-m 1024
	-realtime mlock=off
	-smp 2,sockets=2,cores=1,threads=1
	-uuid 87da8396-5ef0-f851-aa86-e680ba49c882
	-no-user-config
	-nodefaults
	-chardev socket,id=charmonitor,path=/var/lib/libvirt/qemu/UbuntuServer1.monitor,server,nowait
	-mon chardev=charmonitor,id=monitor,mode=control
	-rtc base=utc
	-no-shutdown
	-boot strict=on
	-device piix3-usb-uhci,id=usb,bus=pci.0,addr=0x1.0x2
	-drive file=/var/lib/libvirt/images/UbuntuServer1.img,if=none,id=drive-virtio-disk0,format=qcow2
	-device virtio-blk-pci,scsi=off,bus=pci.0,addr=0x5,drive=drive-virtio-disk0,id=virtio-disk0,bootindex=1
	-drive if=none,id=drive-ide0-1-0,readonly=on,format=raw
	-device ide-cd,bus=ide.1,unit=0,drive=drive-ide0-1-0,id=ide0-1-0
	-netdev tap,fd=24,id=hostnet0,vhost=on,vhostfd=25
	-device virtio-net-pci,netdev=hostnet0,id=net0,mac=52:54:00:67:6a:66,bus=pci.0,addr=0x3
	-chardev pty,id=charserial0
	-device isa-serial,chardev=charserial0,id=serial0
	-vnc 127.0.0.1:0
	-device cirrus-vga,id=video0,bus=pci.0,addr=0x2
	-device intel-hda,id=sound0,bus=pci.0,addr=0x4
	-device hda-duplex,id=sound0-codec0,bus=sound0.0,cad=0
	-device virtio-balloon-pci,id=balloon0,bus=pci.0,addr=0x6
{% endhighlight %}

Execute `virsh dumpxml <guest name> > <filename>.xml` to dump the virsh definition xml.

{% highlight xml %}
<domain type='kvm'>
  <name>UbuntuServer1</name>
  <uuid>87da8396-5ef0-f851-aa86-e680ba49c882</uuid>
  <memory unit='KiB'>1048576</memory>
  <currentMemory unit='KiB'>1048576</currentMemory>
  <vcpu placement='static'>2</vcpu>
  <os>
    <type arch='x86_64' machine='pc-i440fx-trusty'>hvm</type>
    <boot dev='hd'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <pae/>
  </features>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>
  <devices>
    <emulator>/usr/bin/kvm-spice</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/var/lib/libvirt/images/UbuntuServer1.img'/>
      <target dev='vda' bus='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
    </disk>
    <disk type='block' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <target dev='hdc' bus='ide'/>
      <readonly/>
      <address type='drive' controller='0' bus='1' target='0' unit='0'/>
    </disk>
    <controller type='usb' index='0'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x2'/>
    </controller>
    <controller type='pci' index='0' model='pci-root'/>
    <controller type='ide' index='0'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x1'/>
    </controller>
    <interface type='bridge'>
      <mac address='52:54:00:67:6a:66'/>
      <source bridge='br0'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>
    <serial type='pty'>
      <target port='0'/>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
    <input type='mouse' bus='ps2'/>
    <input type='keyboard' bus='ps2'/>
    <graphics type='vnc' port='-1' autoport='yes'/>
    <sound model='ich6'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>
    </sound>
    <video>
      <model type='cirrus' vram='9216' heads='1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
    </video>
    <memballoon model='virtio'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x0'/>
    </memballoon>
  </devices>
</domain>
{% endhighlight %}

**With virt-install**

Import an image to virsh (https://www.redhat.com/archives/libvirt-users/2010-July/msg00033.html)

<span class="marker">TODO</span> -c <path-to-device-or-iso> https://www.howtoforge.com/installing-kvm-guests-with-virt-install-on-ubuntu-12.04-lts-server

- virt-install --name UbuntuServer2 --ram 1024 --vcpus 2 --disk path=/kvm/UbuntuServer2.img,bus=virtio,format=qcow2 --import --noautoconsole --network bridge=br0,model=virtio --os-type=linux --os-variant=ubuntutrusty
- parameters:
  - --name UbuntuServer2
  - --ram 1024
  - --vcpus 2
  - --disk path=/kvm/UbuntuServer2.img,bus=virtio,format=qcow2
    -	add cache=none if using raw instead of qcow2
    -	add size=GB if creating new image and sparse=false to allocate full space
  - --import (skips installation phase)
  - --noautoconsole (prevents automatically connecting to console)
  - --network bridge=br0,model=virtio,[mac=<predefined mac address>]
  - --os-type=linux --os-variant=ubuntutrusty (use --os-variant list to get list of values)

ttyconsole should be automatically created, check with virsh ttyconsole <name>
shows up in virsh list and VMM

<span class="marker">TODO</span> vm-builder  
See https://www.howtoforge.com/virtualization-with-kvm-on-ubuntu-12.10 for vmbuilder, LVM-based virtual machines

<span class="marker">TODO</span> test with xp image (rebooting necessary)  
<span class="marker">TODO</span> test with a recent windows server image

###Cloning Images

<mark>TODO</mark>

- gets new MAC and UUID
- VMM clone option
- virt-clone http://manpages.ubuntu.com/manpages/trusty/man1/virt-clone.1.html

set new host name if importing a copied image with virt-install

- connect with virsh console <name>, VMM or stop the host on virsh and run the image using kvm
- edit both /etc/hostname and /etc/hosts on guest, set new host name in both files
- restart (can also change hostname

###Running an image without virsh

<mark>TODO</mark>

- Need to have an X session on the host to run graphical
- use `-nographics` for running in terminal (exit with `Ctrl-A` `X`)
- kvm vdisk.img -m <memory megabytes>
	-	`-usb -usbdevice tablet` (not much difference with xp at least)

```
kvm
		-hda xp-curr.img
		-m 512
		-soundhw es1370
		-no-acpi
		-snapshot
		-localtime -boot c -usb -usbdevice tablet 
		-net nic,vlan=0,macaddr=00:00:10:52:37:48 -net tap,vlan=0,ifname=tap0,script=no
```

<span class="marker">TODO</span> find ip of new guest https://rwmj.wordpress.com/2010/10/26/tip-find-the-ip-address-of-a-virtual-machine/

<a name="kvm-management"></a>Managing KVM Guests
----------------------

<span class="marker">TODO</span> kvm management tools http://www.linux-kvm.org/page/Management_Tools

Virsh commands

-	virsh list --all --> shows all virtual images managed by virsh
-	virsh define <guest domain xml> --> define a new guest / update existing
-	virsh start GuestName
-	virsh create <guest domain xml> --> define and start a new guest
-	virsh dumpxml GuestName > filename.xml
-	virsh destroy <guest name> --> hard power off a guest
-	virsh shutdown <guest name> --> send shutdown signal
-	virsh suspend <guest name> --> send suspend signal
-	virsh resume <guest name> --> send resume signal
-	virsh console <guest name> [devname] --> connect to console on guest (optional device name)
-	virsh autostart <guest name> --> set guest to autostart on host start
-	virsh dominfo <guest name> --> basic domain info
-	<span class="marker">TODO</span> virsh save/restore and other stuff https://www.centos.org/docs/5/html/5.2/Virtualization/chap-Virtualization-Managing_guests_with_virsh.html
-	use "--connect qemu:///system" argument to explicitly target the local (sometimes necessary)

<a name="references"></a>References & Resources
---------

###Documents

- [KVM HOWTO]
- [KVM Installation]
- [KVM Command Line]
- [KVM Intro]
- [KVM Tuning]
- [How to Debug Virtualization problems]
- [KVM Networking (Ubuntu)]
- [KVM Networking]
- [KVM Network Bridging]
- [KVM Access]
- [KVM Management Tools]
- [KVM Virsh Help]

###Man Pages

- [qemu-system-x86_64]
- [virt-install]
- [virsh]
- [virt-clone]

###Related Resources
- [Convert VirtualBox Image to KVM Image]

[KVM HOWTO]: http://www.linux-kvm.org/page/RunningKVM
[KVM Installation]: https://help.ubuntu.com/community/KVM/Installation
[KVM Command Line]: http://xmodulo.com/use-kvm-command-line-debian-ubuntu.html
[KVM Intro]: http://www.dedoimedo.com/computers/kvm-intro.html
[KVM Tuning]: http://www.linux-kvm.org/page/Tuning_KVM
[How to Debug Virtualization problems]: http://fedoraproject.org/wiki/How_to_debug_Virtualization_problems
[KVM Networking (Ubuntu)]: https://help.ubuntu.com/community/KVM/Networking
[KVM Networking]: http://www.linux-kvm.org/page/Networking
[KVM Network Bridging]: http://hzqtc.github.io/2012/02/kvm-network-bridging.html
[KVM Access]: https://help.ubuntu.com/community/KVM/Access
[KVM Management Tools]: http://www.linux-kvm.org/page/Management_Tools
[KVM Virsh Help]: https://help.ubuntu.com/community/KVM/Virsh

[qemu-system-x86_64]: http://manpages.ubuntu.com/manpages/trusty/en/man1/qemu-system-x86_64.1.html
[virt-install]: http://manpages.ubuntu.com/manpages/trusty/en/man1/virt-install.1.html "test"
[virsh]: http://manpages.ubuntu.com/manpages/trusty/en/man1/virsh.1.html
[virt-clone]: http://manpages.ubuntu.com/manpages/trusty/man1/virt-clone.1.html

[Convert VirtualBox Image to KVM Image]: http://blog.bodhizazen.net/linux/convert-virtualbox-vdi-to-kvm-qcow/

