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
 


