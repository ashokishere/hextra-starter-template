## Day 1

```

~ ✖ az login
To sign in, use a web browser to open the page https://login.microsoft.com/device and enter the code G24WVVELM to authenticate.

Retrieving tenants and subscriptions for the selection...

[Tenant and subscription selection]

No     Subscription name    Subscription ID                       Tenant
-----  -------------------  ------------------------------------  ----------------
[1] *  Azure Free Labs      f0c3bcdd-5ce2-4fa0-8cf3-41559747512b  azurefreekmlprod

The default is marked with an *; the default tenant is 'azurefreekmlprod' and subscription is 'Azure Free Labs' (f0c3bcdd-5ce2-4fa0-8cf3-41559747512b).

Select a subscription and tenant (Type a number or Enter for no changes): 

Tenant: azurefreekmlprod
Subscription: Azure Free Labs (f0c3bcdd-5ce2-4fa0-8cf3-41559747512b)

[Announcements]
With the new Azure CLI login experience, you can select the subscription you want to use more easily. Learn more about it and its configuration at https://go.microsoft.com/fwlink/?linkid=2271236

If you encounter any problem, please open an issue at https://aka.ms/azclibug

[Warning] The login output has been updated. Please be aware that it no longer displays the full list of available subscriptions by default.


~ ➜  az group list --output table
Name                          Location    Status
----------------------------  ----------  ---------
kml_rg_main-04fd00398b2c488c  eastus      Succeeded

~ ➜  RG=kml_rg_main-04fd00398b2c488c

~ ➜   az account list-locations --query "[].{DisplayName:displayName, Name:name}" -o table

..
...

~ ➜  REG=westus

~ ➜  az sshkey create   --name nautilus-kp   --resource-group $RG   --location $REG   --encryption-type RSA
No public key is provided. A key pair is being generated for you.
Private key is saved to "/root/.ssh/1778365315_066096".
Public key is saved to "/root/.ssh/1778365315_066096.pub".
{
  "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/KML_RG_MAIN-04FD00398B2C488C/providers/Microsoft.Compute/sshPublicKeys/nautilus-kp",
  "location": "westus",
  "name": "nautilus-kp",
  "publicKey": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNeatH/+rrxu6p4kjjmuuUMfEos2AmWADAQejegNstjyozHoCh5wqq6dC0vsNSuUd7ZPe+mqKGZGbZPnyUmiWqv1+X80q4Be/+S8k8avE5vdkft6BSHw2A39Z4J8wUtzSYHYAvGvpkLClixRdVXe2jO+Wwqt+KOvz9SvMrMlK3n8yBLLjFBmOFlNzdFiyP+bFy7W/CjkyJ9XdGok4qssBb5F5pW1qNReR0Xha3DK8+ORHavXmp+pIn5PUyyLaWEIh4FjVfSm+/d5cfDqBQANJUDQhkqM1v2ow6lzBDWbb/xxx/0qb7IFE1iD0D8pcfFo5q64n9pfnDvH6CYz0t0jL1KoVHgH9rYLh8PrYY/jg8QKvw7wnaKO6jYUaFBvGNft2MlOr5SBrKaeC5WHf+e/dextXKonDtmY6Ilsmbjg818CqvXtSK3qE+nA2pkjpiom8RKnF3LGxpbsZjQ0MojaT2jqqointZ77vO0yr1IvTY5cVpUL9zV/wvZK/6PeccLoU= generated-by-azure",
  "resourceGroup": "KML_RG_MAIN-04FD00398B2C488C",
  "tags": null,
  "type": null
}

~ ➜  az sshkey show --name nautilus-kp --resource-group $RG
{
  "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/KML_RG_MAIN-04FD00398B2C488C/providers/Microsoft.Compute/sshPublicKeys/nautilus-kp",
  "location": "westus",
  "name": "nautilus-kp",
  "publicKey": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDNeatH/+rrxu6p4kjjmuuUMfEos2AmWADAQejegNstjyozHoCh5wqq6dC0vsNSuUd7ZPe+mqKGZGbZPnyUmiWqv1+X80q4Be/+S8k8avE5vdkft6BSHw2A39Z4J8wUtzSYHYAvGvpkLClixRdVXe2jO+Wwqt+KOvz9SvMrMlK3n8yBLLjFBmOFlNzdFiyP+bFy7W/CjkyJ9XdGok4qssBb5F5pW1qNReR0Xha3DK8+ORHavXmp+pIn5PUyyLaWEIh4FjVfSm+/d5cfDqBQANJUDQhkqM1v2ow6lzBDWbb/xxx/0qb7IFE1iD0D8pcfFo5q64n9pfnDvH6CYz0t0jL1KoVHgH9rYLh8PrYY/jg8QKvw7wnaKO6jYUaFBvGNft2MlOr5SBrKaeC5WHf+e/dextXKonDtmY6Ilsmbjg818CqvXtSK3qE+nA2pkjpiom8RKnF3LGxpbsZjQ0MojaT2jqqointZ77vO0yr1IvTY5cVpUL9zV/wvZK/6PeccLoU= generated-by-azure",
  "resourceGroup": "KML_RG_MAIN-04FD00398B2C488C",
  "tags": null,
  "type": null
}

```

