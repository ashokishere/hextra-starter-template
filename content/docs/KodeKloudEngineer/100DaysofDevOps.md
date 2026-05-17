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