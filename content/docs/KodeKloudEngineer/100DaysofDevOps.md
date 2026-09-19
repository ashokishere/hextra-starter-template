---
title: 100DaysofDevOps
type: docs
prev: docs/KodeKloudEngineer/Terraform
next: docs/KodeKloudEngineer/AWS
sidebar:
  open: true
---


# Day 12: Linux Network Services

Our monitoring tool has reported an issue in Stratos Datacenter. One of our app servers has an issue, as its Apache service is not reachable on port 6400 (which is the Apache port). The service itself could be down, the firewall could be at fault, or something else could be causing the issue.


Use tools like telnet, netstat, etc. to find and fix the issue. Also make sure Apache is reachable from the jump host without compromising any security settings.

Once fixed, you can test the same using command curl http://stapp01:6400 command from jump host.

Note: Please do not try to alter the existing index.html code, as it will lead to task failure.

1️⃣ Identify what is using port 6400

```
sudo ss -tulnp | grep 6400 
sudo netstat -tulnp | grep 6400
```

2️⃣ Find the process name

```
sudo lsof -i :6400
```
3️⃣ Stop the conflicting service

Once you identify it (example: nginx, old httpd, random service):

```
sudo systemctl stop <service-name>
sudo systemctl disable <service-name>
```
Or if it's a rogue process:

```
sudo kill -9 <PID>
``

4️⃣ Restart Apache
```
sudo systemctl restart httpd
```


5️⃣ Verify:

```sudo systemctl status httpd```

5️⃣ Confirm Apache is now listening on 6400

```ss -tulnp | grep httpd```


Expected output:

LISTEN 0.0.0.0:6400

 
🧪 Final Test from Jump Host.. CLIENT SHOULD work else it wont PASS

curl http://stapp01:6400

 
Why Curl Failed Before iptables (Even If Apache Was Running)

You already fixed Apache, but Linux firewall rules can still block traffic even when a service is healthy.

So the flow looked like this:

Client (jump host)
   ↓
Firewall (iptables) ❌ BLOCKED
   ↓
Apache (port 6400) ✅ READY


Apache was fine — the firewall was the gatekeeper.

``` 
sudo iptables -I INPUT -p tcp -m tcp --dport 6400 -j ACCEPT 
sudo service iptables save iptables

```
 ```


# Day 13 
 
## 📌 Project Context

We attempted to secure application servers (`stapp01`, `stapp02`, `stapp03`) by:

- Installing and configuring `iptables`
- Restricting access to Apache port `8086`
- Allowing only Load Balancer (`stlb01`)
- Ensuring rules persist after reboot
- Automating via Ansible from `jump-host`

---

# ❗ Issues Encountered & Root Causes

## 1\. Missing Inventory Group Definition

### ❌ Error

```
Could not match supplied host pattern: app_servers
```

### 🔍 Root Cause

Inventory hosts were not grouped under `[app_servers]`, but playbook targeted that group.

### ✅ Fix

```
[app_servers]stapp01 ...stapp02 ...stapp03 ...
```

---

## 2\. SSH Host Key Verification Failure

### ❌ Error

```
Host key verification failed
```

### 🔍 Root Cause

Servers were not present in `~/.ssh/known_hosts`, causing SSH trust failure.

### ✅ Fix

```
ssh-keyscan -H stapp01 stapp02 stapp03 >> ~/.ssh/known_hosts
```

---

## 3\. Incorrect SSH Username Usage

### ❌ Error

```
Permission denied for thor@stapp01
```

### 🔍 Root Cause

Wrong SSH user used instead of service-specific users (`tony`, `steve`, `banner`).

### ✅ Fix

Inventory corrected:

```
stapp01 ansible_user=tonystapp02 ansible_user=stevestapp03 ansible_user=banner
```

---

## 4\. Missing Sudo Privileges in Ansible

### ❌ Error

```
Missing sudo password
```

### 🔍 Root Cause

Tasks required privilege escalation (`become: true`) but no sudo password provided.

### ✅ Fix Options

- Add:
```
ansible_become_pass=PASSWORD
```
- OR use:
```
--ask-become-pass
```
- OR enable passwordless sudo (best practice)

---

## 5\. Deprecated / Missing `service` Command

### ❌ Error

```
No such file or directory: service iptables save
```

### 🔍 Root Cause

System does not support legacy SysV `service` command for iptables persistence.

### ✅ Fix

Use modern persistence method:

```
iptables-save > /etc/sysconfig/iptables
```

---

## 6\. SSH Password + Host Key Checking Conflict

### ❌ Error

```
Using a SSH password instead of a key is not possible because Host Key checking is enabled
```

### 🔍 Root Cause

- Using `sshpass` (password authentication)
- SSH host key verification still enabled
- sshpass cannot handle interactive prompts

### ✅ Fix Options

### Option 1 (recommended)

```
ssh-keyscan -H stapp01 stapp02 stapp03 >> ~/.ssh/known_hosts
```

### Option 2 (temporary)

```
export ANSIBLE_HOST_KEY_CHECKING=False
```

### Option 3 (best practice)

Use SSH key authentication instead of passwords.

---

# 🧠 Key Learnings

## 1\. Ansible Requires Clean SSH Setup

- Password-based SSH is fragile
- SSH keys are strongly recommended

---

## 2\. Inventory Structure Matters

Correct structure:

```
inventory.inigroup_vars/  app_servers.yml
```

Without proper grouping, playbooks will silently skip execution.

---

## 3\. Privilege Escalation Must Be Explicit

- `become: true` requires:
	- sudo password OR
		- passwordless sudo

---

## 4\. Legacy Linux Commands May Not Work

- `service iptables save` ❌ (deprecated)
- Use `iptables-save` ✔

---

## 5\. Host Key Checking is a Common Automation Blocker

- Always pre-populate `known_hosts` in automation environments
- Or disable host key checking in controlled labs

---

# 🚀 Fixes learned

### ✔ Use SSH keys instead of passwords

### ✔ Preload known\_hosts during setup

### ✔ Use Ansible groups properly

### ✔ Avoid legacy Linux service commands

### ✔ Prefer idempotent Ansible modules where possible

### ✔ Use `group_vars` for configuration separation

---

## Command logs

```
thor@jump-host ~$ mkdir group_vars
thor@jump-host ~$ cd group_vars/
thor@jump-host ~/group_vars$ vi group_vars/app_servers.yml
thor@jump-host ~/group_vars$ cd ..
thor@jump-host ~$ vi group_vars/app_servers.yml
thor@jump-host ~$ vi iptables-app-secure.yml
thor@jump-host ~$ vi inventory.ini:
thor@jump-host ~$ vi inventory.ini
thor@jump-host ~$ ansible-playbook -i inventory.ini iptables-app-secure.yml --ask-become-pass
BECOME password:  [ERROR]: User interrupted execution
thor@jump-host ~$ ansible-playbook -i inventory.ini iptables-app-secure.yml

PLAY [Secure Apache port 8086 using iptables] *********************************************

TASK [Gathering Facts] ********************************************************************
fatal: [stapp01]: FAILED! => {"msg": "Using a SSH password instead of a key is not possible because Host Key checking is enabled and sshpass does not support this.  Please add this host's fingerprint to your known_hosts file to manage this host."}
fatal: [stapp03]: FAILED! => {"msg": "Using a SSH password instead of a key is not possible because Host Key checking is enabled and sshpass does not support this.  Please add this host's fingerprint to your known_hosts file to manage this host."}
fatal: [stapp02]: FAILED! => {"msg": "Using a SSH password instead of a key is not possible because Host Key checking is enabled and sshpass does not support this.  Please add this host's fingerprint to your known_hosts file to manage this host."}

PLAY RECAP ********************************************************************************
stapp01                    : ok=0    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
stapp02                    : ok=0    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
stapp03                    : ok=0    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

thor@jump-host ~$ vi inventory.inithor@jump-host ~$ cat i
inventory.ini            iptables-app-secure.yml  
thor@jump-host ~$ cat inventory.ini 
[app_servers]
stapp01 ansible_user=tony ansible_password=Ir0nM@n ansible_become_pass=Ir0nM@n
stapp02 ansible_user=steve ansible_password=Am3ric@ ansible_become_pass=Am3ric@
stapp03 ansible_user=banner ansible_password=BigGr33n ansible_become_pass=BigGr33n
thor@jump-host ~$ ls -lrt
total 12
drwxr-xr-x 2 thor thor 4096 May 17 18:38 group_vars
-rw-r--r-- 1 thor thor 1996 May 17 18:39 iptables-app-secure.yml
-rw-r--r-- 1 thor thor  256 May 17 18:41 inventory.ini
thor@jump-host ~$ cd group_vars/
thor@jump-host ~/group_vars$ vi app_servers.yml 
thor@jump-host ~/group_vars$ ssh loki@stlb01
The authenticity of host 'stlb01 (10.244.73.206)' can't be established.
ED25519 key fingerprint is SHA256:ynpWpaDnwSiB1ZgoIYYAt7H3ljgOOJgax7wLO4Xzd+Y.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'stlb01' (ED25519) to the list of known hosts.
loki@stlb01's password: 
 
 
[loki@stlb01 ~]$ ip address
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host proto kernel_lo 
       valid_lft forever preferred_lft forever
3: eth0@if124277: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP group default qlen 1000
    link/ether 9a:32:11:cd:26:69 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.244.73.206/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::9832:11ff:fecd:2669/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
[loki@stlb01 ~]$ exit
logout
Connection to stlb01 closed.
thor@jump-host ~/group_vars$ vi app_servers.yml 
 
thor@jump-host ~/group_vars$ cd ..
thor@jump-host ~$ ls -lrt
total 12
-rw-r--r-- 1 thor thor 1996 May 17 18:39 iptables-app-secure.yml
-rw-r--r-- 1 thor thor  256 May 17 18:41 inventory.ini
drwxr-xr-x 2 thor thor 4096 May 17 18:42 group_vars
thor@jump-host ~$ ansible-playbook -i inventory.ini iptables-app-secure.yml
PLAY [Secure Apache port 8086 using iptables] *********************************************

TASK [Gathering Facts] ********************************************************************
fatal: [stapp01]: FAILED! => {"msg": "Using a SSH password instead of a key is not possible because Host Key checking is enabled and sshpass does not support this.  Please add this host's fingerprint to your known_hosts file to manage this host."}
fatal: [stapp02]: FAILED! => {"msg": "Using a SSH password instead of a key is not possible because Host Key checking is enabled and sshpass does not support this.  Please add this host's fingerprint to your known_hosts file to manage this host."}
fatal: [stapp03]: FAILED! => {"msg": "Using a SSH password instead of a key is not possible because Host Key checking is enabled and sshpass does not support this.  Please add this host's fingerprint to your known_hosts file to manage this host."}

PLAY RECAP ********************************************************************************
stapp01                    : ok=0    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
stapp02                    : ok=0    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   
stapp03                    : ok=0    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

thor@jump-host ~$ ssh-keyscan -H stapp01 stapp02 stapp03 >> ~/.ssh/known_hosts
thor@jump-host ~$ ansible-playbook -i inventory.ini iptables-app-secure.yml

PLAY [Secure Apache port 8086 using iptables] *********************************************

TASK [Gathering Facts] ********************************************************************
ok: [stapp03]
ok: [stapp01]
ok: [stapp02]

TASK [Install iptables packages (RHEL)] ***************************************************
changed: [stapp01]
changed: [stapp03]
changed: [stapp02]

TASK [Install iptables packages (Debian)] *************************************************
skipping: [stapp01]
skipping: [stapp02]
skipping: [stapp03]

TASK [Flush existing iptables rules] ******************************************************
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

TASK [Delete custom chains] ***************************************************************
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

TASK [Allow loopback traffic] *************************************************************
changed: [stapp02]
changed: [stapp01]
changed: [stapp03]

TASK [Allow established connections] ******************************************************
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

TASK [Allow SSH access] *******************************************************************
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

TASK [Allow Apache (8086) only from Load Balancer] ****************************************
changed: [stapp03]
changed: [stapp02]
changed: [stapp01]

TASK [Block Apache (8086) from all other sources] *****************************************
changed: [stapp01]
changed: [stapp03]
changed: [stapp02]

TASK [Set default INPUT policy to DROP] ***************************************************
changed: [stapp03]
changed: [stapp01]
changed: [stapp02]

TASK [Set OUTPUT policy to ACCEPT] ********************************************************
changed: [stapp02]
changed: [stapp03]
changed: [stapp01]

TASK [Save iptables rules (RHEL)] *********************************************************
changed: [stapp03]
changed: [stapp01]
changed: [stapp02]

TASK [Enable iptables service (RHEL)] *****************************************************
changed: [stapp02]
changed: [stapp01]
changed: [stapp03]

TASK [Save iptables rules (Debian)] *******************************************************
skipping: [stapp01]
skipping: [stapp02]
skipping: [stapp03]

TASK [Enable netfilter-persistent (Debian)] ***********************************************
skipping: [stapp01]
skipping: [stapp02]
skipping: [stapp03]

PLAY RECAP ********************************************************************************
stapp01                    : ok=13   changed=12   unreachable=0    failed=0    skipped=3    rescued=0    ignored=0   
stapp02                    : ok=13   changed=12   unreachable=0    failed=0    skipped=3    rescued=0    ignored=0   
stapp03                    : ok=13   changed=12   unreachable=0    failed=0    skipped=3    rescued=0    ignored=0   
```

```
thor@jump-host ~$ history
    1  mkdir group_vars
    2  cd group_vars/
    3  vi group_vars/app_servers.yml
    4  cd ..
    5  vi group_vars/app_servers.yml
    6  vi iptables-app-secure.yml
    7  vi inventory.ini:
    8  vi inventory.ini
    9  ansible-playbook -i inventory.ini iptables-app-secure.yml --ask-become-pass
   10  ansible-playbook -i inventory.ini iptables-app-secure.yml
   11  vi inventory.ini
   12  cat inventory.ini 
   13  ls -lrt
   14  cd group_vars/
   15  vi app_servers.yml 
   16  ssh loki@stlb01
   17  vi app_servers.yml 
   18  ccd ..
   19  cd ..
   20  ls -lrt
   21  ansible-playbook -i inventory.ini iptables-app-secure.yml
   22  ssh-keyscan -H stapp01 stapp02 stapp03 >> ~/.ssh/known_hosts
   23  ansible-playbook -i inventory.ini iptables-app-secure.yml
   24  history
```

```
thor@jump-host ~$ ls
group_vars  inventory.ini  iptables-app-secure.yml
thor@jump-host ~$ cat inventory.ini 
[app_servers]
stapp01 ansible_user=tony ansible_password=Ir0nM@n ansible_become_pass=Ir0nM@n
stapp02 ansible_user=steve ansible_password=Am3ric@ ansible_become_pass=Am3ric@
stapp03 ansible_user=banner ansible_password=BigGr33n ansible_become_pass=BigGr33n
```
```
thor@jump-host ~$ cat iptables-app-secure.yml 
---
- name: Secure Apache port 8086 using iptables
  hosts: app_servers
  become: true

  tasks:

    - name: Install iptables packages (RHEL)
      yum:
        name:
          - iptables
          - iptables-services
        state: present
      when: ansible_os_family == "RedHat"

    - name: Install iptables packages (Debian)
      apt:
        name:
          - iptables
          - iptables-persistent
        state: present
        update_cache: yes
      when: ansible_os_family == "Debian"

    - name: Flush existing iptables rules
      command: iptables -F

    - name: Delete custom chains
      command: iptables -X

    - name: Allow loopback traffic
      command: iptables -A INPUT -i lo -j ACCEPT

    - name: Allow established connections
      command: iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    - name: Allow SSH access
      command: iptables -A INPUT -p tcp --dport 22 -j ACCEPT

    - name: Allow Apache (8086) only from Load Balancer
      command: iptables -A INPUT -p tcp -s {{ lb_ip }} --dport {{ app_port }} -j ACCEPT

    - name: Block Apache (8086) from all other sources
      command: iptables -A INPUT -p tcp --dport {{ app_port }} -j DROP

    - name: Set default INPUT policy to DROP
      command: iptables -P INPUT DROP

    - name: Set OUTPUT policy to ACCEPT
      command: iptables -P OUTPUT ACCEPT

    # ---------------- PERSISTENCE ----------------

    - name: Save iptables rules (RHEL)
      shell: iptables-save > /etc/sysconfig/iptables
      when: ansible_os_family == "RedHat"

    - name: Enable iptables service (RHEL)
      service:
        name: iptables
        enabled: yes
      when: ansible_os_family == "RedHat"

    - name: Save iptables rules (Debian)
      command: netfilter-persistent save
      when: ansible_os_family == "Debian"

    - name: Enable netfilter-persistent (Debian)
      service:
        name: netfilter-persistent
        enabled: yes
      when: ansible_os_family == "Debian"
```