## Day 2: Create an Azure Virtual Machine

```
~ ➜  # Login (use the provided credentials)
az login
To sign in, use a web browser to open the page https://login.microsoft.com/device and enter the code GLMFSCXAB to authenticate.

Retrieving tenants and subscriptions for the selection...

[Tenant and subscription selection]

No     Subscription name    Subscription ID                       Tenant
-----  -------------------  ------------------------------------  ----------------
[1] *  Azure Free Labs      f0c3bcdd-5ce2-4fa0-8cf3-41559747512b  azurefreekmlprod

...


~ ➜  az group list --output table
Name                          Location    Status
----------------------------  ----------  ---------
kml_rg_main-eb10d97daf0a4d5a  eastus      Succeeded

~ ➜  RG=kml_rg_main-eb10d97daf0a4d5a

~ ➜  az vm create \
  --resource-group $RG \
  --name datacenter-vm \
  --location centralus \
  --image Ubuntu2404 \
  --size Standard_B1s \
  --admin-username azureuser \
  --generate-ssh-keys \
  --nsg-rule SSH \
  --os-disk-size-gb 30 \
  --storage-sku Standard_LRS \
  --public-ip-sku Standard \
  --output json
SSH key files '/root/.ssh/id_rsa' and '/root/.ssh/id_rsa.pub' have been generated under ~/.ssh to allow SSH access to the VM. If using machines without permanent storage, back up your keys to a safe location.
{
  "fqdns": "",
  "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-eb10d97daf0a4d5a/providers/Microsoft.Compute/virtualMachines/datacenter-vm",
  "location": "centralus",
  "macAddress": "60-45-BD-30-56-7D",
  "powerState": "VM running",
  "privateIpAddress": "10.0.0.4",
  "publicIpAddress": "172.202.43.237",
  "resourceGroup": "kml_rg_main-eb10d97daf0a4d5a",
  "zones": ""
}


~ ✖ az vm show --resource-group $RG --name datacenter-vm --show-details --query "{Name:name, S
tate:powerState, PublicIP:publicIps}" -o table
Name           State       PublicIP
-------------  ----------  --------------
datacenter-vm  VM running  172.202.43.237


~ ➜  ssh azureuser@172.202.43.237
The authenticity of host '172.202.43.237 (172.202.43.237)' can't be established.
ECDSA key fingerprint is SHA256:2WdGclpi0tIjLe5Zc6TG1hEY2NPOO/I3jeKwh9XZaKw.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '172.202.43.237' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 24.04.4 LTS (GNU/Linux 6.17.0-1013-azure x86_64)


```
 

## Day 3: Create VM using Azure CLI

