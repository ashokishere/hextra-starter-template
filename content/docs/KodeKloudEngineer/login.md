---
title: HowtologinKodeKloudEngineer
type: docs
prev: docs/KodeKloudEngineer/
next: docs/KodeKloudEngineer/AWS
sidebar:
  open: true
---

## Single Command Login Examples

## Application Server 1

```markdown
sshpass -p 'Ir0nM@n' ssh -o StrictHostKeyChecking=no tony@stapp01
```

## Application Server 2

```markdown
sshpass -p 'Am3ric@' ssh -o StrictHostKeyChecking=no steve@stapp02
```

## Application Server 3

```markdown
sshpass -p 'BigGr33n' ssh -o StrictHostKeyChecking=no banner@stapp03
```

## Load Balancer

```markdown
sshpass -p 'Mischi3f' ssh -o StrictHostKeyChecking=no loki@stlb01
```

## Database Server

```markdown
sshpass -p 'Sp!dy' ssh -o StrictHostKeyChecking=no peter@stdb01
```

## Storage Server

```markdown
sshpass -p 'Bl@kW' ssh -o StrictHostKeyChecking=no natasha@ststor01
```

## Backup Server

```markdown
sshpass -p 'H@wk3y3' ssh -o StrictHostKeyChecking=no clint@stbkp01
```

## Mail Server

```markdown
sshpass -p 'Gr00T123' ssh -o StrictHostKeyChecking=no groot@stmail01
```

## Jenkins Server

```markdown
sshpass -p 'j@rv!s' ssh -o StrictHostKeyChecking=no jenkins@jenkins
```

---

## Execute Commands Directly

## Check hostname and IP

```markdown
sshpass -p 'Ir0nM@n' ssh -o StrictHostKeyChecking=no tony@stapp01 "hostname && hostname -I"
```

## Check processes

```markdown
sshpass -p 'Ir0nM@n' ssh -o StrictHostKeyChecking=no tony@stapp01 "ps -ef | head"
```

## Check disk usage

```markdown
sshpass -p 'Ir0nM@n' ssh -o StrictHostKeyChecking=no tony@stapp01 "df -h"
```

## Check memory

```markdown
sshpass -p 'Ir0nM@n' ssh -o StrictHostKeyChecking=no tony@stapp01 "free -m"
```

---

## Best Practice (Recommended)

Instead of passwords, configure SSH key authentication:

```markdown
ssh-keygen
ssh-copy-id tony@stapp01
```

Then login becomes:

```markdown
ssh tony@stapp01
```

 


## 1\. Login to Jump Host

```markdown
ssh thor@jump-host
```

Password:

```markdown
mjolnir123
```

---

## 2\. SSH into Each Server

### Application Server 1

```markdown
ssh tony@stapp01
```

### Application Server 2

```markdown
ssh steve@stapp02
```

### Application Server 3

```markdown
ssh banner@stapp03
```

### Load Balancer

```markdown
ssh loki@stlb01
```

### Database Server

```markdown
ssh peter@stdb01
```

### Storage Server

```markdown
ssh natasha@ststor01
```

### Backup Server

```markdown
ssh clint@stbkp01
```

### Mail Server

```markdown
ssh groot@stmail01
```

### Jenkins Server

```markdown
ssh jenkins@jenkins
```

---

## Common Linux Commands for Verification & Troubleshooting

## Check Server IP Address

```markdown
ip addr
```

or

```markdown
hostname -I
```

or

```markdown
ip a
```

---

## Check Hostname

```markdown
hostname
```

---

## Check Running Processes

```markdown
ps -ef
```

or

```markdown
top
```

or

```markdown
htop
```

---

## Check Specific Process

Example: nginx

```markdown
ps -ef | grep nginx
```

Example: mysql

```markdown
ps -ef | grep mysql
```

---

## Check Listening Ports

```markdown
ss -tulnp
```

or

```markdown
netstat -tulnp
```

---

## Check Disk Usage

```markdown
df -h
```

---

## Check Memory Usage

```markdown
free -m
```

---

## Check CPU Usage

```markdown
top
```

or

```markdown
mpstat
```

---

## Check Uptime

```markdown
uptime
```

---

## Check Logged-in Users

```markdown
who
```

---

## Check OS Version

```markdown
cat /etc/os-release
```

---

## Check Service Status

Example:

```markdown
systemctl status nginx
```
```markdown
systemctl status httpd
```
```markdown
systemctl status mysql
```
```markdown
systemctl status jenkins
```

---

## Restart a Service

```markdown
sudo systemctl restart nginx
```

---

## View Logs

System logs:

```markdown
journalctl -xe
```

Application logs:

```markdown
tail -f /var/log/messages
```

or

```markdown
tail -f /var/log/syslog
```

---

## Useful Networking Commands

## Ping Another Server

```markdown
ping stapp01
```

---

## Check DNS Resolution

```markdown
nslookup stapp01
```

---

## Test Port Connectivity

Example port 80:

```markdown
telnet stapp01 80
```

or

```markdown
nc -zv stapp01 80
```

---

## Execute Commands on Remote Server Without Login

Example:

```markdown
ssh tony@stapp01 "hostname && ip addr"
```

Another example:

```markdown
ssh peter@stdb01 "df -h"
```

---

## Copy Files Between Servers

## Copy local → remote

```markdown
scp file.txt tony@stapp01:/tmp/
```

## Copy remote → local

```markdown
scp tony@stapp01:/tmp/file.txt .
```

---

## Switch to Root (if sudo enabled)

```markdown
sudo su -
```

---

## Exit from Server

```markdown
exit
```

Use SSH with `sshpass` for password-based non-interactive login.

## Install sshpass

### RHEL/CentOS

```markdown
sudo yum install -y sshpass
```

### Ubuntu/Debian

```markdown
sudo apt-get install -y sshpass
```

---

