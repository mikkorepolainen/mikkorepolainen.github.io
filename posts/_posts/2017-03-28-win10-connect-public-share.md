---
layout: post
title: Connecting to a public share on a NAS with local credentials from Windows 10
relativeroot: ../../../../
category: posts
alt_excerpt: Windows 10 asks for a password when connecting to public share? Try `<username>@<nas hostname>` for username and just some garbage as the password.
---

TL;DR: Windows 10 asks for a password when connecting to public share? Try `<username>@<nas hostname>` for username and just some garbage as the password.

In my scenario, I have a LaCie NetworkSpace 2 and a windows 10 laptop without domain. I log in to both devices with the same local username.
Connecting to a private share on the device works as expected (just username without domain and password).

On windows 10, connecting to a public share also brings up the login dialog as opposed to Windows 7 or earlier versions.
However, this time the username is not recognized as is. Instead, I have to supply the domain part of the login as well: `<username>@<nas hostname>`.
The fun part is that the password does not actually matter, but you have to input something.

Apparently, either windows networking or the NAS gets confused as to which account is being used: <https://www.neowin.net/forum/topic/1261994-fix-windows-10-accessing-network-drives-password-incorrect/>.

P.s. If you need to manually disconnect a non-mapped network share, use the following commands in the command prompt:

`net use` list connected shares  
`net use /delete \\<host>\<share>` disconnect from share

<https://www.howtogeek.com/howto/16196/how-to-disconnect-non-mapped-unc-path-drives-in-windows/>