```

Create a Virtual Network (VNet) named nautilus-vnet in the eastus region with any IPv4 CIDR block. Use below given Azure Credentials: (You can run the showcreds command on the azure-client host to retrieve these credentials) what is Virtual Network (VNet) explain and do the activty

An Azure Virtual Network (VNet) is a private network in Azure that allows Azure resources (VMs, databases, containers, etc.) to securely communicate with each other, the internet, and on-premises networks.

Think of a VNet as your own isolated network inside Azure, similar to a traditional data center network.

Key concepts:

- **CIDR block**: Defines the IP address range for the network (example: `10.0.0.0/16`)
- **Subnets**: Smaller network segments inside the VNet
- **Region-specific**: A VNet belongs to one Azure region such as `eastus`

For this task:

1. Retrieve the Azure credentials
2. Login to Azure
3. Create the VNet in `eastus`

Run these commands on the `azure-client` host:

```markdown
# Show lab credentials
showcreds
```

Use the displayed values to login (if not already logged in):

```markdown
az login --service-principal \
  --username <clientId> \
  --password <clientSecret> \
  --tenant <tenantId>
```

Check accessible resource groups:

```markdown
az group list --output table
```

Use the available resource group (for example `kml_rg_main-99c26c7fd61443b7`) and create the VNet:

```markdown
az network vnet create \
  --resource-group kml_rg_main-99c26c7fd61443b7 \
  --name nautilus-vnet \
  --address-prefix 10.0.0.0/16 \
  --location eastus
```

Verify:

```markdown
az network vnet list --output table
```

##  Day 4: Create a Virtual Network (VNet) in Azure

Here’s a practical comparison between an Azure Virtual Network (VNet) and the equivalent networking concept in AWS.

| Concept | Azure | AWS |
| --- | --- | --- |
| Private cloud network | Virtual Network (VNet) | Virtual Private Cloud (VPC) |
| Subdivision of network | Subnet | Subnet |
| Internet access | Internet Gateway functionality built into Azure routing | Internet Gateway (IGW) |
| Private connectivity to on-prem | VPN Gateway / ExpressRoute | VPN Gateway / Direct Connect |
| Security at subnet/NIC level | Network Security Group (NSG) | Security Group + NACL |
| Route management | Route Tables | Route Tables |
| DNS support | Azure DNS | Route 53 / VPC DNS |
| Peering between networks | VNet Peering | VPC Peering |
| Private service access | Private Endpoint | PrivateLink |

---

## Azure VNet

A VNet is your private network inside Azure.

Example:

- IP range: `10.0.0.0/16`
- Subnet for web servers: `10.0.1.0/24`
- Subnet for databases: `10.0.2.0/24`

Resources inside the VNet can communicate privately.

---

## AWS VPC

A VPC is essentially the same idea in AWS.

Example:

- VPC CIDR: `10.0.0.0/16`
- Public subnet: `10.0.1.0/24`
- Private subnet: `10.0.2.0/24`

EC2 instances inside the VPC communicate over private IPs.

---

## Real-World Example

Imagine you deploy:

- 2 web servers
- 1 database server

You do NOT want the database exposed to the internet.

### In Azure

You would:

1. Create a VNet
2. Create:
	- public subnet for web VMs
		- private subnet for DB
3. Attach NSG rules

### In AWS

You would:

1. Create a VPC
2. Create:
	- public subnet
		- private subnet
3. Attach Security Groups

The architecture is almost identical.

---

## Mapping Azure → AWS

| Azure | AWS |
| --- | --- |
| VM | EC2 |
| VNet | VPC |
| NSG | Security Group |
| Load Balancer | ELB/ALB |
| Azure Firewall | AWS Network Firewall |
| Route Table | Route Table |
| VPN Gateway | Virtual Private Gateway |
| ExpressRoute | Direct Connect |

---

## CIDR Block Example

When you created:

```markdown
--address-prefix 10.0.0.0/16
```

it means:

- Network starts at `10.0.0.0`
- Supports ~65,536 IP addresses

Equivalent in AWS:

```markdown
aws ec2 create-vpc --cidr-block 10.0.0.0/16
```

---

## Equivalent Commands

## Azure

```markdown
az network vnet create \
  --name nautilus-vnet \
  --resource-group my-rg \
  --address-prefix 10.0.0.0/16