```
thor@jump-host ~$ cat group_vars/app_servers.yml 
lb_ip: "10.244.73.206/32"   # <-- replace with actual stlb01 IP
app_port: 3001
thor@jump-host ~$ 

```

## Day 14: Linux Process Troubleshooting


### Issue

Apache (`httpd`) was configured to run on port `3003`, but it failed to start because another service was already using that port.

Error seen:

```markdown
(98)Address already in use: AH00072: make_sock: could not bind to address 0.0.0.0:3003
```

Using:

```markdown
sudo lsof -i :3003
```

we found that **sendmail** was listening on port `3003`:

```markdown
sendmail ... TCP localhost:3003 (LISTEN)
```

### What we did

1. Identified the conflicting process on port `3003`.
2. Stopped and disabled `sendmail`.
3. Freed port `3003`.
4. Restarted and enabled Apache (`httpd`).

Commands used:

```markdown
sudo systemctl stop sendmail
sudo systemctl disable sendmail
sudo fuser -k 3003/tcp
sudo systemctl restart httpd
sudo systemctl enable httpd
```

### Final result

- Apache service became `active (running)` on all app hosts.
- Apache successfully started listening on port `3003`.

```
thor@jump-host ~$ for host in stapp01 stapp02 stapp03; do
  echo "===== $host ====="
  sshpass -p "$(case $host in \
    stapp01) echo 'Ir0nM@n' ;; \
    stapp02) echo 'Am3ric@' ;; \
    stapp03) echo 'BigGr33n' ;; \
  esac)" \
  ssh -o StrictHostKeyChecking=no $(case $host in \
    stapp01) echo 'tony' ;; \
    stapp02) echo 'steve' ;; \
    stapp03) echo 'banner' ;; \
  esac)@$host \
  "systemctl status httpd --no-pager || systemctl status apache2 --no-pager; \
   echo; \
   ss -tulpn | grep 3003"
  echo
done
===== stapp01 =====
Warning: Permanently added 'stapp01' (ED25519) to the list of known hosts.
× httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; preset: disabled)
     Active: failed (Result: exit-code) since Sun 2026-05-17 20:01:44 UTC; 2min 24s ago
       Docs: man:httpd.service(8)
    Process: 19239 ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND (code=exited, status=1/FAILURE)
   Main PID: 19239 (code=exited, status=1/FAILURE)
     Status: "Reading configuration..."
        CPU: 38ms

May 17 20:01:44 stapp01 systemd[1]: Starting The Apache HTTP Server...
May 17 20:01:44 stapp01 httpd[19239]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 10.244.164.51. Set the 'ServerName' directive globally to suppress this message
May 17 20:01:44 stapp01 httpd[19239]: (98)Address already in use: AH00072: make_sock: could not bind to address [::]:3003
May 17 20:01:44 stapp01 httpd[19239]: (98)Address already in use: AH00072: make_sock: could not bind to address 0.0.0.0:3003
May 17 20:01:44 stapp01 httpd[19239]: no listening sockets available, shutting down
May 17 20:01:44 stapp01 httpd[19239]: AH00015: Unable to open logs
May 17 20:01:44 stapp01 systemd[1]: httpd.service: Main process exited, code=exited, status=1/FAILURE
May 17 20:01:44 stapp01 systemd[1]: httpd.service: Failed with result 'exit-code'.
May 17 20:01:44 stapp01 systemd[1]: Failed to start The Apache HTTP Server.
Unit apache2.service could not be found.

tcp   LISTEN 0      10         127.0.0.1:3003      0.0.0.0:*          

===== stapp02 =====
Warning: Permanently added 'stapp02' (ED25519) to the list of known hosts.
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; preset: disabled)
     Active: active (running) since Sun 2026-05-17 20:01:45 UTC; 2min 24s ago
       Docs: man:httpd.service(8)
   Main PID: 16595 (httpd)
     Status: "Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec:   0 B/sec"
      Tasks: 177 (limit: 404712)
     Memory: 15.1M
        CPU: 144ms
     CGroup: /system.slice/httpd.service
             ├─16595 /usr/sbin/httpd -DFOREGROUND
             ├─16602 /usr/sbin/httpd -DFOREGROUND
             ├─16603 /usr/sbin/httpd -DFOREGROUND
             ├─16604 /usr/sbin/httpd -DFOREGROUND
             └─16605 /usr/sbin/httpd -DFOREGROUND

May 17 20:01:45 stapp02 systemd[1]: Starting The Apache HTTP Server...
May 17 20:01:45 stapp02 httpd[16595]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 10.244.164.12. Set the 'ServerName' directive globally to suppress this message
May 17 20:01:45 stapp02 httpd[16595]: Server configured, listening on: port 3003
May 17 20:01:45 stapp02 systemd[1]: Started The Apache HTTP Server.

tcp   LISTEN 0      511                *:3003            *:*          

===== stapp03 =====
Warning: Permanently added 'stapp03' (ED25519) to the list of known hosts.
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; preset: disabled)
     Active: active (running) since Sun 2026-05-17 20:01:45 UTC; 2min 24s ago
       Docs: man:httpd.service(8)
   Main PID: 16375 (httpd)
     Status: "Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec:   0 B/sec"
      Tasks: 177 (limit: 409892)
     Memory: 14.9M
        CPU: 180ms
     CGroup: /system.slice/httpd.service
             ├─16375 /usr/sbin/httpd -DFOREGROUND
             ├─16382 /usr/sbin/httpd -DFOREGROUND
             ├─16383 /usr/sbin/httpd -DFOREGROUND
             ├─16384 /usr/sbin/httpd -DFOREGROUND
             └─16385 /usr/sbin/httpd -DFOREGROUND

May 17 20:01:45 stapp03 systemd[1]: Starting The Apache HTTP Server...
May 17 20:01:45 stapp03 httpd[16375]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 10.244.189.243. Set the 'ServerName' directive globally to suppress this message
May 17 20:01:45 stapp03 httpd[16375]: Server configured, listening on: port 3003
May 17 20:01:45 stapp03 systemd[1]: Started The Apache HTTP Server.

tcp   LISTEN 0      511                *:3003            *:*          

thor@jump-host ~$ sshpass -p 'Ir0nM@n' ssh -o StrictHostKeyChecking=no tony@stapp01 "
sudo lsof -i :3003
"

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

sudo: a terminal is required to read the password; either use the -S option to read from standard input or configure an askpass helper
sudo: a password is required
thor@jump-host ~$ sshpass -p 'Ir0nM@n' ssh -o StrictHostKeyChecking=no tony@stapp01 "
echo 'Ir0nM@n' | sudo -S lsof -i :3003
"

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for tony: COMMAND    PID USER   FD   TYPE     DEVICE SIZE/OFF NODE NAME
sendmail 18599 root    4u  IPv4 1009309434      0t0  TCP localhost:cgms (LISTEN)
thor@jump-host ~$ sshpass -p 'Ir0nM@n' ssh -o StrictHostKeyChecking=no tony@stapp01 "
echo 'Ir0nM@n' | sudo -S systemctl stop sendmail
echo 'Ir0nM@n' | sudo -S systemctl disable sendmail
echo 'Ir0nM@n' | sudo -S fuser -k 3003/tcp
echo 'Ir0nM@n' | sudo -S systemctl restart httpd
echo 'Ir0nM@n' | sudo -S systemctl enable httpd
systemctl status httpd --no-pager
ss -tulpn | grep 3003
"
[sudo] password for tony: Created symlink /etc/systemd/system/multi-user.target.wants/httpd.service → /usr/lib/systemd/system/httpd.service.
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; preset: disabled)
     Active: active (running) since Sun 2026-05-17 20:07:28 UTC; 242ms ago
       Docs: man:httpd.service(8)
   Main PID: 44623 (httpd)
     Status: "Started, listening on: port 3003"
      Tasks: 177 (limit: 404712)
     Memory: 15.0M
        CPU: 61ms
     CGroup: /system.slice/httpd.service
             ├─44623 /usr/sbin/httpd -DFOREGROUND
             ├─44630 /usr/sbin/httpd -DFOREGROUND
             ├─44631 /usr/sbin/httpd -DFOREGROUND
             ├─44632 /usr/sbin/httpd -DFOREGROUND
             └─44634 /usr/sbin/httpd -DFOREGROUND

May 17 20:07:28 stapp01 systemd[1]: Starting The Apache HTTP Server...
May 17 20:07:28 stapp01 httpd[44623]: AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 10.244.164.51. Set the 'ServerName' directive globally to suppress this message
May 17 20:07:28 stapp01 httpd[44623]: Server configured, listening on: port 3003
May 17 20:07:28 stapp01 systemd[1]: Started The Apache HTTP Server.
tcp   LISTEN 0      511                *:3003            *:*          
thor@jump-host ~$ sshpass -p 'Ir0nM@n' ssh -o StrictHostKeyChecking=no tony@stapp01 "
echo 'Ir0nM@n' | sudo -S lsof -i :3003
"
[sudo] password for tony: COMMAND   PID   USER   FD   TYPE     DEVICE SIZE/OFF NODE NAME
httpd   44623   root    4u  IPv6 1009572923      0t0  TCP *:cgms (LISTEN)
httpd   44631 apache    4u  IPv6 1009572923      0t0  TCP *:cgms (LISTEN)
httpd   44632 apache    4u  IPv6 1009572923      0t0  TCP *:cgms (LISTEN)
httpd   44634 apache    4u  IPv6 1009572923      0t0  TCP *:cgms (LISTEN)
thor@jump-host ~$ 

```

## Day 14: Linux Process Troubleshooting

 
---
1. Install and configure nginx on App Server 3.


2. On App Server 3 there is a self signed SSL certificate and key present at location /tmp/nautilus.crt and /tmp/nautilus.key. Move them to some appropriate location and deploy the same in Nginx.


3. Create an index.html file with content Welcome! under Nginx document root.


4. For final testing try to access the App Server 3 link (via hostname) from jump host using curl command. For example: curl -Ik https://<app-server-name>/.


1. SSH to **App Server 1** from the jump host.
```markdown
sshpass -p 'BigGr33n' ssh -o StrictHostKeyChecking=no banner@stapp03
```
2. Install Nginx.
```markdown
sudo yum install -y nginx
```

(If the server is Ubuntu/Debian, use `apt` instead.)

3. Create a directory for SSL files and move the certificate/key.
```markdown
sudo mkdir -p /etc/nginx/ssl

sudo mv /tmp/nautilus.crt /etc/nginx/ssl/
sudo mv /tmp/nautilus.key /etc/nginx/ssl/

sudo chmod 600 /etc/nginx/ssl/nautilus.key
```
4. Create the welcome page.
```markdown
echo "Welcome!" | sudo tee /usr/share/nginx/html/index.html
```
5. Configure Nginx for SSL.

Edit the default nginx configuration:

```markdown
sudo vi /etc/nginx/nginx.conf
```

Inside the `server` block, ensure it contains:

```markdown
server {
    listen       443 ssl;
    server_name  _;

    ssl_certificate      /etc/nginx/ssl/nautilus.crt;
    ssl_certificate_key  /etc/nginx/ssl/nautilus.key;

    location / {
        root   /usr/share/nginx/html;
        index  index.html;
    }
}
```

Also remove or comment any conflicting default `listen 80` server blocks if needed.

6. Test and start Nginx.
```markdown
sudo nginx -t
sudo systemctl enable nginx
sudo systemctl restart nginx
```
7. Allow HTTPS if firewall is enabled.
```markdown
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```
8. From the jump host, verify using curl.
```markdown
curl -Ik https://stapp03/
```

Expected result should include something similar to:

```markdown
HTTP/1.1 200 OK
Server: nginx
``` 

