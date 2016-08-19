---
layout: document
title: Sanitize filenames in linux
description: How to recursively make file names consistent with other file systems
modified: 2016-08-19 23:59:00
relativeroot: ../../
permalink: documents/linux-fix-filenames
type: document
tags:
- linux
- shell
- NTFS
- cifs
category: documents
published: true
hidden: false
---

Certain file systems (like NTFS) used on windows machines and commercial network drives are picky about the characters used in file and directory names.
This can cause problems when transferring files from other file systems.
For example, poor tagging of media files in combination with media ripping tools that generate file names based on the tags tend to produce problematic file names.

I recently had to move a big media directory (lots of files in many directories and subdirectories) onto a network drive (LaCie Network Space 2) from a linux machine (Ubuntu 14.04).
As you might expect, there were a lot of problems with file and directory names.
After some frantic googling and testing, I managed to piece together the information presented here.

Problems with filenames
=======================

- Illegal characters in filenames: `\:*?"<>|`. `/` is also illegal but it's illegal on linux also.
- Trailing dots (at least in directory names) cause the name to be shortened to a jumble of characters.
- There can be linefeed and tab characters in linux filenames (use `find . -name $'*\n*'` and `find . -name $'*\t*'` to find them).
- Whitespace in beginning and end: whitespace in the beginning is just annoying, but it seems that some component along the way during a copy operation is unable to tell the difference between directories with the same name but different amount of whitespace at the end (e.g. `/test/` and `/test /`).

I was able to sanitize the filenames with the following commands, although the performance was not so good.
Add the `-n` flag after each `rename` command for dry run. *Use at your own risk!*

Remove illegal characters
=========================

`find -depth -execdir rename "s/[\\:*?\"<>|\n]//g" "{}" \;`

Here, I couldn't use the `/` character in the expression because `{}` is the file/dir name prefixed with `./`. The entire result string is included in the match, and therefore, for example, `./test.txt` would be renamed to `.test.txt`.

Remove trailing dots
====================

`find -depth -execdir rename "s/[\.]*$//" "{}" \;`

Trim whitespace from beginning
==============================

`find -depth -execdir rename "s/^(\.\/)\s+/$1/" "{}" \;`

The `(\.\/)` and `$1` bits preserve the `./` in the beginning to prevent `rename` from attempting to rename the file or dir with the same name.

Trim whitespace from end
========================

`find -depth -execdir rename "s/\s+$//" "{}" \;`

Replace whitespace with underscores
===================================

This is a bonus for those who are allergic to whitespace in general

`find -depth -execdir rename "s/\s+/_/g" "{}" \;`