```

## AWS

```markdown
aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16
```

---

## Key Difference

## Azure

- Networking is tightly integrated into resource groups and subscriptions.
- NSGs can be applied at:
	- subnet level
		- NIC level

## AWS

- More explicit networking objects:
	- Internet Gateway
		- NAT Gateway
		- Route Tables
- Security Groups are stateful firewall rules attached to instances.

---

## Easy Analogy

| Cloud | Think of it as |
| --- | --- |
| Azure VNet | Your office LAN |
| AWS VPC | Your office LAN |

Both provide:

- private IP space
- isolation
- routing
- firewalling
- secure communication

```
~ ✖ az login
To sign in, use a web browser to open the page https://login.microsoft.com/device and enter the code D24WHFKPE to authenticate.

Retrieving tenants and subscriptions for the selection...

[Tenant and subscription selection]

No     Subscription name    Subscription ID                       Tenant
-----  -------------------  ------------------------------------  ----------------
[1] *  Azure Free Labs      f0c3bcdd-5ce2-4fa0-8cf3-41559747512b  azurefreekmlprod

The default is marked with an *; the default tenant is 'azurefreekmlprod' and subscription is 'Azure Free Labs' (f0c3bcdd-5ce2-4fa0-8cf3-41559747512b).

Select a subscription and tenant (Type a number or Enter for no changes): 

Tenant: azurefreekmlprod
Subscription: Azure Free Labs (f0c3bcdd-5ce2-4fa0-8cf3-41559747512b)

[Announcements]
With the new Azure CLI login experience, you can select the subscription you want to use more easily. Learn more about it and its configuration at https://go.microsoft.com/fwlink/?linkid=2271236

If you encounter any problem, please open an issue at https://aka.ms/azclibug

[Warning] The login output has been updated. Please be aware that it no longer displays the full list of available subscriptions by default.


~ ➜  az account show --output table
EnvironmentName    HomeTenantId                          IsDefault    Name             State    TenantDefaultDomain               TenantDisplayName    TenantId
-----------------  ------------------------------------  -----------  ---------------  -------  --------------------------------  -------------------  ------------------------------------
AzureCloud         54c1a2d3-d100-453c-9636-3a109eb45552  True         Azure Free Labs  Enabled  azurefreekmlprod.onmicrosoft.com  azurefreekmlprod     54c1a2d3-d100-453c-9636-3a109eb45552

 

 
~ ✖ az role assignment list --output table


~ ➜  az group list --query "[].name" --output table
Result
----------------------------
kml_rg_main-83093c6f4d404c70

~ ➜  az network vnet create \
  --resource-group kml_rg_main-83093c6f4d404c70 \
  --name nautilus-vnet \
  --address-prefix 10.0.0.0/16 \
  --location eastus
{
  "newVNet": {
    "addressSpace": {
      "addressPrefixes": [
        "10.0.0.0/16"
      ]
    },
    "enableDdosProtection": false,
    "etag": "W/\"14aeb114-1995-40a2-ac1a-947d08dddd56\"",
    "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-83093c6f4d404c70/providers/Microsoft.Network/virtualNetworks/nautilus-vnet",
    "location": "eastus",
    "name": "nautilus-vnet",
    "privateEndpointVNetPolicies": "Disabled",
    "provisioningState": "Succeeded",
    "resourceGroup": "kml_rg_main-83093c6f4d404c70",
    "resourceGuid": "b48ddf36-f4b4-43c6-8b7b-b304796c2ba6",
    "subnets": [],
    "type": "Microsoft.Network/virtualNetworks",
    "virtualNetworkPeerings": []
  }
}