```
 

thor@jump-host ~$ sshpass -p 'Ir0nM@n' ssh -o StrictHostKeyChecking=no tony@stapp01
[tony@stapp01 ~]$ sudo yum install -y nginx

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for tony: 
CentOS Stream 9 - BaseOS                                      8.4 MB/s | 8.9 MB     00:01    
CentOS Stream 9 - AppStream                                   419 kB/s |  27 MB     01:06    
CentOS Stream 9 - Extras packages                              18 kB/s |  21 kB     00:01    
Extra Packages for Enterprise Linux 9 - x86_64                 25 MB/s |  21 MB     00:00    
Extra Packages for Enterprise Linux 9 openh264 (From Cisco) - 2.3 kB/s | 2.5 kB     00:01    
Extra Packages for Enterprise Linux 9 - Next - x86_64         435 kB/s | 260 kB     00:00    
Dependencies resolved.
==============================================================================================
 Package                    Architecture   Version                    Repository         Size
==============================================================================================
Installing:
 nginx                      x86_64         2:1.20.1-29.el9            appstream          37 k
Installing dependencies:
 centos-logos-httpd         noarch         90.9-1.el9                 appstream         1.5 M
 nginx-core                 x86_64         2:1.20.1-29.el9            appstream         572 k
 nginx-filesystem           noarch         2:1.20.1-29.el9            appstream          10 k
Installing weak dependencies:
 logrotate                  x86_64         3.18.0-12.el9              baseos             74 k

Transaction Summary
==============================================================================================
Install  5 Packages

Total download size: 2.2 M
Installed size: 4.5 M
Downloading Packages:
(1/5): logrotate-3.18.0-12.el9.x86_64.rpm                     330 kB/s |  74 kB     00:00    
(2/5): nginx-1.20.1-29.el9.x86_64.rpm                         136 kB/s |  37 kB     00:00    
(3/5): nginx-filesystem-1.20.1-29.el9.noarch.rpm              125 kB/s |  10 kB     00:00    
(4/5): nginx-core-1.20.1-29.el9.x86_64.rpm                    1.7 MB/s | 572 kB     00:00    
(5/5): centos-logos-httpd-90.9-1.el9.noarch.rpm               935 kB/s | 1.5 MB     00:01    
----------------------------------------------------------------------------------------------
Total                                                         1.1 MB/s | 2.2 MB     00:01     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                      1/1 
  Running scriptlet: nginx-filesystem-2:1.20.1-29.el9.noarch                              1/5 
  Installing       : nginx-filesystem-2:1.20.1-29.el9.noarch                              1/5 
  Installing       : nginx-core-2:1.20.1-29.el9.x86_64                                    2/5 
  Installing       : centos-logos-httpd-90.9-1.el9.noarch                                 3/5 
  Running scriptlet: logrotate-3.18.0-12.el9.x86_64                                       4/5 
  Installing       : logrotate-3.18.0-12.el9.x86_64                                       4/5 
  Running scriptlet: logrotate-3.18.0-12.el9.x86_64                                       4/5 
Created symlink /etc/systemd/system/timers.target.wants/logrotate.timer → /usr/lib/systemd/system/logrotate.timer.

  Installing       : nginx-2:1.20.1-29.el9.x86_64                                         5/5 
  Running scriptlet: nginx-2:1.20.1-29.el9.x86_64                                         5/5 
  Verifying        : logrotate-3.18.0-12.el9.x86_64                                       1/5 
  Verifying        : centos-logos-httpd-90.9-1.el9.noarch                                 2/5 
  Verifying        : nginx-2:1.20.1-29.el9.x86_64                                         3/5 
  Verifying        : nginx-core-2:1.20.1-29.el9.x86_64                                    4/5 
  Verifying        : nginx-filesystem-2:1.20.1-29.el9.noarch                              5/5 

Installed:
  centos-logos-httpd-90.9-1.el9.noarch             logrotate-3.18.0-12.el9.x86_64            
  nginx-2:1.20.1-29.el9.x86_64                     nginx-core-2:1.20.1-29.el9.x86_64         
  nginx-filesystem-2:1.20.1-29.el9.noarch         

Complete!
[tony@stapp01 ~]$ sudo mkdir -p /etc/nginx/ssl

sudo mv /tmp/nautilus.crt /etc/nginx/ssl/
sudo mv /tmp/nautilus.key /etc/nginx/ssl/

sudo chmod 600 /etc/nginx/ssl/nautilus.key
[tony@stapp01 ~]$ ls /etc/nginx/ssl/
nautilus.crt  nautilus.key
[tony@stapp01 ~]$ ls -lr /etc/nginx/ssl/
total 8
-rw------- 1 root root 3267 May 17 20:14 nautilus.key
-rw-r--r-- 1 root root 2170 May 17 20:14 nautilus.crt
[tony@stapp01 ~]$ echo "Welcome!" | sudo tee /usr/share/nginx/html/index.html
Welcome!
[tony@stapp01 ~]$ sudo vi /etc/nginx/nginx.conf
[tony@stapp01 ~]$ sudo nginx -t
sudo systemctl enable nginx
sudo systemctl restart nginx
nginx: [emerg] cannot load certificate key "/etc/nginx/ssl/nautilus.crt": PEM_read_bio_PrivateKey() failed (SSL: error:1E08010C:DECODER routines::unsupported:No supported data to decode. Input type: PEM)
nginx: configuration file /etc/nginx/nginx.conf test failed
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
Job for nginx.service failed because the control process exited with error code.
See "systemctl status nginx.service" and "journalctl -xeu nginx.service" for details.
[tony@stapp01 ~]$ ls  /etc/nginx/ssl/nautilus.crt
/etc/nginx/ssl/nautilus.crt
[tony@stapp01 ~]$ sudo vi /etc/nginx/nginx.conf
[tony@stapp01 ~]$ sudo vi /etc/nginx/nginx.conf
[tony@stapp01 ~]$ sudo nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
[tony@stapp01 ~]$ sudo systemctl enable nginx
[tony@stapp01 ~]$ sudo systemctl restart nginx
[tony@stapp01 ~]$ curl -Ik https://app01/
curl: (6) Could not resolve host: app01
[tony@stapp01 ~]$ curl -Ik https://stapp01/
HTTP/2 200 
server: nginx/1.20.1
date: Sun, 17 May 2026 20:31:30 GMT
content-type: text/html
content-length: 9
last-modified: Sun, 17 May 2026 20:23:31 GMT
etag: "6a0a23c3-9"
accept-ranges: bytes

[tony@stapp01 ~]$ cat /etc/nginx/nginx.conf
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/
#   * Official Russian Documentation: http://nginx.org/ru/docs/

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }

# Settings for a TLS enabled server.
#
    server {
        listen       443 ssl http2;
        listen       [::]:443 ssl http2;
        server_name  _;
        root         /usr/share/nginx/html;

        ssl_certificate "/etc/nginx/ssl/nautilus.crt";
        ssl_certificate_key "/etc/nginx/ssl/nautilus.key";
        ssl_session_cache shared:SSL:1m;
        ssl_session_timeout  10m;
        ssl_ciphers PROFILE=SYSTEM;
        ssl_prefer_server_ciphers on;
        
        location / {
           root   /usr/share/nginx/html;
           index  index.html;
         }
        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
            location = /40x.html {
        }

        error_page 500 502 503 504 /50x.html;
            location = /50x.html {
        }
    }

}

[tony@stapp01 ~]$ 

```

### Day 81: Jenkins Multistage Pipel
Click on the Jenkins button on the top bar to access the Jenkins UI. Login using username admin and password Adm!n321.


Similarly, click on the Gitea button on the top bar to access the Gitea UI. Login using username sarah and password Sarah_pass123.


There is a repository named sarah/web in Gitea that is already cloned on App Server 1 under /var/www/html directory.


Update the content of the file index.html under the same repository to Welcome to xFusionCorp Industries and push the changes to the origin into the master branch.


Apache is already installed on the app server and is running on port 8080.


Add App Server 1 as a Jenkins agent (slave) node: name App Server 1, label stapp01, remote root directory /home/sarah/jenkins_agent, launch via SSH with host stapp01 and credentials for user sarah. Install java-17-openjdk on App Server 1 if needed.


Create a Jenkins pipeline job named deploy-job (it must not be a Multibranch pipeline job) and pipeline should have two stages Deploy and Test ( names are case sensitive ). Configure these stages as per details mentioned below.


a. The Deploy stage should deploy the code from web repository under /var/www/html on App Server 1, as this is the document root of the app server.


b. The pipeline should run on the App Server 1 node (e.g. use label stapp01).


