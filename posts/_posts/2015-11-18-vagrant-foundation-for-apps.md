---
layout: post
title: Vagrantfile for using Foundation for Apps
relativeroot: ../../../../
category: posts
---

Created a vagrantfile for using Foundation for Apps on Vagrant: https://github.com/mikkorepolainen/vagrant-foundation-for-apps/.

Unfortunately, I was unable to get it working within a shared directory (on Windows 7 using VirtualBox 5.0.10 and Vagrant 1.7.4.)
Apparently the culprit is the really long directory paths created by npm in the node_modules directory.

More:

- [http://foundation.zurb.com/apps.html](http://foundation.zurb.com/apps.html)
- [https://scotch.io/tutorials/getting-started-with-foundation-for-apps](https://scotch.io/tutorials/getting-started-with-foundation-for-apps)