~ ➜  
```

## Day 5: Create a Virtual Network (IPv4) in Azure

### 1) Concept: What is a Virtual Network (VNet)?

A **Virtual Network (VNet)** in Microsoft Azure is a logically isolated network in the cloud where you can securely run your resources (VMs, databases, services, etc.).

Think of it as your **own private data center network inside Azure**.

A VNet allows you to:

- Define your own **IP address range (CIDR block)**
- Create **subnets** to segment workloads
- Control **routing and traffic flow**
- Apply **security rules** (Network Security Groups)
- Connect securely to on-premises networks or other VNets

For this task:

- Name: `devops-vnet`
- Region: `eastus`
- CIDR: `192.168.0.0/24`

---

### 2) Comparison with AWS Networking

In Amazon Web Services, the equivalent concept is:

| Azure | AWS | Purpose |
| --- | --- | --- |
| VNet | VPC (Virtual Private Cloud) | Isolated virtual network |
| Subnet | Subnet | IP segmentation within network |
| NSG (Network Security Group) | Security Groups / NACLs | Traffic filtering |
| VNet Peering | VPC Peering | Network-to-network connectivity |

Key difference:

- Azure VNets are often more **integrated with regional design**
- AWS VPC is **global in concept but regionally scoped in implementation**
- Both use CIDR blocks, but AWS often requires slightly more manual routing setup

---

### 3) Steps to Create VNet in Azure

You can do this using the **Azure Portal** or **Azure CLI**.

---



### 4) What you achieved

After completion, you now have:

- A logically isolated network in Azure
- A defined private IP range: `192.168.0.0/24`
- A foundation to deploy:
	- VMs
		- AKS clusters
		- Databases
		- Microservices

---
 

## 🔁 AWS comparison (important for understanding)

In Amazon Web Services:

| Action | Azure | AWS |
| --- | --- | --- |
| Create network | `virtualNetworks/write` | `ec2:CreateVpc` |
| Permission system | Azure RBAC | IAM Policies |
| Fix access | Assign Role | Attach IAM Policy |

So this is equivalent to:

> “You are trying to create a VPC without IAM permissions in AWS.”

```
~ ✖ az login
To sign in, use a web browser to open the page https://login.microsoft.com/device and enter the code D2XMAK3UZ to authenticate.

 

No     Subscription name    Subscription ID                       Tenant
-----  -------------------  ------------------------------------  ----------------
[1] *  Azure Free Labs      f0c3bcdd-5ce2-4fa0-8cf3-41559747512b  azurefreekmlprod

 

 
~ ✖ az group list -o table
Name                          Location    Status
----------------------------  ----------  ---------
kml_rg_main-6f3822f52a2443cb  eastus      Succeeded

~ ➜  az network vnet create \
  --name devops-vnet \
  --resource-group kml_rg_main-6f3822f52a2443cb \
  --location eastus \
  --address-prefix 192.168.0.0/24
{
  "newVNet": {
    "addressSpace": {
      "addressPrefixes": [
        "192.168.0.0/24"
      ]
    },
    "enableDdosProtection": false,
    "etag": "W/\"8801abb6-88a6-479c-bb5e-19accfdec478\"",
    "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-6f3822f52a2443cb/providers/Microsoft.Network/virtualNetworks/devops-vnet",
    "location": "eastus",
    "name": "devops-vnet",
    "privateEndpointVNetPolicies": "Disabled",
    "provisioningState": "Succeeded",
    "resourceGroup": "kml_rg_main-6f3822f52a2443cb",
    "resourceGuid": "a02c6dff-33e9-4c45-981f-a446e65b78f9",
    "subnets": [],
    "type": "Microsoft.Network/virtualNetworks",
    "virtualNetworkPeerings": []
  }
}

~ ➜  