c. The Test stage should just test if the app is working fine and website is accessible. Its up to you how you design this stage to test it out, you can simply add a curl command as well to run a curl against the LBR URL (http://stlb01:8091) to see if the website is working or not. Make sure this stage fails in case the website/app is not working or if the Deploy stage fails.


Click on the App button on the top bar to see the latest changes you deployed. Please make sure the required content is loading on the main URL http://stlb01:8091 i.e there should not be a sub-directory like http://stlb01:8091/web etc.


Note:


You might need to install some plugins and restart Jenkins service. So, we recommend clicking on Restart Jenkins when installation is complete and no jobs are running on plugin installation/update page i.e update centre. Also, Jenkins UI sometimes gets stuck when Jenkins service restarts in the back end. In this case, please make sure to refresh the UI page.


For these kind of scenarios requiring changes to be done in a web UI, please take screenshots so that you can share it with us for review in case your task is marked incomplete. You may also consider using a screen recording software such as loom.com to record and share your work.


## terminal1

```
thor@jumphost ~$ ssh sarah@stapp01
The authenticity of host 'stapp01 (10.244.164.50)' can't be established.
ED25519 key fingerprint is SHA256:yEyN8qvzhNxfcKVE+H05zwQPmQMKCXj4JyGWuOP1HIg.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'stapp01' (ED25519) to the list of known hosts.
sarah@stapp01's password: 
Last login: Sat Sep 12 03:11:03 2026
[sarah@stapp01 ~]$ java -version
openjdk version "11.0.20.1" 2023-08-24 LTS
OpenJDK Runtime Environment (Red_Hat-11.0.20.1.1-2) (build 11.0.20.1+1-LTS)
OpenJDK 64-Bit Server VM (Red_Hat-11.0.20.1.1-2) (build 11.0.20.1+1-LTS, mixed mode, sharing)
[sarah@stapp01 ~]$ sudo yum install -y java-17-openjdk

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

For security reasons, the password you type will not be visible.

[sudo] password for sarah: 
Last metadata expiration check: 0:53:40 ago on Sat Sep 12 02:24:24 2026.
Dependencies resolved.
===========================================================================================
 Package                       Arch        Version                    Repository      Size
===========================================================================================
Installing:
 java-17-openjdk               x86_64      1:17.0.20.0.8-1.2.el9      appstream      428 k
Upgrading:
 tzdata-java                   noarch      2026c-1.el9                appstream      223 k
Installing dependencies:
 java-17-openjdk-headless      x86_64      1:17.0.20.0.8-1.2.el9      appstream       44 M

Transaction Summary
===========================================================================================
Install  2 Packages
Upgrade  1 Package

Total download size: 45 M
Downloading Packages:
(1/3): tzdata-java-2026c-1.el9.noarch.rpm                  773 kB/s | 223 kB     00:00    
(2/3): java-17-openjdk-17.0.20.0.8-1.2.el9.x86_64.rpm      1.3 MB/s | 428 kB     00:00    
(3/3): java-17-openjdk-headless-17.0.20.0.8-1.2.el9.x86_64  29 MB/s |  44 MB     00:01    
-------------------------------------------------------------------------------------------
Total                                                       22 MB/s |  45 MB     00:02     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Running scriptlet: java-17-openjdk-headless-1:17.0.20.0.8-1.2.el9.x86_64             1/1 
  Preparing        :                                                                   1/1 
  Upgrading        : tzdata-java-2026c-1.el9.noarch                                    1/4 
  Installing       : java-17-openjdk-headless-1:17.0.20.0.8-1.2.el9.x86_64             2/4 
  Running scriptlet: java-17-openjdk-headless-1:17.0.20.0.8-1.2.el9.x86_64             2/4 
  Installing       : java-17-openjdk-1:17.0.20.0.8-1.2.el9.x86_64                      3/4 
  Running scriptlet: java-17-openjdk-1:17.0.20.0.8-1.2.el9.x86_64                      3/4 
  Cleanup          : tzdata-java-2025c-1.el9.noarch                                    4/4 
  Running scriptlet: java-17-openjdk-headless-1:17.0.20.0.8-1.2.el9.x86_64             4/4 
  Running scriptlet: java-17-openjdk-1:17.0.20.0.8-1.2.el9.x86_64                      4/4 
  Running scriptlet: tzdata-java-2025c-1.el9.noarch                                    4/4 
  Verifying        : java-17-openjdk-1:17.0.20.0.8-1.2.el9.x86_64                      1/4 
  Verifying        : java-17-openjdk-headless-1:17.0.20.0.8-1.2.el9.x86_64             2/4 
  Verifying        : tzdata-java-2026c-1.el9.noarch                                    3/4 
  Verifying        : tzdata-java-2025c-1.el9.noarch                                    4/4 

Upgraded:
  tzdata-java-2026c-1.el9.noarch                                                           
Installed:
  java-17-openjdk-1:17.0.20.0.8-1.2.el9.x86_64                                             
  java-17-openjdk-headless-1:17.0.20.0.8-1.2.el9.x86_64                                    

Complete!
[sarah@stapp01 ~]$ java -version
openjdk version "17.0.20" 2026-07-21 LTS
OpenJDK Runtime Environment (Red_Hat-17.0.20.0.8-1) (build 17.0.20+8-LTS)
OpenJDK 64-Bit Server VM (Red_Hat-17.0.20.0.8-1) (build 17.0.20+8-LTS, mixed mode, sharing)
[sarah@stapp01 ~]$ sudo systemctl status httpd
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; preset: disabled)
     Active: active (running) since Fri 2026-09-11 19:44:31 UTC; 7h ago
       Docs: man:httpd.service(8)
   Main PID: 1339 (httpd)
     Status: "Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec>
      Tasks: 177 (limit: 404712)
     Memory: 15.2M (peak: 17.4M)
        CPU: 15.669s
     CGroup: /system.slice/httpd.service
             ├─1339 /usr/sbin/httpd -DFOREGROUND
             ├─1426 /usr/sbin/httpd -DFOREGROUND
             ├─1428 /usr/sbin/httpd -DFOREGROUND
             ├─1429 /usr/sbin/httpd -DFOREGROUND
             └─1431 /usr/sbin/httpd -DFOREGROUND

Sep 12 03:16:46 stapp01 systemd[1]: httpd.service: Got notification message from PID 1339 >
Sep 12 03:16:56 stapp01 systemd[1]: httpd.service: Got notification message from PID 1339 >
Sep 12 03:17:06 stapp01 systemd[1]: httpd.service: Got notification message from PID 1339 >
Sep 12 03:17:16 stapp01 systemd[1]: httpd.service: Got notification message from PID 1339 >
Sep 12 03:17:26 stapp01 systemd[1]: httpd.service: Got notification message from PID 1339 >
Sep 12 03:17:36 stapp01 systemd[1]: httpd.service: Got notification message from PID 1339 >
Sep 12 03:17:46 stapp01 systemd[1]: httpd.service: Got notification message from PID 1339 >
Sep 12 03:17:56 stapp01 systemd[1]: httpd.service: Got notification message from PID 1339 >
Sep 12 03:18:06 stapp01 systemd[1]: httpd.service: Got notification message from PID 1339 >
Sep 12 03:18:16 stapp01 systemd[1]: httpd.service: Got notification message from PID 1339 >
[sarah@stapp01 ~]$ 
[sarah@stapp01 ~]$ cd /var/www/html
git status
git remote -v
git branch
On branch master
Your branch is up to date with 'origin/master'.

nothing to commit, working tree clean
origin  http://sarah:Sarah_pass123@gitea:3000/sarah/web.git (fetch)
origin  http://sarah:Sarah_pass123@gitea:3000/sarah/web.git (push)
* master
[sarah@stapp01 html]$ echo "Welcome to xFusionCorp Industries" > index.html
[sarah@stapp01 html]$ cat index.html
Welcome to xFusionCorp Industries
[sarah@stapp01 html]$ git add index.html
git commit -m "Update welcome page"
git push origin master
[master 954b58d] Update welcome page
 1 file changed, 1 insertion(+), 1 deletion(-)
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Writing objects: 100% (3/3), 287 bytes | 287.00 KiB/s, done.
Total 3 (delta 0), reused 0 (delta 0), pack-reused 0 (from 0)
remote: . Processing 1 references
remote: Processed 1 references in total
To http://gitea:3000/sarah/web.git
   a82f036..954b58d  master -> master
[sarah@stapp01 html]$ git status
git log -1 --oneline
On branch master
Your branch is up to date with 'origin/master'.

nothing to commit, working tree clean
954b58d (HEAD -> master, origin/master) Update welcome page
[sarah@stapp01 html]$ curl http://localhost:8080
Welcome to xFusionCorp Industries
[sarah@stapp01 html]$ http://stlb01:8091
-bash: http://stlb01:8091: No such file or directory
[sarah@stapp01 html]$ curl http://stlb01:8091
Welcome to xFusionCorp Industries
[sarah@stapp01 html]$ ssh sarah@stapp01
```
## terminal2
```
thor@jumphost ~$ sshpass -p 'j@rv!s' ssh -o StrictHostKeyChecking=no jenkins@jenkins
Warning: Permanently added 'jenkins' (ED25519) to the list of known hosts.
Welcome to Ubuntu 24.04.4 LTS (GNU/Linux 6.8.0-90-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, you can run the 'unminimize' command.

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

jenkins@jenkins:~$ sudo -u jenkins mkdir -p /var/lib/jenkins/.ssh
sudo -u jenkins ssh-keyscan -H stapp01 | sudo -u jenkins tee /var/lib/jenkins/.ssh/known_hosts
jenkins is not in the sudoers file.
jenkins is not in the sudoers file.
jenkins is not in the sudoers file.
jenkins@jenkins:~$ sudo -u jenkins ssh -o BatchMode=yes sarah@stapp01 'java -version'
jenkins is not in the sudoers file.
jenkins@jenkins:~$ su -
Password: 
su: Authentication failure
jenkins@jenkins:~$ su -
Password: 
su: Authentication failure
jenkins@jenkins:~$ mkdir -p /var/lib/jenkins/.ssh
chown jenkins:jenkins /var/lib/jenkins/.ssh
chmod 700 /var/lib/jenkins/.ssh
jenkins@jenkins:~$ su -s /bin/bash jenkins
Password: 
jenkins@jenkins:~$ ssh-keygen -t ed25519 -f /var/lib/jenkins/.ssh/id_ed25519
Generating public/private ed25519 key pair.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /var/lib/jenkins/.ssh/id_ed25519
Your public key has been saved in /var/lib/jenkins/.ssh/id_ed25519.pub
The key fingerprint is:
SHA256:xzKQCD1dZzsvfT6FYuuDNx18R9TXQNE8ywxPvvXHovc jenkins@jenkins.stratos.xfusioncorp.com
The key's randomart image is:
+--[ED25519 256]--+
|  .. . .. o  .+=o|
|   .o... o . . oB|
|    ..o   o   B.+|
|       . . +   Bo|
|        S + =.oo=|
|         + o =+o*|
|           ..oo+o|
|          ..= o. |
|           ..+ .E|
+----[SHA256]-----+
jenkins@jenkins:~$ ssh-keyscan -H stapp01 > /var/lib/jenkins/.ssh/known_hosts
# stapp01:22 SSH-2.0-OpenSSH_9.9
# stapp01:22 SSH-2.0-OpenSSH_9.9
# stapp01:22 SSH-2.0-OpenSSH_9.9
# stapp01:22 SSH-2.0-OpenSSH_9.9
# stapp01:22 SSH-2.0-OpenSSH_9.9
jenkins@jenkins:~$ chown jenkins:jenkins /var/lib/jenkins/.ssh/known_hosts
chmod 600 /var/lib/jenkins/.ssh/known_hosts
jenkins@jenkins:~$ ls -la /var/lib/jenkins/.ssh/
total 24
drwx------ 2 jenkins jenkins 4096 Sep 12 03:40 .
drwxr-xr-x 1 jenkins jenkins 4096 Sep 12 03:39 ..
-rw------- 1 jenkins jenkins  444 Sep 12 03:40 id_ed25519
-rw-r--r-- 1 jenkins jenkins  121 Sep 12 03:40 id_ed25519.pub
-rw------- 1 jenkins jenkins  978 Sep 12 03:40 known_hosts
jenkins@jenkins:~$ cat /var/lib/jenkins/.ssh/id_ed25519.pub
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGp+paIts5JeZU4uV2FH094ZE/rOpBH0n2A/MeH9GZrR jenkins@jenkins.stratos.xfusioncorp.com
jenkins@jenkins:~$ ssh sarah@stapp01
sarah@stapp01's password: 
Last login: Sat Sep 12 03:16:49 2026 from 10.244.244.152
[sarah@stapp01 ~]$ exit
logout
Connection to stapp01 closed.
jenkins@jenkins:~$ ssh sarah@stapp01
sarah@stapp01's password: 
Last login: Sat Sep 12 03:42:07 2026 from 10.244.73.207
[sarah@stapp01 ~]$ mkdir -p ~/.ssh
chmod 700 ~/.ssh
vi ~/.ssh/authorized_keys
[sarah@stapp01 ~]$ 
```

terminal 3

```
thor@jumphost ~$ sshpass -p 'j@rv!s' ssh -o StrictHostKeyChecking=no jenkins@jenkins
Welcome to Ubuntu 24.04.4 LTS (GNU/Linux 6.8.0-90-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, you can run the 'unminimize' command.
jenkins@jenkins:~$ cat /var/lib/jenkins/.ssh/id_ed25519.pub
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGp+paIts5JeZU4uV2FH094ZE/rOpBH0n2A/MeH9GZrR jenkins@jenkins.stratos.xfusioncorp.com
jenkins@jenkins:~$ ssh sarah@stapp01
Last login: Sat Sep 12 03:42:44 2026 from 10.244.73.207
[sarah@stapp01 ~]$ chmod 600 ~/.ssh/authorized_keys
[sarah@stapp01 ~]$ exit
logout
Connection to stapp01 closed.
jenkins@jenkins:~$ ssh -i /var/lib/jenkins/.ssh/id_ed25519 sarah@stapp01 'java -version'
openjdk version "17.0.20" 2026-07-21 LTS
OpenJDK Runtime Environment (Red_Hat-17.0.20.0.8-1) (build 17.0.20+8-LTS)
OpenJDK 64-Bit Server VM (Red_Hat-17.0.20.0.8-1) (build 17.0.20+8-LTS, mixed mode, sharing)
jenkins@jenkins:~$ 
```



## Day 82: Create Ansible Inventory for App Server Testing

The Nautilus DevOps team is testing Ansible playbooks on various servers within their stack. They've placed some playbooks under /home/thor/playbook/ directory on the jump host and now intend to test them on app server 3 in Stratos DC. However, an inventory file needs creation for Ansible to connect to the respective app. Here are the requirements:


a. Create an ini type Ansible inventory file /home/thor/playbook/inventory on jump host.


b. Include App Server 3 in this inventory along with necessary variables for proper functionality.


c. Ensure the inventory hostname corresponds to the server name as per the wiki, for example stapp01 for app server 1 in Stratos DC.


Note: Validation will execute the playbook using the command ansible-playbook -i inventory playbook.yml. Ensure the playbook functions properly without any extra arguments.






cat > /home/thor/playbook/inventory <<'EOF'
[app]
stapp03 ansible_host=stapp03 ansible_user=banner ansible_password=BigGr33n
EOF

cd /home/thor/playbook
ansible-playbook -i inventory playbook.yml

thor@jump-host ~$ /home/thor/playbook/inventory
bash: /home/thor/playbook/inventory: No such file or directory
thor@jump-host ~$ vi /home/thor/playbook/inventory
thor@jump-host ~$ ansible-playbook -i inventory playbook.yml
ERROR! the playbook: playbook.yml could not be found
thor@jump-host ~$ cd /home/thor/playbook
thor@jump-host ~/playbook$ ansible-playbook -i inventory playbook.yml

PLAY [all] ********************************************************************************

TASK [Gathering Facts] ********************************************************************
ok: [stapp03]

TASK [Install httpd package] **************************************************************
changed: [stapp03]

TASK [Start service httpd] ****************************************************************
changed: [stapp03]

PLAY RECAP ********************************************************************************
stapp03                    : ok=3    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

thor@jump-host ~/playbook$ 


## 
Day 83: Troubleshoot and Create Ansible Playbook

An Ansible playbook needs completion on the jump host, where a team member left off. Below are the details:



The inventory file /home/thor/ansible/inventory requires adjustments. The playbook must run on App Server 2 in Stratos DC. Update the inventory accordingly.


Create a playbook /home/thor/ansible/playbook.yml. Include a task to create an empty file /tmp/file.txt on App Server 2.


Note: Validation will run the playbook using the command ansible-playbook -i inventory playbook.yml. Ensure the playbook works without any additional arguments.

```
thor@jump-host ~/ansible$ cd /home/thor/ansible
thor@jump-host ~/ansible$ ls -lrt
total 8
-rw-r--r-- 1 thor thor  79 Sep 12 04:13 inventory
-rw-r--r-- 1 thor thor 169 Sep 12 04:13 playbook.yml
thor@jump-host ~/ansible$ cat inventory 
[app]
stapp02 ansible_host=stapp02 ansible_user=steve ansible_password=Am3ric@
thor@jump-host ~/ansible$ ansible-playbook -i inventory playbook.yml

PLAY [Create file on App Server 2] ********************************************************

TASK [Gathering Facts] ********************************************************************
fatal: [stapp02]: FAILED! => {"msg": "Using a SSH password instead of a key is not possible because Host Key checking is enabled and sshpass does not support this.  Please add this host's fingerprint to your known_hosts file to manage this host."}

PLAY RECAP ********************************************************************************
stapp02                    : ok=0    changed=0    unreachable=0    failed=1    skipped=0    rescued=0    ignored=0   

thor@jump-host ~/ansible$ vi inventory 
thor@jump-host ~/ansible$ ansible-playbook -i inventory playbook.yml

PLAY [Create file on App Server 2] ********************************************************

TASK [Gathering Facts] ********************************************************************
ok: [stapp02]

TASK [Create empty file] ******************************************************************
changed: [stapp02]

PLAY RECAP ********************************************************************************
stapp02                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

thor@jump-host ~/ansible$ cat inventory 
[app]
stapp02 ansible_host=stapp02 ansible_user=steve ansible_password=Am3ric@ ansible_host_key_checking=false

thor@jump-host ~/ansible$ cat playbook.yml
---
- name: Create file on App Server 2
  hosts: app
  tasks:
    - name: Create empty file
      ansible.builtin.file:
        path: /tmp/file.txt
        state: touch
thor@jump-host ~/ansible$ 
```

### Day 84: Copy Data to App Servers using Ansible

The Nautilus DevOps team needs to copy data from the jump host to all application servers in Stratos DC using Ansible. Execute the task with the following details:


a. Create an inventory file /home/thor/ansible/inventory on jump_host and add all application servers as managed nodes.


b. Create a playbook /home/thor/ansible/playbook.yml on the jump host to copy the /usr/src/finance/index.html file to all application servers, placing it at /opt/finance.


Note: Validation will run the playbook using the command ansible-playbook -i inventory playbook.yml. Ensure the playbook functions properly without any extra arguments.

```
hor@jump-host ~/ansible$ ansible-playbook -i inventory playbook.yml

PLAY [Copy finance index to all application servers] **************************************

TASK [Gathering Facts] ********************************************************************
ok: [stapp03]
ok: [stapp01]
ok: [stapp02]

TASK [Copy finance index.html] ************************************************************
changed: [stapp02]
changed: [stapp01]
changed: [stapp03]

PLAY RECAP ********************************************************************************
stapp01                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp02                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp03                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

thor@jump-host ~/ansible$ cat inventory 
[app]
stapp01 ansible_host=stapp01 ansible_user=tony ansible_password=Ir0nM@n
stapp02 ansible_host=stapp02 ansible_user=steve ansible_password=Am3ric@
stapp03 ansible_host=stapp03 ansible_user=banner ansible_password=BigGr33n

[app:vars]
ansible_host_key_checking=false
thor@jump-host ~/ansible$ cat playbook.yml 
---
- name: Copy finance index to all application servers
  hosts: app
  become: true

  tasks:
    - name: Copy finance index.html
      ansible.builtin.copy:
        src: /usr/src/finance/index.html
        dest: /opt/finance/index.html
        mode: '0644'
thor@jump-host ~/ansible$ 
```


### Day 85: Create Files on App Servers using Ansible

```
thor@jump-host ~/playbook$ cd ~/playbook
ansible-playbook -i inventory playbook.yml

PLAY [Create nfsshare file on all app servers] ********************************************

TASK [Gathering Facts] ********************************************************************
ok: [stapp01]
ok: [stapp02]
ok: [stapp03]

TASK [Create blank /home/nfsshare.txt] ****************************************************
changed: [stapp03]
changed: [stapp01]
changed: [stapp02]

PLAY RECAP ********************************************************************************
stapp01                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp02                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp03                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

thor@jump-host ~/playbook$ cat playbook.yml 
---
- name: Create nfsshare file on all app servers
  hosts: app
  become: true

  tasks:
    - name: Create blank /home/nfsshare.txt
      ansible.builtin.file:
        path: /home/nfsshare.txt
        state: touch
        owner: "{{ ansible_user }}"
        group: "{{ ansible_user }}"
        mode: '0777'
thor@jump-host ~/playbook$ cat inventory 
[app]
stapp01 ansible_host=stapp01 ansible_user=tony ansible_password=Ir0nM@n
stapp02 ansible_host=stapp02 ansible_user=steve ansible_password=Am3ric@
stapp03 ansible_host=stapp03 ansible_user=banner ansible_password=BigGr33n

[app:vars]
ansible_host_key_checking=false
thor@jump-host ~/playbook$ 

```

### Day 86: Ansible Ping Module Usage

The Nautilus DevOps team is planning to test several Ansible playbooks on different app servers in Stratos DC. Before that, some pre-requisites must be met. Essentially, the team needs to set up a password-less SSH connection between Ansible controller and Ansible managed nodes. One of the tickets is assigned to you; please complete the task as per details mentioned below:


a. Jump host is our Ansible controller, and we are going to run Ansible playbooks through thor user from jump host.


b. There is an inventory file /home/thor/ansible/inventory on jump host. Using that inventory file test Ansible ping from jump host to App Server 2, make sure ping works.






```
hor@jump-host ~/ansible$ vi inventory 
thor@jump-host ~/ansible$ ansible stapp02 -i inventory -m ping
stapp02 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
thor@jump-host ~/ansible$ cat inventory 
[app]
stapp01 ansible_user=tony ansible_ssh_pass=Ir0nM@n
stapp02 ansible_user=steve ansible_ssh_pass=Am3ric@
stapp03 ansible_user=banner ansible_ssh_pass=BigGr33n

[app:vars]
ansible_host_key_checking=false

thor@jump-host ~/ansible$ 

```


 ## Day 87: Ansible Install Package

Create an inventory file /home/thor/playbook/inventory on jump host and add all app servers in it.


Create an Ansible playbook /home/thor/playbook/playbook.yml to install sqlite package on all  app servers using Ansible yum module.


Make sure user thor should be able to run the playbook on jump host.

Note: Validation will try to run playbook using command ansible-playbook -i inventory playbook.yml so please make sure playbook works this way, without passing any extra arguments.
```
thor@jump-host ~$ cd /home/thor/playbook
ansible-playbook -i inventory playbook.yml

PLAY [Install sqlite on all application servers] ***********************************************************

TASK [Install sqlite package] ******************************************************************************
changed: [stapp02]
changed: [stapp01]
changed: [stapp03]

PLAY RECAP *************************************************************************************************
stapp01                    : ok=1    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp02                    : ok=1    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp03                    : ok=1    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

thor@jump-host ~/playbook$ cat inventory 
[app]
stapp01 ansible_user=tony ansible_password='Ir0nM@n'
stapp02 ansible_user=steve ansible_password='Am3ric@'
stapp03 ansible_user=banner ansible_password='BigGr33n'
thor@jump-host ~/playbook$ cat playbook.yml 
---
- name: Install sqlite on all application servers
  hosts: app
  become: true
  gather_facts: false

  tasks:
    - name: Install sqlite package
      ansible.builtin.yum:
        name: sqlite
        state: present
thor@jump-host ~/playbook$ 
```

## Day 88: Ansible Blockinfile Module

We already have an inventory file under /home/thor/ansible directory on jump host. Create a playbook.yml under /home/thor/ansible directory on jump host itself.


Using the playbook, install httpd web server on all app servers. Additionally, make sure its service should up and running.


Using blockinfile Ansible module add some content in /var/www/html/index.html file. Below is the content:


Welcome to XfusionCorp!

This is  Nautilus sample file, created using Ansible!

Please do not modify this file manually!


The /var/www/html/index.html file's user and group owner should be apache on all app servers.


The /var/www/html/index.html file's permissions should be 0777 on all app servers.


Note:


i. Validation will try to run the playbook using command ansible-playbook -i inventory playbook.yml so please make sure the playbook works this way without passing any extra arguments.


ii. Do not use any custom or empty marker for blockinfile module.

```
thor@jump-host ~/ansible$ cd /home/thor/ansible
ansible-playbook -i inventory playbook.yml

PLAY [Configure Apache web servers] ************************************************************************

TASK [Install httpd] ***************************************************************************************
changed: [stapp03]
changed: [stapp01]
changed: [stapp02]

TASK [Ensure httpd service is running and enabled] *********************************************************
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

TASK [Add required content to index.html] ******************************************************************
changed: [stapp02]
changed: [stapp03]
changed: [stapp01]

TASK [Set index.html ownership] ****************************************************************************
changed: [stapp02]
changed: [stapp03]
changed: [stapp01]

TASK [Set index.html permissions] **************************************************************************
changed: [stapp03]
changed: [stapp02]
changed: [stapp01]

PLAY RECAP *************************************************************************************************
stapp01                    : ok=5    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp02                    : ok=5    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp03                    : ok=5    changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

thor@jump-host ~/ansible$ cat inventory 
stapp01 ansible_host=stapp01 ansible_ssh_pass=Ir0nM@n ansible_user=tony
stapp02 ansible_host=stapp02 ansible_ssh_pass=Am3ric@ ansible_user=steve
stapp03 ansible_host=stapp03 ansible_ssh_pass=BigGr33n ansible_user=bannerthor

@jump-host ~/ansible$ cat playbook.yml 
---
- name: Configure Apache web servers
  hosts: all
  become: true
  gather_facts: false

  tasks:

    - name: Install httpd
      ansible.builtin.yum:
        name: httpd
        state: present

    - name: Ensure httpd service is running and enabled
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: true

    - name: Add required content to index.html
      ansible.builtin.blockinfile:
        path: /var/www/html/index.html
        create: true
        block: |
          Welcome to XfusionCorp!

          This is  Nautilus sample file, created using Ansible!

          Please do not modify this file manually!

    - name: Set index.html ownership
      ansible.builtin.file:
        path: /var/www/html/index.html
        owner: apache
        group: apache

    - name: Set index.html permissions
      ansible.builtin.file:
        path: /var/www/html/index.html
        mode: '0777'
thor@jump-host ~/ansible$ 
```

### Day 89: Ansible Manage Services

a. On jump host create an Ansible playbook /home/thor/ansible/playbook.yml and configure it to install httpd on all app servers.


b. After installation make sure to start and enable httpd service on all app servers.


c. The inventory /home/thor/ansible/inventory is already there on jump host.


d. Make sure user thor should be able to run the playbook on jump host.


Note: Validation will try to run playbook using command ansible-playbook -i inventory playbook.yml so please make sure playbook works this way, without passing any extra arguments.

```
hor@jump-host ~/ansible$ ansible-playbook -i inventory playbook.yml

PLAY [Install and configure httpd] *************************************************************************

TASK [Install httpd] ***************************************************************************************
changed: [stapp03]
changed: [stapp01]
changed: [stapp02]

TASK [Start and enable httpd] ******************************************************************************
changed: [stapp03]
changed: [stapp02]
changed: [stapp01]

PLAY RECAP *************************************************************************************************
stapp01                    : ok=2    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp02                    : ok=2    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp03                    : ok=2    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

thor@jump-host ~/ansible$ cat inventory 
stapp01 ansible_host=stapp01 ansible_ssh_pass=Ir0nM@n ansible_user=tony
stapp02 ansible_host=stapp02 ansible_ssh_pass=Am3ric@ ansible_user=steve
stapp03 ansible_host=stapp03 ansible_ssh_pass=BigGr33n ansible_user=bannerthor@jump-host ~/ansible$ cat playbook.yml 
---
- name: Install and configure httpd
  hosts: all
  become: true
  gather_facts: false

  tasks:
    - name: Install httpd
      ansible.builtin.yum:
        name: httpd
        state: present

    - name: Start and enable httpd
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: true
thor@jump-host ~/ansible$ 
```

### Day 90: Managing ACLs Using Ansible

Create a playbook named playbook.yml under /home/thor/ansible directory on jump host, an inventory file is already present under /home/thor/ansible directory on Jump Server itself.


Create an empty file blog.txt under /opt/itadmin/ directory on app server 1. Set some acl properties for this file. Using acl provide read '(r)' permissions to group tony (i.e entity is tony and etype is group).


Create an empty file story.txt under /opt/itadmin/ directory on app server 2. Set some acl properties for this file. Using acl provide read + write '(rw)' permissions to user steve (i.e entity is steve and etype is user).


Create an empty file media.txt under /opt/itadmin/ on app server 3. Set some acl properties for this file. Using acl provide read + write '(rw)' permissions to group banner (i.e entity is banner and etype is group).


Note: Validation will try to run the playbook using command ansible-playbook -i inventory playbook.yml so please make sure the playbook works this way, without passing any extra arguments.

```
ansible-playbook -i inventory playbook.yml

PLAY [Configure ACLs on application servers] ***************************************************************

TASK [Create blog.txt on App Server 1] *********************************************************************
skipping: [stapp02]
skipping: [stapp03]
changed: [stapp01]

TASK [Give group tony read permission on blog.txt] *********************************************************
skipping: [stapp02]
skipping: [stapp03]
changed: [stapp01]

TASK [Create story.txt on App Server 2] ********************************************************************
skipping: [stapp01]
skipping: [stapp03]
changed: [stapp02]

TASK [Give user steve read-write permission on story.txt] **************************************************
skipping: [stapp01]
skipping: [stapp03]
changed: [stapp02]

TASK [Create media.txt on App Server 3] ********************************************************************
skipping: [stapp01]
skipping: [stapp02]
changed: [stapp03]

TASK [Give group banner read-write permission on media.txt] ************************************************
skipping: [stapp01]
skipping: [stapp02]
changed: [stapp03]

PLAY RECAP *************************************************************************************************
stapp01                    : ok=2    changed=2    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0   
stapp02                    : ok=2    changed=2    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0   
stapp03                    : ok=2    changed=2    unreachable=0    failed=0    skipped=4    rescued=0    ignored=0   

thor@jump-host ~/ansible$ cat playbook.yml 
---
- name: Configure ACLs on application servers
  hosts: all
  become: true
  gather_facts: false

  tasks:
    - name: Create blog.txt on App Server 1
      ansible.builtin.file:
        path: /opt/itadmin/blog.txt
        state: touch
        mode: '0644'
      when: inventory_hostname == 'stapp01'

    - name: Give group tony read permission on blog.txt
      ansible.posix.acl:
        path: /opt/itadmin/blog.txt
        entity: tony
        etype: group
        permissions: r
        state: present
      when: inventory_hostname == 'stapp01'

    - name: Create story.txt on App Server 2
      ansible.builtin.file:
        path: /opt/itadmin/story.txt
        state: touch
        mode: '0644'
      when: inventory_hostname == 'stapp02'

    - name: Give user steve read-write permission on story.txt
      ansible.posix.acl:
        path: /opt/itadmin/story.txt
        entity: steve
        etype: user
        permissions: rw
        state: present
      when: inventory_hostname == 'stapp02'

    - name: Create media.txt on App Server 3
      ansible.builtin.file:
        path: /opt/itadmin/media.txt
        state: touch
        mode: '0644'
      when: inventory_hostname == 'stapp03'

    - name: Give group banner read-write permission on media.txt
      ansible.posix.acl:
        path: /opt/itadmin/media.txt
        entity: banner
        etype: group
        permissions: rw
        state: present
      when: inventory_hostname == 'stapp03'
thor@jump-host ~/ansible$ cat inventory 
stapp01 ansible_host=stapp01 ansible_ssh_pass=Ir0nM@n ansible_user=tony
stapp02 ansible_host=stapp02 ansible_ssh_pass=Am3ric@ ansible_user=steve
stapp03 ansible_host=stapp03 ansible_ssh_pass=BigGr33n ansible_user=banner
thor@jump-host ~/ansible$ 
```

### Day 91: Ansible Lineinfile Module

Install httpd web server on all app servers, and make sure its service is up and running.


Create a file /var/www/html/index.html with content:


This is a Nautilus sample file, created using Ansible!


Using lineinfile Ansible module add some more content in /var/www/html/index.html file. Below is the content:

Welcome to Nautilus Group!


Also make sure this new line is added at the top of the file.


The /var/www/html/index.html file's user and group owner should be apache on all app servers.


The /var/www/html/index.html file's permissions should be 0755 on all app servers.


Note: Validation will try to run the playbook using command ansible-playbook -i inventory playbook.yml so please make sure the playbook works this way without passing any extra arguments.

```
hor@jump-host ~/ansible$ cd /home/thor/ansible
ansible-playbook -i inventory playbook.yml

PLAY [Configure Apache web servers] ************************************************************************

TASK [Install httpd] ***************************************************************************************
changed: [stapp03]
changed: [stapp01]
changed: [stapp02]

TASK [Ensure httpd is started and enabled] *****************************************************************
changed: [stapp01]
changed: [stapp03]
changed: [stapp02]

TASK [Create index.html with initial content] **************************************************************
changed: [stapp01]
changed: [stapp02]
changed: [stapp03]

TASK [Add welcome line at the top of index.html] ***********************************************************
changed: [stapp01]
changed: [stapp03]
changed: [stapp02]

TASK [Ensure index.html ownership and permissions] *********************************************************
ok: [stapp01]
ok: [stapp03]
ok: [stapp02]

PLAY RECAP *************************************************************************************************
stapp01                    : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp02                    : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
stapp03                    : ok=5    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

thor@jump-host ~/ansible$ cat inventory 
stapp01 ansible_host=stapp01 ansible_ssh_pass=Ir0nM@n ansible_user=tony
stapp02 ansible_host=stapp02 ansible_ssh_pass=Am3ric@ ansible_user=steve
stapp03 ansible_host=stapp03 ansible_ssh_pass=BigGr33n ansible_user=bannerthor@jump-host ~/ansible$ cat playbook.yml 
---
- name: Configure Apache web servers
  hosts: all
  become: true
  gather_facts: false

  tasks:
    - name: Install httpd
      ansible.builtin.yum:
        name: httpd
        state: present

    - name: Ensure httpd is started and enabled
      ansible.builtin.service:
        name: httpd
        state: started
        enabled: true

    - name: Create index.html with initial content
      ansible.builtin.copy:
        dest: /var/www/html/index.html
        content: "This is a Nautilus sample file, created using Ansible!\n"
        owner: apache
        group: apache
        mode: '0755'

    - name: Add welcome line at the top of index.html
      ansible.builtin.lineinfile:
        path: /var/www/html/index.html
        line: "Welcome to Nautilus Group!"
        insertbefore: BOF
        state: present

    - name: Ensure index.html ownership and permissions
      ansible.builtin.file:
        path: /var/www/html/index.html
        owner: apache
        group: apache
        mode: '0755'
thor@jump-host ~/ansible$ 
```


###


a. Update ~/ansible/playbook.yml playbook to run the httpd role on App Server 2.


b. Create a jinja2 template index.html.j2 under /home/thor/ansible/role/httpd/templates/ directory and add a line This file was created using Ansible on <respective server> (for example This file was created using Ansible on stapp01 in case of App Server 1). Also please make sure not to hard code the server name inside the template. Instead, use inventory_hostname variable to fetch the correct value.


c. Add a task inside /home/thor/ansible/role/httpd/tasks/main.yml to copy this template on App Server 2 under /var/www/html/index.html. Also make sure that /var/www/html/index.html file's permissions are 0644.


d. The user/group owner of /var/www/html/index.html file must be respective sudo user of the server (for example tony in case of stapp01).


Note: Validation will try to run the playbook using command ansible-playbook -i inventory playbook.yml so please make sure the playbook works this way without passing any extra arguments.


```
ansible-playbook -i inventory playbook.yml

PLAY [Run httpd role on App Server 1] **********************************************************************

TASK [Gathering Facts] *************************************************************************************
ok: [stapp01]

TASK [httpd : Install httpd] *******************************************************************************
changed: [stapp01]

TASK [httpd : Start and enable httpd] **********************************************************************
changed: [stapp01]

TASK [httpd : Copy index.html template] ********************************************************************
changed: [stapp01]

PLAY RECAP *************************************************************************************************
stapp01                    : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

thor@jump-host ~/ansible$ ansible -i inventory stapp01 -b -m shell -a \
"cat /var/www/html/index.html && stat -c '%U:%G %a %n' /var/www/html/index.html && systemctl is-enabled httpd && systemctl is-active httpd"
stapp01 | CHANGED | rc=0 >>
This file was created using Ansible on stapp01
tony:tony 655 /var/www/html/index.html
enabled
active
thor@jump-host ~/ansible$ cat playbook.yml 
---
- name: Run httpd role on App Server 1
  hosts: stapp01
  become: true

  roles:
    - httpd
thor@jump-host ~/ansible$ cat inventory 
stapp01 ansible_host=stapp01 ansible_ssh_pass=Ir0nM@n ansible_user=tony
stapp02 ansible_host=stapp02 ansible_ssh_pass=Am3ric@ ansible_user=steve
stapp03 ansible_host=stapp03 ansible_ssh_pass=BigGr33n ansible_user=bannerthor@jump-host ~/ansible$ 
thor@jump-host ~/ansible$ cat /home/thor/ansible/ansible.cfg
[defaults]
host_key_checking = False
roles_path = /home/thor/ansible/role
thor@jump-host ~/ansible$ 
```

### Day 92: Managing Jinja2 Templates Using Ansible


a. Update ~/ansible/playbook.yml playbook to run the httpd role on App Server 1.


b. Create a jinja2 template index.html.j2 under /home/thor/ansible/role/httpd/templates/ directory and add a line This file was created using Ansible on <respective server> (for example This file was created using Ansible on stapp01 in case of App Server 1). Also please make sure not to hard code the server name inside the template. Instead, use inventory_hostname variable to fetch the correct value.


c. Add a task inside /home/thor/ansible/role/httpd/tasks/main.yml to copy this template on App Server 1 under /var/www/html/index.html. Also make sure that /var/www/html/index.html file's permissions are 0655.


d. The user/group owner of /var/www/html/index.html file must be respective sudo user of the server (for example tony in case of stapp01).


Note: Validation will try to run the playbook using command ansible-playbook -i inventory playbook.yml so please make sure the playbook works this way without passing any extra arguments.


```
thor@jump-host ~/ansible$ cat inventory 
stapp01 ansible_host=stapp01 ansible_ssh_pass=Ir0nM@n ansible_user=tony
stapp02 ansible_host=stapp02 ansible_ssh_pass=Am3ric@ ansible_user=steve
stapp03 ansible_host=stapp03 ansible_ssh_pass=BigGr33n ansible_user=bannerthor@jump-host ~/ansible$ 
thor@jump-host ~/ansible$ cat playbook.yml
cat role/httpd/templates/index.html.j2
cat role/httpd/tasks/main.yml
---
- hosts: 
  become: yes
  become_user: root
  roles:
    - role/httpdThis file was created using Ansible on {{ inventory_hostname }}
---
# tasks file for role/test

- name: install the latest version of HTTPD
  yum:
    name: httpd
    state: latest

- name: Start service httpd
  service:
    name: httpd
    state: started


- name: Deploy index.html
  template:
    src: index.html.j2
    dest: /var/www/html/index.html
    owner: "{{ ansible_user }}"
    group: "{{ ansible_user }}"
    mode: '0655'
thor@jump-host ~/ansible$ ansible-inventory -i inventory --graph
@all:
  |--@ungrouped:
  |  |--stapp01
  |  |--stapp02
  |  |--stapp03
thor@jump-host ~/ansible$ ansible-playbook -i inventory playbook.yml
ERROR! Hosts list cannot be empty. Please check your playbook
thor@jump-host ~/ansible$ cat playbook.yml 
---
- hosts: 
  become: yes
  become_user: root
  roles:
    - role/httpdthor@jump-host ~/ansible$ cat inventory 
stapp01 ansible_host=stapp01 ansible_ssh_pass=Ir0nM@n ansible_user=tony
stapp02 ansible_host=stapp02 ansible_ssh_pass=Am3ric@ ansible_user=steve
stapp03 ansible_host=stapp03 ansible_ssh_pass=BigGr33n ansible_user=bannerthor@jump-host ~/ansible$ 
thor@jump-host ~/ansible$ cat > ~/ansible/playbook.yml <<'EOF'
---
- hosts: stapp01
  become: yes
  become_user: root
  roles:
    - role/httpd
EOF
thor@jump-host ~/ansible$ ansible-playbook -i inventory playbook.yml

PLAY [stapp01] *************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************
ok: [stapp01]

TASK [role/httpd : install the latest version of HTTPD] ********************************************************************
changed: [stapp01]

TASK [role/httpd : Start service httpd] ************************************************************************************
changed: [stapp01]

TASK [role/httpd : Deploy index.html] **************************************************************************************
changed: [stapp01]

PLAY RECAP *****************************************************************************************************************
stapp01                    : ok=4    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

thor@jump-host ~/ansible$ ansible -i inventory stapp01 -m shell -a 'ls -l /var/www/html/index.html && cat /var/www/html/index.html'
stapp01 | CHANGED | rc=0 >>
-rw-r-xr-x 1 tony tony 47 Sep 13 17:32 /var/www/html/index.html
This file was created using Ansible on stapp01
thor@jump-host ~/ansible$ 
```

## Day 93: Using Ansible Conditionals

An inventory file is already placed under /home/thor/ansible directory on jump host, with all the Stratos DC app servers included.


Create a playbook /home/thor/ansible/playbook.yml and make sure to use Ansible's when conditionals statements to perform the below given tasks.


Copy blog.txt file present under /usr/src/sysops directory on jump host to App Server 1 under /opt/sysops directory. Its user and group owner must be user tony and its permissions must be 0644 .


Copy story.txt file present under /usr/src/sysops directory on jump host to App Server 2 under /opt/sysops directory. Its user and group owner must be user steve and its permissions must be 0644 .


Copy media.txt file present under /usr/src/sysops directory on jump host to App Server 3 under /opt/sysops directory. Its user and group owner must be user banner and its permissions must be 0644.


NOTE: You can use ansible_nodename variable from gathered facts with when condition. Additionally, please make sure you are running the play for all hosts i.e use - hosts: all.


Note: Validation will try to run the playbook using command ansible-playbook -i inventory playbook.yml, so please make sure the playbook works this way without passing any extra arguments.


```
thor@jump-host ~/ansible$ ansible-playbook -i inventory playbook.yml

PLAY [all] *****************************************************************************************************************

TASK [Gathering Facts] *****************************************************************************************************
ok: [stapp03]
ok: [stapp02]
ok: [stapp01]

TASK [Copy blog.txt to App Server 1] ***************************************************************************************
skipping: [stapp02]
skipping: [stapp03]
changed: [stapp01]

TASK [Copy story.txt to App Server 2] **************************************************************************************
skipping: [stapp01]
skipping: [stapp03]
changed: [stapp02]

TASK [Copy media.txt to App Server 3] **************************************************************************************
skipping: [stapp01]
skipping: [stapp02]
changed: [stapp03]

PLAY RECAP *****************************************************************************************************************
stapp01                    : ok=2    changed=1    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
stapp02                    : ok=2    changed=1    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
stapp03                    : ok=2    changed=1    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   

thor@jump-host ~/ansible$ cat inventory playbook.yml 
stapp01 ansible_host=stapp01 ansible_ssh_pass=Ir0nM@n ansible_user=tony
stapp02 ansible_host=stapp02 ansible_ssh_pass=Am3ric@ ansible_user=steve
stapp03 ansible_host=stapp03 ansible_ssh_pass=BigGr33n ansible_user=banner---
- hosts: all
  become: yes
  tasks:

    - name: Copy blog.txt to App Server 1
      copy:
        src: /usr/src/sysops/blog.txt
        dest: /opt/sysops/blog.txt
        owner: tony
        group: tony
        mode: '0644'
      when: ansible_nodename == "stapp01"

    - name: Copy story.txt to App Server 2
      copy:
        src: /usr/src/sysops/story.txt
        dest: /opt/sysops/story.txt
        owner: steve
        group: steve
        mode: '0644'
      when: ansible_nodename == "stapp02"

    - name: Copy media.txt to App Server 3
      copy:
        src: /usr/src/sysops/media.txt
        dest: /opt/sysops/media.txt
        owner: banner
        group: banner
        mode: '0644'
      when: ansible_nodename == "stapp03"
thor@jump-host ~/ansible$ 
```


## Day 94: Create VPC Using Terraform

Create a VPC named devops-vpc in region us-east-1 with any IPv4 CIDR block through terraform.

The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to accomplish this task.

Note: Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.


```

bob@iac-server ~/terraform via 💠 default ✖ terraform init
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "5.91.0"...
- Installing hashicorp/aws v5.91.0...
- Installed hashicorp/aws v5.91.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

bob@iac-server ~/terraform via 💠 default ➜  terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_vpc.devops_vpc will be created
  + resource "aws_vpc" "devops_vpc" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = (known after apply)
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + tags                                 = {
          + "Name" = "devops-vpc"
        }
      + tags_all                             = {
          + "Name" = "devops-vpc"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take
exactly these actions if you run "terraform apply" now.

bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_vpc.devops_vpc will be created
  + resource "aws_vpc" "devops_vpc" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = (known after apply)
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + tags                                 = {
          + "Name" = "devops-vpc"
        }
      + tags_all                             = {
          + "Name" = "devops-vpc"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
aws_vpc.devops_vpc: Creating...
aws_vpc.devops_vpc: Creation complete after 1s [id=vpc-7ae5f419770c5308f]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

bob@iac-server ~/terraform via 💠 default ➜  terraform state list
aws_vpc.devops_vpc

bob@iac-server ~/terraform via 💠 default ➜  terraform show
# aws_vpc.devops_vpc:
resource "aws_vpc" "devops_vpc" {
    arn                                  = "arn:aws:ec2:us-east-1:000000000000:vpc/vpc-7ae5f419770c5308f"
    assign_generated_ipv6_cidr_block     = false
    cidr_block                           = "10.0.0.0/16"
    default_network_acl_id               = "acl-249d2410d190eb3e3"
    default_route_table_id               = "rtb-c4e3b1833264060c2"
    default_security_group_id            = "sg-3e858c7a550a477e6"
    dhcp_options_id                      = "default"
    enable_dns_hostnames                 = false
    enable_dns_support                   = true
    enable_network_address_usage_metrics = false
    id                                   = "vpc-7ae5f419770c5308f"
    instance_tenancy                     = "default"
    ipv6_association_id                  = null
    ipv6_cidr_block                      = null
    ipv6_cidr_block_network_border_group = null
    ipv6_ipam_pool_id                    = null
    ipv6_netmask_length                  = 0
    main_route_table_id                  = "rtb-c4e3b1833264060c2"
    owner_id                             = "000000000000"
    tags                                 = {
        "Name" = "devops-vpc"
    }
    tags_all                             = {
        "Name" = "devops-vpc"
    }
}

bob@iac-server ~/terraform via 💠 default ➜  ls -lrt
total 16
-rw-rw-r-- 1 bob bob 1116 May 13  2025 provider.tf
-rw-rw-r-- 1 bob bob  435 Jun 19  2025 README.MD
-rw-r--r-- 1 bob bob  110 Sep 13 17:44 main.tf
-rw-r--r-- 1 bob bob 1730 Sep 13 17:45 terraform.tfstate

bob@iac-server ~/terraform via 💠 default ➜  cat provider.tf main.tf 
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.91.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  s3_use_path_style = true

endpoints {
    ec2            = "http://aws:4566"
    apigateway     = "http://aws:4566"
    cloudformation = "http://aws:4566"
    cloudwatch     = "http://aws:4566"
    dynamodb       = "http://aws:4566"
    es             = "http://aws:4566"
    firehose       = "http://aws:4566"
    iam            = "http://aws:4566"
    kinesis        = "http://aws:4566"
    lambda         = "http://aws:4566"
    route53        = "http://aws:4566"
    redshift       = "http://aws:4566"
    s3             = "http://aws:4566"
    secretsmanager = "http://aws:4566"
    ses            = "http://aws:4566"
    sns            = "http://aws:4566"
    sqs            = "http://aws:4566"
    ssm            = "http://aws:4566"
    stepfunctions  = "http://aws:4566"
    sts            = "http://aws:4566"
    rds            = "http://aws:4566"
  }
}
 
 

resource "aws_vpc" "devops_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "devops-vpc"
  }
}

bob@iac-server ~/terraform via 💠 default ➜  
```
 
## Day 95: Create Security Group Using Terraform

Use Terraform to create a security group under the default VPC with the following requirements:

1) The name of the security group must be xfusion-sg.

