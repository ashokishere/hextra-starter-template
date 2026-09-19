---
title: Operating Systems and Linux Basics
type: docs
prev: docs/NanaBootcamo/
next: docs/NanaBootcamo/Module2
sidebar:
  open: true
---


# Linux Operating System System Administration
---

### 1\. Operating System Fundamentals &amp; Linux Overview

* **Definition &amp; Function**: An Operating System (OS) serves as an essential abstraction layer between computer software applications and physical hardware resources.
* **Core OS Responsibilities**:
  * **Process Management**: Schedules CPU tasks using fast time-slicing so multiple processes execute smoothly without bottlenecking.
  * **Memory Management**: Allocates working memory (RAM) dynamically among active applications.
  * **Storage &amp; File Management**: Persists long-term data like files, application binaries, and configurations in organized directory structures.
  * **Device Management**: Coordinates hardware communication across peripherals using dedicated device drivers.
  * **Security &amp; Networking**: Controls user accounts and permissions, manages open network ports, and routes incoming/outgoing network packets.
* **OS Architecture**:
  * **Kernel**: The heart of the OS loaded at startup that directly controls hardware, allocates resources, and manages process lifecycles.
  * **Application Layer**: Sits on top of the kernel, providing user interfaces such as Graphical User Interfaces (GUI) or Command Line Interfaces (CLI).
* **Linux History &amp; POSIX Compliance**:
  * Developed by Linus Torvalds in 1991 as an open-source "Unix-like" kernel clone.
  * Adheres to POSIX (Portable Operating System Interface) standards for cross-OS compatibility.
  * Multiple Linux distributions (such as Ubuntu, Debian, CentOS, and Mint) share the same Linux kernel. Android is also built on top of the Linux kernel.
  * Linux is the primary operating system used for production cloud infrastructure and server deployments.

---

### 2\. Virtualization &amp; Virtual Machines (VMs)

* **Virtualization Concept**: Creating software-based "virtual" instances of computers with dedicated amounts of CPU, RAM, and storage borrowed from a physical host computer.
* **Key Terminology**:
  * **Host OS**: The operating system running directly on host physical hardware.
  * **Guest OS**: The operating system running inside an isolated Virtual Machine.
  * **Hypervisor**: The underlying software managing virtual machine execution and resource distribution (e.g., Oracle VM VirtualBox).
* **Hypervisor Types**:
  * **Type 1 (Bare Metal / Native)**: Executes directly on physical server hardware without a host OS (e.g., VMware ESXi, Microsoft Hyper-V).
  * **Type 2 (Hosted)**: Runs as an application inside a host operating system (e.g., VirtualBox).
* **Benefits**: Provides complete environment isolation, speeds up server provisioning, cuts hardware costs, and offers portability via Virtual Machine Images (VMIs) and snapshots.

---

### 3\. Linux File System &amp; Directory Layout

* **Hierarchical Tree Structure**: Unlike Windows (which uses separate root drive letters like `C:` and `D:`), Linux organizes all files and folders under a single root directory (`/`).
* **"Everything is a File" Paradigm**: Text documents, binary executables, directories, and hardware devices (printers, keyboards, storage drives) are all represented as file descriptors.
* **Core Root Directories**:
  * `/bin` &amp; `/sbin`: Houses essential user commands and superuser system administrative binaries.
  * `/usr/local`: Stores user-installed third-party software accessible across all accounts (e.g., Docker, Java).
  * `/opt`: Holds third-party applications that do not split their components across standard system folders.
  * `/var`: Stores variable data generated during runtime, such as system logs (`/var/log`) and cached data (`/var/cache`).
  * `/etc`: Holds configuration files for system-wide applications.
  * `/home` &amp; `/root`: Home directories for regular users (`/home/

 

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
