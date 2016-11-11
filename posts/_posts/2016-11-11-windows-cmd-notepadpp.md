---
layout: post
title: Launch notepad++ from windows command line
relativeroot: ../../../../
category: posts
alt_excerpt: Simple way to launch notepad++ from the command line
---

I spend a lot of time in the command line, so I wanted an easy way to edit files in my favorite multipurpose editor without having to locate the file in windows explorer. I also did not want to pollute the path environment variable, so I decided to write a batch file and place it in a directory that is already in the path: `C:\Windows\System32\npp.bat`.

{% highlight bat %}
@echo off
START "" "C:\Program Files (x86)\Notepad++\notepad++.exe" %*
{% endhighlight %}

The START command launches a new process to unblock the command prompt (note the extra double quotes, that's just an empty "title" parameter).
The `%*` argument forwards all arguments from the command line to the executable.

Now I can just `cd` around in the command line and say `npp <filename>` to edit text files in a nice windowed text editor without having to divert to windows explorer.