2) The description must be Security group for Nautilus App Servers.

3) Add an inbound rule of type HTTP, with a port range of 80, and source CIDR range 0.0.0.0/0.

4) Add another inbound rule of type SSH, with a port range of 22, and source CIDR range 0.0.0.0/0.

Ensure that the security group is created in the us-east-1 region using Terraform. The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to accomplish this task.

Note: Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.



```
ob@iac-server ~/terraform via 💠 default ➜  terraform init
terraform plan
terraform apply -auto-approve
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "5.91.0"...
- Installing hashicorp/aws v5.91.0...
- Installed hashicorp/aws v5.91.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
data.aws_vpc.default: Reading...
data.aws_vpc.default: Read complete after 1s [id=vpc-68518d1ff7775c6bd]

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_security_group.xfusion_sg will be created
  + resource "aws_security_group" "xfusion_sg" {
      + arn                    = (known after apply)
      + description            = "Security group for Nautilus App Servers"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "HTTP"
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "SSH"
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
      + name                   = "xfusion-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags_all               = (known after apply)
      + vpc_id                 = "vpc-68518d1ff7775c6bd"
    }

Plan: 1 to add, 0 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take
exactly these actions if you run "terraform apply" now.
data.aws_vpc.default: Reading...
data.aws_vpc.default: Read complete after 0s [id=vpc-68518d1ff7775c6bd]

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_security_group.xfusion_sg will be created
  + resource "aws_security_group" "xfusion_sg" {
      + arn                    = (known after apply)
      + description            = "Security group for Nautilus App Servers"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "HTTP"
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = "SSH"
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
        ]
      + name                   = "xfusion-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags_all               = (known after apply)
      + vpc_id                 = "vpc-68518d1ff7775c6bd"
    }

Plan: 1 to add, 0 to change, 0 to destroy.
aws_security_group.xfusion_sg: Creating...
aws_security_group.xfusion_sg: Creation complete after 1s [id=sg-fbc7e5c1f8a00e06c]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

bob@iac-server ~/terraform via 💠 default ➜  terraform state list
data.aws_vpc.default
aws_security_group.xfusion_sg

bob@iac-server ~/terraform via 💠 default ➜  

bob@iac-server ~/terraform via 💠 default ➜  ls
README.MD  main.tf  provider.tf  terraform.tfstate

bob@iac-server ~/terraform via 💠 default ➜  cat main.tf provider.tf 
 

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "xfusion_sg" {
  name        = "xfusion-sg"
  description = "Security group for Nautilus App Servers"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.91.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  s3_use_path_style = true

endpoints {
    ec2            = "http://aws:4566"
    apigateway     = "http://aws:4566"
    cloudformation = "http://aws:4566"
    cloudwatch     = "http://aws:4566"
    dynamodb       = "http://aws:4566"
    es             = "http://aws:4566"
    firehose       = "http://aws:4566"
    iam            = "http://aws:4566"
    kinesis        = "http://aws:4566"
    lambda         = "http://aws:4566"
    route53        = "http://aws:4566"
    redshift       = "http://aws:4566"
    s3             = "http://aws:4566"
    secretsmanager = "http://aws:4566"
    ses            = "http://aws:4566"
    sns            = "http://aws:4566"
    sqs            = "http://aws:4566"
    ssm            = "http://aws:4566"
    stepfunctions  = "http://aws:4566"
    sts            = "http://aws:4566"
    rds            = "http://aws:4566"
  }
}

bob@iac-server ~/terraform via 💠 default ➜  
```
 
