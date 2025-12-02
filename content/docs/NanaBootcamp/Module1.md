---
title: Operating Systems and Linux Basics
type: docs
prev: docs/NanaBootcamo/
next: docs/NanaBootcamo/Module2
sidebar:
  open: true
---


# 2 - Operating Systems & Linux Basics

## Virtualization & Virtual Machines

- You need a **hypervisor** to run multiple virtual machines on a physical Host OS.
- Most popular hypervisor: **VirtualBox** (not supported on M1, switched to **UTM** instead).
- VMs are isolated environments.

### Hypervisor Types

**Type 1 Hypervisor**
- Installed directly on hardware.
- Used in servers.
- Efficient hardware usage.
- OS abstraction from hardware via **VMI** (Virtual Machine Image) with backups/snapshots.

**Type 2 Hypervisor**
- Runs on a host OS (laptops/desktops).
- Best for learning & experimenting.
- Does not endanger main OS.
- Allows testing different OS environments.

---

## Linux File System

- **Everything in Linux is a file** (unlike macOS/Windows).
- Root user has its own home directory (e.g., `/Users/username` on macOS).

### Linux Folder Structure

- `/home/{username}` → Home directory of non-root users.
- `/bin` → Essential system commands (executables).
- `/sbin` → System binaries (superuser privileges required).
- `/lib` → Shared libraries for `/bin` and `/sbin`.
- `/usr` → Historic user directory (due to storage limits in old systems).
- `/usr/local` → Programs YOU install (3rd-party), available to all users.
- `/opt` → 3rd-party programs not broken into components.
- `/boot` → Bootloader files.
- `/etc` → System configuration files.
- `/dev` → Device files (mouse, keyboard, webcam, etc).
- `/var` → Logs.
- `/var/cache` → Cached files.
- `/tmp` → Temporary files.
- `/media` → Removable media.
- `/mnt` → Temporary mount points.

**Hidden Files:** Start with a dot (`.`).

---

## Basic Linux Commands

- `pwd` → print current directory  
- `ls` → list directory contents  
- `cd` → change directory  
  - `cd /` → go to root  
  - `cd` → go to home  
- `mkdir` → make directory  
- `touch` → create file  
- `rm` → delete file  
- `rm -r` → delete non-empty directory  
- `rmdir` → delete empty directory  
- `clear` → clear terminal  
- `mv <old> <new>` → rename/move file  
- `cp -r <src> <dest>` → copy directory  
- `ls -R` → recursive list  
- `history` → show recent commands  
- `ls -a` → show hidden files  
- `ls -l` → long format  
- `ls -la` → long + hidden  
- `cat` → show file contents  
- `uname -a` → show system & kernel info  
- `cat /etc/os-release` → OS release  
- `lscpu` → CPU info  
- `lsmem` → memory info  
- `sudo` → superuser privileges  
- `su - <username>` → switch user  
- `|` → pipe output  
- `<input> | less` → scrollable view  
- `<input> | grep <pattern>` → filter by pattern  
- `>` → redirect output (overwrite)  
- `>>` → append output  
- `;` → run multiple commands  

---

## Package Manager: APT

- Resolves dependencies.
- Ensures package authenticity.
- Downloads/installs/updates software.
- Knows correct file locations.

## Commands:

- apt search <package>
- apt install <package>
- apt remove <package>
- apt update
- apt upgrade
- apt autoremove
- apt full-upgrade

## VIM Text Editor

- `:wq` → save & quit  
- `:q!` → quit without saving  
- `dd` → delete line  
- `d10d` → delete 10 lines  
- `u` → undo  
- `A` → go to end of line + insert  
- `$` → go to end of line  
- `0` → go to beginning  
- `12G` → go to line 12  
- `/pattern` → search  
- `n` → next match  
- `N` → previous match  
- `:%s/old/new` → replace all  

## Users, Groups & Permissions

### User Types

- **Root user**
- **Regular user**
- **Service user** (no login shell; used for apps like Nexus/Docker)

Users can be grouped for easier permission management.

### User & Group Commands
- adduser <username>
- passwd <username>
- su - <username>
- su - # switch to root
- groupadd <groupname>
- deluser <username>
- groupdel <groupname>
- usermod [OPTIONS] <username>
- usermod -g <group> <user> # primary group
- usermod -G <group> <user> # override secondary groups
- usermod -aG <group> <user> # append to secondary groups
- gpasswd -d <user> <group>
- groups <username>
- exit
- chown <user>:<group> <file>
- chgrp <group> <file>


---

## Permissions

### Types

- **Owner** → `r w x -`
- **Group** → `r w x -`
- **Other** → `r w x -`

### Chmod Examples

- chmod -x <file> # remove execute for all
- chmod g-w <file> # remove write for group
- chmod g+x <file> # add execute for group
- chmod u+x <file> # add execute for user
- chmod o+x <file> # add execute for others
- chmod g=rwx <file> # set rwx for group
- chmod 777 <file> # full permissions for all