```
 
 ## Day 6: Create a Subnet in Azure Virtual Network

  

1. **Resource Group name** (required to create both the VNet and subnet)
2. **Subnet CIDR range** (you gave the VNet as `10.0.0.0/16`, but not the subnet range—typically something like `10.0.1.0/24` or similar)




### Why 10.0.1.0/24 was used

Your VNet is:

- **10.0.0.0/16**

That means the full private address space available is:

- 10.0.0.0 → 10.0.255.255 (65,536 IPs total)

Inside that, subnets must be carved out into smaller, non-overlapping ranges.

---

### What /24 means here

A **/24 subnet** gives:

- 256 IP addresses total
- 251 usable IPs in Azure (Azure reserves 5)

So:

- `10.0.1.0/24` = a clean, standard block within the VNet

---

### Why start at 10.0.1.0 instead of 10.0.0.0

Because:

- `10.0.0.0/24` is often reserved for:
	- default gateway planning
		- future “core” subnet
		- hub / shared services subnet in real architectures

So a common convention is:

- `10.0.0.0/24` → infrastructure / shared services
- `10.0.1.0/24` → first workload subnet (like yours)
- `10.0.2.0/24` → next workload subnet, etc.

---

### Why not use something else like /20 or /28?

You *could*, but tradeoffs:

- `/20` → too large for a simple initial subnet (4096 IPs)
- `/28` → too small (11 usable IPs)
- `/24` → **balanced default for most DevOps labs and workloads**

---

### Key rule in Azure networking

Inside a VNet:

- Subnets must be **non-overlapping**
- Subnets must fully fit within the VNet range
- You choose size based on expected workload growth

---
 

---

## 🟦 Azure VNet vs 🟧 AWS VPC (core idea)

| Concept | Azure | AWS |
| --- | --- | --- |
| Main network container | Azure Virtual Network | Amazon VPC |
| Subdivision unit | Subnets | Subnets |
| IP planning scope | VNet-wide + subnet blocks | VPC-wide + subnet blocks |

So structurally: they look similar.

---

## 🧠 Your example mapped to AWS

### Azure setup you used:

- VNet: `10.0.0.0/16`
- Subnet: `10.0.1.0/24`

### Equivalent AWS setup:

- VPC: `10.0.0.0/16`
- Subnet: `10.0.1.0/24`

So conceptually:

> Azure VNet = AWS VPC  
> Azure Subnet = AWS Subnet

---

## 🔑 Key difference: flexibility vs structure

### 1\. AWS is more “freeform”

In AWS:

- You explicitly define everything separately:
	- Create VPC
		- Then create subnet(s)
- No “combined creation” required

Example flow:

```markdown
Create VPC → Create Subnet → Attach routing → Attach IGW/NAT
```

---

### 2\. Azure allows “bundled creation”

In Azure (what you just did):

- You can create:
	- VNet
		- Subnet
		- Addressing  
		in one command

This is more opinionated and structured.

---

## 🧩 Subnet design philosophy difference

### AWS mindset

AWS gives you more freedom but more responsibility:

- You decide:
	- how many subnets
		- which AZ they belong to
		- routing design explicitly

Example:

- `10.0.1.0/24` in us-east-1a
- `10.0.2.0/24` in us-east-1b

---

### Azure mindset

Azure encourages a more “logical grouping” approach:

- Subnets sit inside a VNet
- Services integrate more automatically (NSGs, routing, etc.)
- Less manual network glue work compared to AWS

---

## 🧮 Why /24 behaves the same in both

Both AWS and Azure use standard CIDR rules:

- `/16` → large network (65,536 IPs)
- `/24` → medium subnet (256 IPs)

So:

> IP math is identical in both clouds

The difference is *how you organize and attach services around it*

---

## 🏗️ Practical architecture difference

### AWS typical production layout

```markdown
VPC 10.0.0.0/16
 ├─ Public subnet (10.0.1.0/24)
 ├─ Private subnet (10.0.2.0/24)
 ├─ DB subnet (10.0.3.0/24)