## Day 96: Create EC2 Instance Using Terraform

For this task, create an EC2 instance using Terraform with the following requirements:

The EC2 instance must use the value devops-ec2 as its Name tag, which defines the instance name in AWS.

Use the Amazon Linux ami-0c101f26f147fa7fd to launch this instance.

The Instance type must be t2.micro.

Create a new RSA key named devops-kp.

Attach the default (available by default) security group.

The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to provision the instance.

Note: Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.
```

bob@iac-server ~/terraform via 💠 default ➜  terraform init
terraform plan
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "5.91.0"...
- Finding latest version of hashicorp/tls...
- Installing hashicorp/aws v5.91.0...
- Installed hashicorp/aws v5.91.0 (signed by HashiCorp)
- Installing hashicorp/tls v4.4.1...
- Installed hashicorp/tls v4.4.1 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
data.aws_vpc.default: Reading...
data.aws_vpc.default: Read complete after 1s [id=vpc-70aa29240a6aac20d]
data.aws_security_group.default: Reading...
data.aws_security_group.default: Read complete after 0s [id=sg-84c5886abcbb0e742]

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.devops_ec2 will be created
  + resource "aws_instance" "devops_ec2" {
      + ami                                  = "ami-0c101f26f147fa7fd"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "devops-kp"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "devops-ec2"
        }
      + tags_all                             = {
          + "Name" = "devops-ec2"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = [
          + "sg-84c5886abcbb0e742",
        ]

      + capacity_reservation_specification (known after apply)

      + cpu_options (known after apply)

      + ebs_block_device (known after apply)

      + enclave_options (known after apply)

      + ephemeral_block_device (known after apply)

      + instance_market_options (known after apply)

      + maintenance_options (known after apply)

      + metadata_options (known after apply)

      + network_interface (known after apply)

      + private_dns_name_options (known after apply)

      + root_block_device (known after apply)
    }

  # aws_key_pair.devops_kp will be created
  + resource "aws_key_pair" "devops_kp" {
      + arn             = (known after apply)
      + fingerprint     = (known after apply)
      + id              = (known after apply)
      + key_name        = "devops-kp"
      + key_name_prefix = (known after apply)
      + key_pair_id     = (known after apply)
      + key_type        = (known after apply)
      + public_key      = (known after apply)
      + tags_all        = (known after apply)
    }

  # tls_private_key.devops_kp will be created
  + resource "tls_private_key" "devops_kp" {
      + algorithm                     = "RSA"
      + ecdsa_curve                   = "P224"
      + id                            = (known after apply)
      + private_key_openssh           = (sensitive value)
      + private_key_pem               = (sensitive value)
      + private_key_pem_pkcs8         = (sensitive value)
      + public_key_fingerprint_md5    = (known after apply)
      + public_key_fingerprint_sha256 = (known after apply)
      + public_key_openssh            = (known after apply)
      + public_key_pem                = (known after apply)
      + rsa_bits                      = 2048
    }

Plan: 3 to add, 0 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take
exactly these actions if you run "terraform apply" now.

bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve
data.aws_vpc.default: Reading...
data.aws_vpc.default: Read complete after 0s [id=vpc-70aa29240a6aac20d]
data.aws_security_group.default: Reading...
data.aws_security_group.default: Read complete after 0s [id=sg-84c5886abcbb0e742]

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.devops_ec2 will be created
  + resource "aws_instance" "devops_ec2" {
      + ami                                  = "ami-0c101f26f147fa7fd"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "devops-kp"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "devops-ec2"
        }
      + tags_all                             = {
          + "Name" = "devops-ec2"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = [
          + "sg-84c5886abcbb0e742",
        ]

      + capacity_reservation_specification (known after apply)

      + cpu_options (known after apply)

      + ebs_block_device (known after apply)

      + enclave_options (known after apply)

      + ephemeral_block_device (known after apply)

      + instance_market_options (known after apply)

      + maintenance_options (known after apply)

      + metadata_options (known after apply)

      + network_interface (known after apply)

      + private_dns_name_options (known after apply)

      + root_block_device (known after apply)
    }

  # aws_key_pair.devops_kp will be created
  + resource "aws_key_pair" "devops_kp" {
      + arn             = (known after apply)
      + fingerprint     = (known after apply)
      + id              = (known after apply)
      + key_name        = "devops-kp"
      + key_name_prefix = (known after apply)
      + key_pair_id     = (known after apply)
      + key_type        = (known after apply)
      + public_key      = (known after apply)
      + tags_all        = (known after apply)
    }

  # tls_private_key.devops_kp will be created
  + resource "tls_private_key" "devops_kp" {
      + algorithm                     = "RSA"
      + ecdsa_curve                   = "P224"
      + id                            = (known after apply)
      + private_key_openssh           = (sensitive value)
      + private_key_pem               = (sensitive value)
      + private_key_pem_pkcs8         = (sensitive value)
      + public_key_fingerprint_md5    = (known after apply)
      + public_key_fingerprint_sha256 = (known after apply)
      + public_key_openssh            = (known after apply)
      + public_key_pem                = (known after apply)
      + rsa_bits                      = 2048
    }

Plan: 3 to add, 0 to change, 0 to destroy.
tls_private_key.devops_kp: Creating...
tls_private_key.devops_kp: Creation complete after 0s [id=769f59ba3062a7bf4c52d0d325d4c4e5eda9358b]
aws_key_pair.devops_kp: Creating...
aws_key_pair.devops_kp: Creation complete after 0s [id=devops-kp]
aws_instance.devops_ec2: Creating...
aws_instance.devops_ec2: Still creating... [10s elapsed]
aws_instance.devops_ec2: Creation complete after 10s [id=i-1bfa3df316903fe3a]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

bob@iac-server ~/terraform via 💠 default ➜  terraform state list
data.aws_security_group.default
data.aws_vpc.default
aws_instance.devops_ec2
aws_key_pair.devops_kp
tls_private_key.devops_kp

bob@iac-server ~/terraform via 💠 default ➜  cat main.tf provider.tf 
 
data "aws_vpc" "default" {
  default = true
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

resource "tls_private_key" "devops_kp" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "devops_kp" {
  key_name   = "devops-kp"
  public_key = tls_private_key.devops_kp.public_key_openssh
}

resource "aws_instance" "devops_ec2" {
  ami           = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.devops_kp.key_name

  vpc_security_group_ids = [
    data.aws_security_group.default.id
  ]

  tags = {
    Name = "devops-ec2"
  }
}
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.91.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  s3_use_path_style = true

endpoints {
    ec2            = "http://aws:4566"
    apigateway     = "http://aws:4566"
    cloudformation = "http://aws:4566"
    cloudwatch     = "http://aws:4566"
    dynamodb       = "http://aws:4566"
    es             = "http://aws:4566"
    firehose       = "http://aws:4566"
    iam            = "http://aws:4566"
    kinesis        = "http://aws:4566"
    lambda         = "http://aws:4566"
    route53        = "http://aws:4566"
    redshift       = "http://aws:4566"
    s3             = "http://aws:4566"
    secretsmanager = "http://aws:4566"
    ses            = "http://aws:4566"
    sns            = "http://aws:4566"
    sqs            = "http://aws:4566"
    ssm            = "http://aws:4566"
    stepfunctions  = "http://aws:4566"
    sts            = "http://aws:4566"
    rds            = "http://aws:4566"
  }
}

bob@iac-server ~/terraform via 💠 default ➜  
```
 
## Day 97: Create IAM Policy Using Terraform

Create an IAM policy named iampolicy_kareem in us-east-1 region using Terraform. It must allow read-only access to the EC2 console, i.e., this policy must allow users to view all instances, AMIs, and snapshots in the Amazon EC2 console.

The Terraform working directory is /home/bob/terraform. Create the main.tf file (do not create a different .tf file) to accomplish this task.

Note: Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.
 

```
bob@iac-server ~/terraform via 💠 default ➜  cat main.tf provider.tf 
 

resource "aws_iam_policy" "iampolicy_kareem" {
  name        = "iampolicy_kareem"
  description = "Read-only access to EC2 console"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeImages",
          "ec2:DescribeSnapshots"
        ]

        Resource = "*"
      }
    ]
  })
}
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.91.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  s3_use_path_style = true

endpoints {
    ec2            = "http://aws:4566"
    apigateway     = "http://aws:4566"
    cloudformation = "http://aws:4566"
    cloudwatch     = "http://aws:4566"
    dynamodb       = "http://aws:4566"
    es             = "http://aws:4566"
    firehose       = "http://aws:4566"
    iam            = "http://aws:4566"
    kinesis        = "http://aws:4566"
    lambda         = "http://aws:4566"
    route53        = "http://aws:4566"
    redshift       = "http://aws:4566"
    s3             = "http://aws:4566"
    secretsmanager = "http://aws:4566"
    ses            = "http://aws:4566"
    sns            = "http://aws:4566"
    sqs            = "http://aws:4566"
    ssm            = "http://aws:4566"
    stepfunctions  = "http://aws:4566"
    sts            = "http://aws:4566"
    rds            = "http://aws:4566"
  }
}

bob@iac-server ~/terraform via 💠 default ➜  

bob@iac-server ~/terraform via 💠 default ➜  terraform init
terraform plan
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "5.91.0"...
- Installing hashicorp/aws v5.91.0...
- Installed hashicorp/aws v5.91.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_policy.iampolicy_kareem will be created
  + resource "aws_iam_policy" "iampolicy_kareem" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "Read-only access to EC2 console"
      + id               = (known after apply)
      + name             = "iampolicy_kareem"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "ec2:DescribeInstances",
                          + "ec2:DescribeImages",
                          + "ec2:DescribeSnapshots",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id        = (known after apply)
      + tags_all         = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.

──────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take
exactly these actions if you run "terraform apply" now.

bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_iam_policy.iampolicy_kareem will be created
  + resource "aws_iam_policy" "iampolicy_kareem" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "Read-only access to EC2 console"
      + id               = (known after apply)
      + name             = "iampolicy_kareem"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "ec2:DescribeInstances",
                          + "ec2:DescribeImages",
                          + "ec2:DescribeSnapshots",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + policy_id        = (known after apply)
      + tags_all         = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
aws_iam_policy.iampolicy_kareem: Creating...
aws_iam_policy.iampolicy_kareem: Creation complete after 1s [id=arn:aws:iam::000000000000:policy/iampolicy_kareem]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

bob@iac-server ~/terraform via 💠 default ➜  terraform state list
aws_iam_policy.iampolicy_kareem
```
 
## Day 98: Launch EC2 in Private VPC Subnet Using Terraform
 

Create a VPC named devops-priv-vpc with the CIDR block 10.0.0.0/16.

Create a subnet named devops-priv-subnet inside the VPC with the CIDR block 10.0.1.0/24 and auto-assign IP option must not be enabled.

Create an EC2 instance named devops-priv-ec2 inside the subnet and instance type must be t2.micro.

Ensure the security group of the EC2 instance allows access only from within the VPC's CIDR block.

Create the main.tf file (do not create a separate .tf file) to provision the VPC, subnet and EC2 instance.

Use variables.tf file with the following variable names:

KKE_VPC_CIDR for the VPC CIDR block.
KKE_SUBNET_CIDR for the subnet CIDR block.
Use the outputs.tf file with the following variable names:

KKE_vpc_name for the name of the VPC.
KKE_subnet_name for the name of the subnet.
KKE_ec2_private for the name of the EC2 instance.

```
bob@iac-server ~/terraform via 💠 default ➜  terraform init
terraform validate
terraform plan
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "5.91.0"...
- Installing hashicorp/aws v5.91.0...
- Installed hashicorp/aws v5.91.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
Success! The configuration is valid.

data.aws_availability_zones.available: Reading...
data.aws_ami.amazon_linux: Reading...
data.aws_availability_zones.available: Read complete after 0s [id=us-east-1]
data.aws_ami.amazon_linux: Read complete after 0s [id=ami-07c1fa5792ef8fe27]

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.devops_priv_ec2 will be created
  + resource "aws_instance" "devops_priv_ec2" {
      + ami                                  = "ami-07c1fa5792ef8fe27"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "devops-priv-ec2"
        }
      + tags_all                             = {
          + "Name" = "devops-priv-ec2"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification (known after apply)

      + cpu_options (known after apply)

      + ebs_block_device (known after apply)

      + enclave_options (known after apply)

      + ephemeral_block_device (known after apply)

      + instance_market_options (known after apply)

      + maintenance_options (known after apply)

      + metadata_options (known after apply)

      + network_interface (known after apply)

      + private_dns_name_options (known after apply)

      + root_block_device (known after apply)
    }

  # aws_security_group.devops_priv_sg will be created
  + resource "aws_security_group" "devops_priv_sg" {
      + arn                    = (known after apply)
      + description            = "Allow access only from within VPC"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
                # (1 unchanged attribute hidden)
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "10.0.0.0/16",
                ]
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
                # (1 unchanged attribute hidden)
            },
        ]
      + name                   = "devops-priv-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "devops-priv-sg"
        }
      + tags_all               = {
          + "Name" = "devops-priv-sg"
        }
      + vpc_id                 = (known after apply)
    }

  # aws_subnet.devops_priv_subnet will be created
  + resource "aws_subnet" "devops_priv_subnet" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.1.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Name" = "devops-priv-subnet"
        }
      + tags_all                                       = {
          + "Name" = "devops-priv-subnet"
        }
      + vpc_id                                         = (known after apply)
    }

  # aws_vpc.devops_priv_vpc will be created
  + resource "aws_vpc" "devops_priv_vpc" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = (known after apply)
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + tags                                 = {
          + "Name" = "devops-priv-vpc"
        }
      + tags_all                             = {
          + "Name" = "devops-priv-vpc"
        }
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + KKE_ec2_private = "devops-priv-ec2"
  + KKE_subnet_name = "devops-priv-subnet"
  + KKE_vpc_name    = "devops-priv-vpc"

─────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take
exactly these actions if you run "terraform apply" now.

bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve
data.aws_ami.amazon_linux: Reading...
data.aws_availability_zones.available: Reading...
data.aws_availability_zones.available: Read complete after 0s [id=us-east-1]
data.aws_ami.amazon_linux: Read complete after 0s [id=ami-07c1fa5792ef8fe27]

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.devops_priv_ec2 will be created
  + resource "aws_instance" "devops_priv_ec2" {
      + ami                                  = "ami-07c1fa5792ef8fe27"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "devops-priv-ec2"
        }
      + tags_all                             = {
          + "Name" = "devops-priv-ec2"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification (known after apply)

      + cpu_options (known after apply)

      + ebs_block_device (known after apply)

      + enclave_options (known after apply)

      + ephemeral_block_device (known after apply)

      + instance_market_options (known after apply)

      + maintenance_options (known after apply)

      + metadata_options (known after apply)

      + network_interface (known after apply)

      + private_dns_name_options (known after apply)

      + root_block_device (known after apply)
    }

  # aws_security_group.devops_priv_sg will be created
  + resource "aws_security_group" "devops_priv_sg" {
      + arn                    = (known after apply)
      + description            = "Allow access only from within VPC"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
                # (1 unchanged attribute hidden)
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "10.0.0.0/16",
                ]
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
                # (1 unchanged attribute hidden)
            },
        ]
      + name                   = "devops-priv-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "devops-priv-sg"
        }
      + tags_all               = {
          + "Name" = "devops-priv-sg"
        }
      + vpc_id                 = (known after apply)
    }

  # aws_subnet.devops_priv_subnet will be created
  + resource "aws_subnet" "devops_priv_subnet" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "us-east-1a"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.0.1.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags                                           = {
          + "Name" = "devops-priv-subnet"
        }
      + tags_all                                       = {
          + "Name" = "devops-priv-subnet"
        }
      + vpc_id                                         = (known after apply)
    }

  # aws_vpc.devops_priv_vpc will be created
  + resource "aws_vpc" "devops_priv_vpc" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.0.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_dns_hostnames                 = (known after apply)
      + enable_dns_support                   = true
      + enable_network_address_usage_metrics = (known after apply)
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + tags                                 = {
          + "Name" = "devops-priv-vpc"
        }
      + tags_all                             = {
          + "Name" = "devops-priv-vpc"
        }
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + KKE_ec2_private = "devops-priv-ec2"
  + KKE_subnet_name = "devops-priv-subnet"
  + KKE_vpc_name    = "devops-priv-vpc"
aws_vpc.devops_priv_vpc: Creating...
aws_vpc.devops_priv_vpc: Creation complete after 0s [id=vpc-b68ea5710276a4f2d]
aws_subnet.devops_priv_subnet: Creating...
aws_security_group.devops_priv_sg: Creating...
aws_subnet.devops_priv_subnet: Creation complete after 1s [id=subnet-de75f7d34c48855ec]
aws_security_group.devops_priv_sg: Creation complete after 1s [id=sg-4da4b5b6814b82296]
aws_instance.devops_priv_ec2: Creating...
aws_instance.devops_priv_ec2: Still creating... [10s elapsed]
aws_instance.devops_priv_ec2: Creation complete after 10s [id=i-25cbdbefc5bc39320]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

KKE_ec2_private = "devops-priv-ec2"
KKE_subnet_name = "devops-priv-subnet"
KKE_vpc_name = "devops-priv-vpc"

bob@iac-server ~/terraform via 💠 default ➜  terraform output
KKE_ec2_private = "devops-priv-ec2"
KKE_subnet_name = "devops-priv-subnet"
KKE_vpc_name = "devops-priv-vpc"

bob@iac-server ~/terraform via 💠 default ➜  cat main.tf provider.tf outputs.tf 
 

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

resource "aws_vpc" "devops_priv_vpc" {
  cidr_block = var.KKE_VPC_CIDR

  tags = {
    Name = "devops-priv-vpc"
  }
}

resource "aws_subnet" "devops_priv_subnet" {
  vpc_id                  = aws_vpc.devops_priv_vpc.id
  cidr_block              = var.KKE_SUBNET_CIDR
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "devops-priv-subnet"
  }
}

resource "aws_security_group" "devops_priv_sg" {
  name        = "devops-priv-sg"
  description = "Allow access only from within VPC"
  vpc_id      = aws_vpc.devops_priv_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.KKE_VPC_CIDR]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-priv-sg"
  }
}

resource "aws_instance" "devops_priv_ec2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.devops_priv_subnet.id

  vpc_security_group_ids = [
    aws_security_group.devops_priv_sg.id
  ]

  tags = {
    Name = "devops-priv-ec2"
  }
}
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.91.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  s3_use_path_style = true

endpoints {
    ec2            = "http://aws:4566"
    apigateway     = "http://aws:4566"
    cloudformation = "http://aws:4566"
    cloudwatch     = "http://aws:4566"
    dynamodb       = "http://aws:4566"
    es             = "http://aws:4566"
    firehose       = "http://aws:4566"
    iam            = "http://aws:4566"
    kinesis        = "http://aws:4566"
    lambda         = "http://aws:4566"
    route53        = "http://aws:4566"
    redshift       = "http://aws:4566"
    s3             = "http://aws:4566"
    secretsmanager = "http://aws:4566"
    ses            = "http://aws:4566"
    sns            = "http://aws:4566"
    sqs            = "http://aws:4566"
    ssm            = "http://aws:4566"
    stepfunctions  = "http://aws:4566"
    sts            = "http://aws:4566"
    rds            = "http://aws:4566"
  }
}
output "KKE_vpc_name" {
  value = aws_vpc.devops_priv_vpc.tags["Name"]
}

output "KKE_subnet_name" {
  value = aws_subnet.devops_priv_subnet.tags["Name"]
}

output "KKE_ec2_private" {
  value = aws_instance.devops_priv_ec2.tags["Name"]
}

bob@iac-server ~/terraform via 💠 default ➜  


```