```

You manually wire:

- Route tables
- Internet Gateway
- NAT Gateway

---

### Azure typical production layout

```markdown
VNet 10.0.0.0/16
 ├─ subnet-devops (10.0.1.0/24)
 ├─ subnet-db (10.0.2.0/24)
```

Then you attach:

- NSGs (network security groups)
- Service endpoints / private endpoints

Azure handles more integration automatically.

---

## ⚡ Big takeaway

- AWS = **building blocks + maximum control**
- Azure = **structured networking model + faster setup**

Same CIDR logic, different philosophy.

---
 
 ```
 ~ ➜  showcreds
╒═════════════════════════════╤════════════════════════════════════════════════════════════════════╕
│ Name                        │ Value                                                              │
╞═════════════════════════════╪════════════════════════════════════════════════════════════════════╡
│ Azure Console URL           │ https://portal.azure.com/azurefreekmlprod.onmicrosoft.com          │
├─────────────────────────────┼────────────────────────────────────────────────────────────────────┤
│ Azure User Name             │ kk_lab_user_main-67379a5e90e54693@azurefreekmlprod.onmicrosoft.com │
├─────────────────────────────┼────────────────────────────────────────────────────────────────────┤
│ Azure Password              │ aSH-JVBt                                                           │
├─────────────────────────────┼────────────────────────────────────────────────────────────────────┤
│ Azure Application Client ID │ 4c643e3e-67df-4d21-a4d2-50fc8de87185                               │
├─────────────────────────────┼────────────────────────────────────────────────────────────────────┤
│ Azure Client Secret         │ U4W8Q~0jN2cv-wXwB1_P74k7sIW.SAyeUO5FedgQ                           │
├─────────────────────────────┼────────────────────────────────────────────────────────────────────┤
│ Azure Session End Time      │ Sat May 16 18:06:07 UTC 2026                                       │
╘═════════════════════════════╧════════════════════════════════════════════════════════════════════╛

~ ➜  az group list -o table
Name                          Location    Status
----------------------------  ----------  ---------
kml_rg_main-67379a5e90e54693  eastus      Succeeded

~ ➜  az network vnet create \
  --resource-group kml_rg_main-67379a5e90e54693 \
  --name devops-vnet \
  --location centralus \
  --address-prefix 10.0.0.0/16 \
  --subnet-name devops-subnet \
  --subnet-prefix 10.0.1.0/24
{
  "newVNet": {
    "addressSpace": {
      "addressPrefixes": [
        "10.0.0.0/16"
      ]
    },
    "enableDdosProtection": false,
    "etag": "W/\"cee7fb2d-90b7-4293-a4df-8f0cf6c0fa19\"",
    "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-67379a5e90e54693/providers/Microsoft.Network/virtualNetworks/devops-vnet",
    "location": "centralus",
    "name": "devops-vnet",
    "privateEndpointVNetPolicies": "Disabled",
    "provisioningState": "Succeeded",
    "resourceGroup": "kml_rg_main-67379a5e90e54693",
    "resourceGuid": "e691f81b-c987-4e3f-b8ae-08b5489b17e8",
    "subnets": [
      {
        "addressPrefix": "10.0.1.0/24",
        "delegations": [],
        "etag": "W/\"cee7fb2d-90b7-4293-a4df-8f0cf6c0fa19\"",
        "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-67379a5e90e54693/providers/Microsoft.Network/virtualNetworks/devops-vnet/subnets/devops-subnet",
        "name": "devops-subnet",
        "privateEndpointNetworkPolicies": "Disabled",
        "privateLinkServiceNetworkPolicies": "Enabled",
        "provisioningState": "Succeeded",
        "resourceGroup": "kml_rg_main-67379a5e90e54693",
        "type": "Microsoft.Network/virtualNetworks/subnets"
      }
    ],
    "type": "Microsoft.Network/virtualNetworks",
    "virtualNetworkPeerings": []
  }
}

~ ➜  
 ```