## Day 99: Attach IAM Policy for DynamoDB Access Using Terraform

Create a DynamoDB Table: Create a table named xfusion-table with minimal configuration.

Create an IAM Role: Create an IAM role named xfusion-role that will be allowed to access the table.

Create an IAM Policy: Create a policy named xfusion-readonly-policy that should grant read-only access (GetItem, Scan, Query) to the specific DynamoDB table and attach it to the role.

Create the main.tf file (do not create a separate .tf file) to provision the table, role, and policy.

Create the variables.tf file with the following variables:

KKE_TABLE_NAME: name of the DynamoDB table
KKE_ROLE_NAME: name of the IAM role
KKE_POLICY_NAME: name of the IAM policy
Create the outputs.tf file with the following outputs:

kke_dynamodb_table: name of the DynamoDB table
kke_iam_role_name: name of the IAM role
kke_iam_policy_name: name of the IAM policy
Define the actual values for these variables in the terraform.tfvars file.

Ensure that the IAM policy allows only read access and restricts it to the specific DynamoDB table created.


```
ob@iac-server ~/terraform via 💠 default ➜  terraform init
terraform validate
terraform plan
terraform apply -auto-approve
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "5.91.0"...
- Installing hashicorp/aws v5.91.0...
- Installed hashicorp/aws v5.91.0 (signed by HashiCorp)
Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
Success! The configuration is valid.


Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_dynamodb_table.xfusion_table will be created
  + resource "aws_dynamodb_table" "xfusion_table" {
      + arn              = (known after apply)
      + billing_mode     = "PAY_PER_REQUEST"
      + hash_key         = "id"
      + id               = (known after apply)
      + name             = "xfusion-table"
      + read_capacity    = (known after apply)
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)
      + tags_all         = (known after apply)
      + write_capacity   = (known after apply)

      + attribute {
          + name = "id"
          + type = "S"
        }

      + point_in_time_recovery (known after apply)

      + server_side_encryption (known after apply)

      + ttl (known after apply)
    }

  # aws_iam_policy.xfusion_readonly_policy will be created
  + resource "aws_iam_policy" "xfusion_readonly_policy" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "Read-only access to xfusion DynamoDB table"
      + id               = (known after apply)
      + name             = "xfusion-readonly-policy"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = (known after apply)
      + policy_id        = (known after apply)
      + tags_all         = (known after apply)
    }

  # aws_iam_role.xfusion_role will be created
  + resource "aws_iam_role" "xfusion_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "ec2.amazonaws.com"
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "xfusion-role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags_all              = (known after apply)
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # aws_iam_role_policy_attachment.xfusion_readonly will be created
  + resource "aws_iam_role_policy_attachment" "xfusion_readonly" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "xfusion-role"
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_dynamodb_table  = "xfusion-table"
  + kke_iam_policy_name = "xfusion-readonly-policy"
  + kke_iam_role_name   = "xfusion-role"

──────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take
exactly these actions if you run "terraform apply" now.

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_dynamodb_table.xfusion_table will be created
  + resource "aws_dynamodb_table" "xfusion_table" {
      + arn              = (known after apply)
      + billing_mode     = "PAY_PER_REQUEST"
      + hash_key         = "id"
      + id               = (known after apply)
      + name             = "xfusion-table"
      + read_capacity    = (known after apply)
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)
      + tags_all         = (known after apply)
      + write_capacity   = (known after apply)

      + attribute {
          + name = "id"
          + type = "S"
        }

      + point_in_time_recovery (known after apply)

      + server_side_encryption (known after apply)

      + ttl (known after apply)
    }

  # aws_iam_policy.xfusion_readonly_policy will be created
  + resource "aws_iam_policy" "xfusion_readonly_policy" {
      + arn              = (known after apply)
      + attachment_count = (known after apply)
      + description      = "Read-only access to xfusion DynamoDB table"
      + id               = (known after apply)
      + name             = "xfusion-readonly-policy"
      + name_prefix      = (known after apply)
      + path             = "/"
      + policy           = (known after apply)
      + policy_id        = (known after apply)
      + tags_all         = (known after apply)
    }

  # aws_iam_role.xfusion_role will be created
  + resource "aws_iam_role" "xfusion_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "ec2.amazonaws.com"
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "xfusion-role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags_all              = (known after apply)
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # aws_iam_role_policy_attachment.xfusion_readonly will be created
  + resource "aws_iam_role_policy_attachment" "xfusion_readonly" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "xfusion-role"
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_dynamodb_table  = "xfusion-table"
  + kke_iam_policy_name = "xfusion-readonly-policy"
  + kke_iam_role_name   = "xfusion-role"
aws_iam_role.xfusion_role: Creating...
aws_dynamodb_table.xfusion_table: Creating...
aws_iam_role.xfusion_role: Creation complete after 0s [id=xfusion-role]
aws_dynamodb_table.xfusion_table: Creation complete after 2s [id=xfusion-table]
aws_iam_policy.xfusion_readonly_policy: Creating...
aws_iam_policy.xfusion_readonly_policy: Creation complete after 1s [id=arn:aws:iam::000000000000:policy/xfusion-readonly-policy]
aws_iam_role_policy_attachment.xfusion_readonly: Creating...
aws_iam_role_policy_attachment.xfusion_readonly: Creation complete after 0s [id=xfusion-role-20260913182644505500000001]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

kke_dynamodb_table = "xfusion-table"
kke_iam_policy_name = "xfusion-readonly-policy"
kke_iam_role_name = "xfusion-role"

bob@iac-server ~/terraform via 💠 default ➜  terraform output
kke_dynamodb_table = "xfusion-table"
kke_iam_policy_name = "xfusion-readonly-policy"
kke_iam_role_name = "xfusion-role"

bob@iac-server ~/terraform via 💠 default ➜  cat main.tf provider.tf  variables.tf 
 
resource "aws_dynamodb_table" "xfusion_table" {
  name         = var.KKE_TABLE_NAME
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_role" "xfusion_role" {
  name = var.KKE_ROLE_NAME

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "xfusion_readonly_policy" {
  name        = var.KKE_POLICY_NAME
  description = "Read-only access to xfusion DynamoDB table"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.xfusion_table.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "xfusion_readonly" {
  role       = aws_iam_role.xfusion_role.name
  policy_arn = aws_iam_policy.xfusion_readonly_policy.arn
}
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.91.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  s3_use_path_style = true

endpoints {
    ec2            = "http://aws:4566"
    apigateway     = "http://aws:4566"
    cloudformation = "http://aws:4566"
    cloudwatch     = "http://aws:4566"
    dynamodb       = "http://aws:4566"
    es             = "http://aws:4566"
    firehose       = "http://aws:4566"
    iam            = "http://aws:4566"
    kinesis        = "http://aws:4566"
    lambda         = "http://aws:4566"
    route53        = "http://aws:4566"
    redshift       = "http://aws:4566"
    s3             = "http://aws:4566"
    secretsmanager = "http://aws:4566"
    ses            = "http://aws:4566"
    sns            = "http://aws:4566"
    sqs            = "http://aws:4566"
    ssm            = "http://aws:4566"
    stepfunctions  = "http://aws:4566"
    sts            = "http://aws:4566"
    rds            = "http://aws:4566"
  }
}
variable "KKE_TABLE_NAME" {
  description = "DynamoDB table name"
  type        = string
}

variable "KKE_ROLE_NAME" {
  description = "IAM role name"
  type        = string
}

variable "KKE_POLICY_NAME" {
  description = "IAM policy name"
  type        = string
}

bob@iac-server ~/terraform via 💠 default ➜  
```

## Day 100: Create and Configure Alarm Using CloudWatch Using Terraform

Launch EC2 Instance: Create an EC2 instance named xfusion-ec2 using any appropriate Ubuntu AMI (you can use AMI ami-0c02fb55956c7d316).

Create CloudWatch Alarm: Create a CloudWatch alarm named xfusion-alarm with the following specifications:

Statistic: Average
Metric: CPU Utilization
Threshold: >= 90% for 1 consecutive 5-minute period
Alarm Actions: Send a notification to the xfusion-sns-topic SNS topic.
Update the main.tf file (do not create a separate .tf file) to create a EC2 Instance and CloudWatch Alarm.

Create an outputs.tf file to output the following values:

KKE_instance_name for the EC2 instance name.
KKE_alarm_name for the CloudWatch alarm name.

Notes:

The Terraform working directory is /home/bob/terraform.

Right-click under the EXPLORER section in VS Code and select Open in Integrated Terminal to launch the terminal.

Before submitting the task, ensure that terraform plan returns No changes. Your infrastructure matches the configuration.

```
ob@iac-server ~/terraform via 💠 default ✖ aws --endpoint-url=http://aws:4566 sns list-topics
{
    "Topics": [
        {
            "TopicArn": "arn:aws:sns:us-east-1:000000000000:xfusion-sns-topic"
        }
    ]
}

bob@iac-server ~/terraform via 💠 default ➜  terraform fmt
terraform init
terraform validate
terraform plan
provider.tf
Initializing the backend...
Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v5.91.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
Success! The configuration is valid.

aws_sns_topic.sns_topic: Refreshing state... [id=arn:aws:sns:us-east-1:000000000000:xfusion-sns-topic]

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_cloudwatch_metric_alarm.xfusion_alarm will be created
  + resource "aws_cloudwatch_metric_alarm" "xfusion_alarm" {
      + actions_enabled                       = true
      + alarm_actions                         = [
          + "arn:aws:sns:us-east-1:000000000000:xfusion-sns-topic",
        ]
      + alarm_name                            = "xfusion-alarm"
      + arn                                   = (known after apply)
      + comparison_operator                   = "GreaterThanOrEqualToThreshold"
      + dimensions                            = (known after apply)
      + evaluate_low_sample_count_percentiles = (known after apply)
      + evaluation_periods                    = 1
      + id                                    = (known after apply)
      + metric_name                           = "CPUUtilization"
      + namespace                             = "AWS/EC2"
      + period                                = 300
      + statistic                             = "Average"
      + tags_all                              = (known after apply)
      + threshold                             = 90
      + treat_missing_data                    = "missing"
    }

  # aws_instance.xfusion_ec2 will be created
  + resource "aws_instance" "xfusion_ec2" {
      + ami                                  = "ami-0c02fb55956c7d316"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "xfusion-ec2"
        }
      + tags_all                             = {
          + "Name" = "xfusion-ec2"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification (known after apply)

      + cpu_options (known after apply)

      + ebs_block_device (known after apply)

      + enclave_options (known after apply)

      + ephemeral_block_device (known after apply)

      + instance_market_options (known after apply)

      + maintenance_options (known after apply)

      + metadata_options (known after apply)

      + network_interface (known after apply)

      + private_dns_name_options (known after apply)

      + root_block_device (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + KKE_alarm_name    = "xfusion-alarm"
  + KKE_instance_name = "xfusion-ec2"

─────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take
exactly these actions if you run "terraform apply" now.

bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve
aws_sns_topic.sns_topic: Refreshing state... [id=arn:aws:sns:us-east-1:000000000000:xfusion-sns-topic]

Terraform used the selected providers to generate the following execution plan. Resource actions
are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_cloudwatch_metric_alarm.xfusion_alarm will be created
  + resource "aws_cloudwatch_metric_alarm" "xfusion_alarm" {
      + actions_enabled                       = true
      + alarm_actions                         = [
          + "arn:aws:sns:us-east-1:000000000000:xfusion-sns-topic",
        ]
      + alarm_name                            = "xfusion-alarm"
      + arn                                   = (known after apply)
      + comparison_operator                   = "GreaterThanOrEqualToThreshold"
      + dimensions                            = (known after apply)
      + evaluate_low_sample_count_percentiles = (known after apply)
      + evaluation_periods                    = 1
      + id                                    = (known after apply)
      + metric_name                           = "CPUUtilization"
      + namespace                             = "AWS/EC2"
      + period                                = 300
      + statistic                             = "Average"
      + tags_all                              = (known after apply)
      + threshold                             = 90
      + treat_missing_data                    = "missing"
    }

  # aws_instance.xfusion_ec2 will be created
  + resource "aws_instance" "xfusion_ec2" {
      + ami                                  = "ami-0c02fb55956c7d316"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + enable_primary_ipv6                  = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_lifecycle                   = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + spot_instance_request_id             = (known after apply)
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "xfusion-ec2"
        }
      + tags_all                             = {
          + "Name" = "xfusion-ec2"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification (known after apply)

      + cpu_options (known after apply)

      + ebs_block_device (known after apply)

      + enclave_options (known after apply)

      + ephemeral_block_device (known after apply)

      + instance_market_options (known after apply)

      + maintenance_options (known after apply)

      + metadata_options (known after apply)

      + network_interface (known after apply)

      + private_dns_name_options (known after apply)

      + root_block_device (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + KKE_alarm_name    = "xfusion-alarm"
  + KKE_instance_name = "xfusion-ec2"
aws_instance.xfusion_ec2: Creating...
aws_instance.xfusion_ec2: Still creating... [10s elapsed]
aws_instance.xfusion_ec2: Creation complete after 11s [id=i-60bcc9923b7a67810]
aws_cloudwatch_metric_alarm.xfusion_alarm: Creating...
aws_cloudwatch_metric_alarm.xfusion_alarm: Creation complete after 0s [id=xfusion-alarm]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

KKE_alarm_name = "xfusion-alarm"
KKE_instance_name = "xfusion-ec2"

bob@iac-server ~/terraform via 💠 default ➜  terraform output
KKE_alarm_name = "xfusion-alarm"
KKE_instance_name = "xfusion-ec2"

bob@iac-server ~/terraform via 💠 default ➜  cat main.tf outputs.tf provider.tf 
resource "aws_sns_topic" "sns_topic" {
  name = "xfusion-sns-topic"
}

resource "aws_instance" "xfusion_ec2" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

  tags = {
    Name = "xfusion-ec2"
  }
}

resource "aws_cloudwatch_metric_alarm" "xfusion_alarm" {
  alarm_name          = "xfusion-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  threshold           = 90

  dimensions = {
    InstanceId = aws_instance.xfusion_ec2.id
  }

  alarm_actions = [
    "arn:aws:sns:us-east-1:000000000000:xfusion-sns-topic"
  ]
}output "KKE_instance_name" {
  value = aws_instance.xfusion_ec2.tags["Name"]
}

output "KKE_alarm_name" {
  value = aws_cloudwatch_metric_alarm.xfusion_alarm.alarm_name
}terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.91.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    ec2            = "http://aws:4566"
    apigateway     = "http://aws:4566"
    cloudformation = "http://aws:4566"
    cloudwatch     = "http://aws:4566"
    dynamodb       = "http://aws:4566"
    es             = "http://aws:4566"
    firehose       = "http://aws:4566"
    iam            = "http://aws:4566"
    kinesis        = "http://aws:4566"
    lambda         = "http://aws:4566"
    route53        = "http://aws:4566"
    redshift       = "http://aws:4566"
    s3             = "http://aws:4566"
    secretsmanager = "http://aws:4566"
    ses            = "http://aws:4566"
    sns            = "http://aws:4566"
    sqs            = "http://aws:4566"
    ssm            = "http://aws:4566"
    stepfunctions  = "http://aws:4566"
    sts            = "http://aws:4566"
    rds            = "http://aws:4566"
  }
}

bob@iac-server ~/terraform via 💠 default ➜  
```