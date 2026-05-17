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
2. **Subnet CIDR range** ( VNet as `10.0.0.0/16`, but not the subnet range—typically something like `10.0.1.0/24` or similar)




### Why 10.0.1.0/24 was used

 VNet is:

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
- `10.0.1.0/24` → first workload subnet  
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

## Day 8: Attach Managed Disk to Azure Virtual Machine

 

### What you’re doing: Public IP allocation in Azure

In Microsoft Azure, a **Public IP address** is a resource that allows Azure services (VMs, load balancers, etc.) to be reachable from the internet.

You’re being asked to:

> Create a Public IP named `nautilus-pip`

This is commonly done during migrations so workloads can:

- be accessed externally (SSH, HTTP, APIs)
- maintain connectivity during phased migration
- support hybrid architectures

---

### Azure concept (simple)

A Public IP in Azure is:

- A standalone resource
- Attached to a VM, NIC, or load balancer
- Can be Static or Dynamic
- Region-specific

Think of it as a “public-facing identity” for a cloud resource.

---

### AWS comparison

In Amazon Web Services:

| Concept | Azure | AWS |
| --- | --- | --- |
| Public IP resource | Public IP Address | Public IPv4 (auto-assigned or Elastic IP) |
| Static public IP | Static Public IP | Elastic IP (EIP) |
| Attached to | NIC / VM / Load Balancer | EC2 instance / ENI |
| Persistence | Optional (Static) | EIP is persistent |

Key difference:

- AWS uses **Elastic IP (EIP)** as a reusable static public IP
- Azure uses a **Public IP resource** that can be static or dynamic

---

 
 
---

### Why this matters in migration (your scenario)

Since Nautilus is doing phased migration:

- Public IPs allow **incremental cutover**
- You can move services one VM at a time
- DNS or routing can be switched gradually
- Reduces downtime risk compared to a “big bang” migration

---
 

---

### Quick concept check

A **resource group in Azure** is basically:

- A container for related resources (VMs, networks, disks, IPs)
- Used for lifecycle management (create/delete everything together)

---

### AWS comparison

In Amazon Web Services:

- Closest equivalent: a mix of **tags + accounts + stacks (CloudFormation)**
- But AWS does NOT have a strict “resource group” container like Azure

v

 ```
 ~ ➜  showcreds
╒═════════════════════════════╤════════════════════════════════════════════════════════════════════╕
│ Name                        │ Value                                                              │
╞═════════════════════════════╪════════════════════════════════════════════════════════════════════╡
│ Azure Console URL           │ https://portal.azure.com/azurefreekmlprod.onmicrosoft.com          │
├─────────────────────────────┼────────────────────────────────────────────────────────────────────┤
│ Azure User Name             │ kk_lab_user_main-0a9c870439d84de1@azurefreekmlprod.onmicrosoft.com │
├─────────────────────────────┼────────────────────────────────────────────────────────────────────┤
│ Azure Password              │ 7DPNG$8N                                                           │
├─────────────────────────────┼────────────────────────────────────────────────────────────────────┤
│ Azure Application Client ID │ 4c8925bf-bfd3-46aa-a802-9381090233da                               │
├─────────────────────────────┼────────────────────────────────────────────────────────────────────┤
│ Azure Client Secret         │ plS8Q~bfLiZIT_LGfzFj9iiBqCS7zIFWQOTBPcwt                           │
├─────────────────────────────┼────────────────────────────────────────────────────────────────────┤
│ Azure Session End Time      │ Sat May 16 18:19:05 UTC 2026                                       │
╘═════════════════════════════╧════════════════════════════════════════════════════════════════════╛

~ ➜  az login
To sign in, use a web browser to open the page https://login.microsoft.com/device and enter the code CTKMH2CRN to authenticate.

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
kml_rg_main-0a9c870439d84de1  eastus      Succeeded

~ ➜  az group show --name <resource-group-name>
-bash: syntax error near unexpected token `newline'

~ ✖ az group show --name kml_rg_main-0a9c870439d84de1
{
  "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-0a9c870439d84de1",
  "location": "eastus",
  "managedBy": null,
  "name": "kml_rg_main-0a9c870439d84de1",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}

~ ➜  az network public-ip create \
  --name nautilus-pip \
  --resource-group kml_rg_main-0a9c870439d84de1 \
  --allocation-method Static \
  --sku Standard
[Coming breaking change] In the coming release, the default behavior will be changed as follows when sku is Standard and zone is not provided: For zonal regions, you will get a zone-redundant IP indicated by zones:["1","2","3"]; For non-zonal regions, you will get a non zone-redundant IP indicated by zones:null.
{
  "publicIp": {
    "ddosSettings": {
      "protectionMode": "VirtualNetworkInherited"
    },
    "etag": "W/\"a71d62a6-c6d0-4ea4-98d1-dfc20f85c243\"",
    "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-0a9c870439d84de1/providers/Microsoft.Network/publicIPAddresses/nautilus-pip",
    "idleTimeoutInMinutes": 4,
    "ipAddress": "20.228.157.81",
    "ipTags": [],
    "location": "eastus",
    "name": "nautilus-pip",
    "provisioningState": "Succeeded",
    "publicIPAddressVersion": "IPv4",
    "publicIPAllocationMethod": "Static",
    "resourceGroup": "kml_rg_main-0a9c870439d84de1",
    "resourceGuid": "29dce163-6f2c-4e9b-bae0-39bef528300a",
    "sku": {
      "name": "Standard",
      "tier": "Regional"
    },
    "type": "Microsoft.Network/publicIPAddresses"
  }
}

~ ➜  

 ```

###

 


 
### Concept: Attaching a data disk to a VM (Azure)

In cloud computing, a **virtual machine (VM)** usually comes with an **operating system (OS) disk**, but you often need extra storage for application data, logs, databases, etc. That’s where a **data disk** comes in.

In your case:

- VM: Azure Virtual Machines (`datacenter-vm`)
- Disk: Azure **managed disk** (`datacenter-disk`)

A **managed disk** in Azure is a durable block storage resource that exists independently of a VM. Attaching it means:

- The VM gains an additional storage volume
- The disk is mounted inside the OS after attachment
- Data persists even if the VM is stopped or rebuilt (as long as the disk isn’t deleted)

So conceptually:

> VM = compute engine  
> Managed disk = external hard drive in the cloud  
> Attaching = plugging the drive into the VM


 
### How Azure does it (key idea)

With Azure Managed Disks:

- Disks are **first-class resources**
- They are created and managed independently
- You explicitly attach/detach them from VMs
- Azure handles redundancy (LRS/ZRS/GRS depending on configuration)

This makes storage:

- More modular
- Easier to scale
- Safer (decoupled lifecycle from VM)

---

## AWS equivalent

In Amazon Web Services, the closest equivalents are:

- VM → Amazon Elastic Compute Cloud (EC2 instance)
- Disk → Amazon Elastic Block Store (EBS volume)

---

### AWS vs Azure comparison

| Concept | Azure | AWS | Key idea |
| --- | --- | --- | --- |
| Compute VM | Azure Virtual Machines | EC2 | Virtual server |
| Block storage | Managed Disks | EBS Volumes | Persistent disk |
| Attach storage | Attach disk to VM | Attach EBS to EC2 | Same concept |
| Lifecycle | Independent disk resource | Independent volume resource | Both decoupled |
| Default behavior | Auto-managed by Azure | More explicit configuration needed | Azure is slightly more automated |

---

### Key differences (practical)

**1\. Abstraction level**

- Azure: Managed Disks hide storage account complexity
- AWS: EBS is simpler historically, but still more visible as a distinct service

**2\. Naming and structure**

- Azure: “data disk” is a role attached to VM
- AWS: “EBS volume” is always the unit; attachment is more explicit

**3\. Flexibility**

- Both allow:
	- Resize disks
		- Snapshots
		- Detach/reattach to other VMs

---

### Mental model

Think of both systems like this:

- VM = laptop
- Disk = external SSD
- Attachment = plugging SSD into laptop
- Data persists independently of the laptop lifecycle

```
~ ➜  az login
To sign in, use a web browser to open the page https://login.microsoft.com/device and enter the code C7DZ3JYUX to authenticate.

Retrieving tenants and subscriptions for the selection...

[Tenant and subscription selection]

No     Subscription name    Subscription ID                       Tenant
-----  -------------------  ------------------------------------  ----------------
[1] *  Azure Free Labs      f0c3bcdd-5ce2-4fa0-8cf3-41559747512b  azurefreekmlprod

 .... 

~ ➜  az group list --output table
Name                          Location    Status
----------------------------  ----------  ---------
kml_rg_main-692f4f8f6d504287  eastus      Succeeded

~ ➜  az vm get-instance-view \
  --name datacenter-vm \
  --resource-group kml_rg_main-692f4f8f6d504287 \
  --query "instanceView.statuses"
[
  {
    "code": "ProvisioningState/succeeded",
    "displayStatus": "Provisioning succeeded",
    "level": "Info",
    "message": null,
    "time": "2026-05-16T17:40:35.142402+00:00"
  },
  {
    "code": "PowerState/running",
    "displayStatus": "VM running",
    "level": "Info",
    "message": null,
    "time": null
  }
]

~ ➜  az vm disk attach \
  --resource-group kml_rg_main-692f4f8f6d504287 \
  --vm-name datacenter-vm \
  --name datacenter-disk

 

~ ✖ az vm show   --resource-group kml_rg_main-692f4f8f6d504287   --name datacenter-vm   --query "storageProfile.d
ataDisks"
[
  {
    "caching": "None",
    "createOption": "Attach",
    "deleteOption": "Detach",
    "detachOption": null,
    "diskIopsReadWrite": null,
    "diskMBpsReadWrite": null,
    "diskSizeGb": 30,
    "image": null,
    "lun": 0,
    "managedDisk": {
      "diskEncryptionSet": null,
      "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-692f4f8f6d504287/providers/Microsoft.Compute/disks/datacenter-disk",
      "resourceGroup": "kml_rg_main-692f4f8f6d504287",
      "securityProfile": null,
      "storageAccountType": "Standard_LRS"
    },
    "name": "datacenter-disk",
    "sourceResource": null,
    "toBeDetached": false,
    "vhd": null,
    "writeAcceleratorEnabled": null
  }
]

~ ➜  
```

## Day 9: Attach Network Interface Card (NIC) to Azure Virtual Machine


In Microsoft Azure, a **Network Interface (NIC)** is the component that connects a Virtual Machine (VM) to a virtual network. It defines:

- Private IP address (static or dynamic)
- Subnet association
- Network Security Group (NSG) rules (firewall-like rules)
- Public IP association (optional)

A VM can have **one or multiple NICs**, depending on its size and architecture design.

Attaching an existing NIC (like `xfusion-nic`) to an existing VM (`xfusion-vm`) means:

- The VM will start using that NIC for network communication
- The NIC must be **detached from any other VM first**
- The VM typically must be **stopped (deallocated)** before modification

---

## Key Requirement in Your Task

You must ensure:

1. VM `xfusion-vm` initialization is complete (VM is fully created and stable)
2. NIC `xfusion-nic` is not attached elsewhere
3. NIC is successfully attached and shows **“Attached” status**
4. VM is running normally after attachment

---

 
You should see:

- `"virtualMachine"` field populated
- Status = **Attached**

---

## AWS Equivalent (Comparison)

In Amazon Web Services, the equivalent concept is:

| Azure | AWS |
| --- | --- |
| Network Interface (NIC) | Elastic Network Interface (ENI) |
| Virtual Machine | Amazon EC2 instance |

---
 

### 2\. Key Differences vs Azure

| Feature | Azure NIC | AWS ENI |
| --- | --- | --- |
| Can attach multiple NICs | Yes | Yes |
| Requires VM stop to attach/detach | Often yes | Sometimes no (depends on case) |
| Managed via resource group | Yes | No (uses VPC scope) |
| IP configuration tied to NIC | Yes | Yes |

---

### 3\. Lifecycle Difference

- Azure NIC is a **first-class resource**
- AWS ENI is also first-class but more tightly bound to **VPC subnet design**

---

## Summary

To complete your task in Azure:

- Stop VM → Attach NIC → Start VM → Verify attachment

Conceptually:

- NIC = network identity of a VM
- Attaching NIC = assigning network configuration to compute instance

AWS equivalent:

- NIC (Azure) ≈ ENI (AWS)
- VM (Azure) ≈ EC2 instance (AWS)

---

 

```

## Azure Steps: Attach Existing NIC to VM

### Step 1: Stop (Deallocate) the VM

Azure does not allow NIC changes while VM is running.

### Step 2: Detach NIC from any existing VM (if needed)

Check current NIC attachments:
  
If attached elsewhere, detach it from that VM first.
 
### Step 3: Attach NIC to the VM
 
### Step 4: Start the VM again
 
### Step 5: Verify NIC Attachment

~ ➜  az login
To sign in, use a web browser to open the page https://login.microsoft.com/device and enter the code D69Z4V6V3 to authenticate.

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
kml_rg_main-8bf68d2ffd1e4dc4  eastus      Succeeded

~ ➜  export RG=kml_rg_main-8bf68d2ffd1e4dc4

~ ➜  az vm deallocate \
  --resource-group $RG \
  --name xfusion-vm

~ ➜  az network nic show \
  --name xfusion-nic \
  --resource-group $RG
{
  "auxiliaryMode": "None",
  "auxiliarySku": "None",
  "disableTcpStateTracking": false,
  "dnsSettings": {
    "appliedDnsServers": [],
    "dnsServers": [],
    "internalDomainNameSuffix": "u3kdvqzdu1nuzfszp5mk4uzmua.gx.internal.cloudapp.net"
  },
  "enableIPForwarding": false,
  "etag": "W/\"e4184711-e2a8-4824-9392-2573093ff307\"",
  "hostedWorkloads": [],
  "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-8bf68d2ffd1e4dc4/providers/Microsoft.Network/networkInterfaces/xfusion-nic",
  "ipConfigurations": [
    {
      "etag": "W/\"e4184711-e2a8-4824-9392-2573093ff307\"",
      "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-8bf68d2ffd1e4dc4/providers/Microsoft.Network/networkInterfaces/xfusion-nic/ipConfigurations/ipconfig1",
      "name": "ipconfig1",
      "primary": true,
      "privateIPAddress": "10.0.0.5",
      "privateIPAddressVersion": "IPv4",
      "privateIPAllocationMethod": "Dynamic",
      "provisioningState": "Succeeded",
      "resourceGroup": "kml_rg_main-8bf68d2ffd1e4dc4",
      "subnet": {
        "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-8bf68d2ffd1e4dc4/providers/Microsoft.Network/virtualNetworks/xfusion-vmVNET/subnets/xfusion-vmSubnet",
        "resourceGroup": "kml_rg_main-8bf68d2ffd1e4dc4"
      },
      "type": "Microsoft.Network/networkInterfaces/ipConfigurations"
    }
  ],
  "location": "centralus",
  "name": "xfusion-nic",
  "nicType": "Standard",
  "provisioningState": "Succeeded",
  "resourceGroup": "kml_rg_main-8bf68d2ffd1e4dc4",
  "resourceGuid": "cb43c959-81e0-4782-971b-4c831d9285b3",
  "tapConfigurations": [],
  "type": "Microsoft.Network/networkInterfaces",
  "vnetEncryptionSupported": false
}

~ ➜  az vm nic add \
  --resource-group $RG \
  --vm-name xfusion-vm \
  --nics xfusion-nic
[
  {
    "deleteOption": null,
    "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-8bf68d2ffd1e4dc4/providers/Microsoft.Network/networkInterfaces/xfusion-vmVMNic",
    "primary": true,
    "resourceGroup": "kml_rg_main-8bf68d2ffd1e4dc4"
  },
  {
    "deleteOption": null,
    "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-8bf68d2ffd1e4dc4/providers/Microsoft.Network/networkInterfaces/xfusion-nic",
    "primary": false,
    "resourceGroup": "kml_rg_main-8bf68d2ffd1e4dc4"
  }
]

~ ➜  az vm start \
  --resource-group $RG \
  --name xfusion-vm

~ ➜  az vm show \
  --resource-group $RG \
  --name xfusion-vm \
  --query "networkProfile.networkInterfaces"
[
  {
    "deleteOption": null,
    "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-8bf68d2ffd1e4dc4/providers/Microsoft.Network/networkInterfaces/xfusion-vmVMNic",
    "primary": true,
    "resourceGroup": "kml_rg_main-8bf68d2ffd1e4dc4"
  },
  {
    "deleteOption": null,
    "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-8bf68d2ffd1e4dc4/providers/Microsoft.Network/networkInterfaces/xfusion-nic",
    "primary": false,
    "resourceGroup": "kml_rg_main-8bf68d2ffd1e4dc4"
  }
]

~ ➜  az network nic show \
  --name xfusion-nic \
  --resource-group $RG
{
  "auxiliaryMode": "None",
  "auxiliarySku": "None",
  "disableTcpStateTracking": false,
  "dnsSettings": {
    "appliedDnsServers": [],
    "dnsServers": []
  },
  "enableIPForwarding": false,
  "etag": "W/\"2d70a995-3015-4e3b-b8fe-e2f090e1558d\"",
  "hostedWorkloads": [],
  "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-8bf68d2ffd1e4dc4/providers/Microsoft.Network/networkInterfaces/xfusion-nic",
  "ipConfigurations": [
    {
      "etag": "W/\"2d70a995-3015-4e3b-b8fe-e2f090e1558d\"",
      "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-8bf68d2ffd1e4dc4/providers/Microsoft.Network/networkInterfaces/xfusion-nic/ipConfigurations/ipconfig1",
      "name": "ipconfig1",
      "primary": true,
      "privateIPAddress": "10.0.0.5",
      "privateIPAddressVersion": "IPv4",
      "privateIPAllocationMethod": "Dynamic",
      "provisioningState": "Succeeded",
      "resourceGroup": "kml_rg_main-8bf68d2ffd1e4dc4",
      "subnet": {
        "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-8bf68d2ffd1e4dc4/providers/Microsoft.Network/virtualNetworks/xfusion-vmVNET/subnets/xfusion-vmSubnet",
        "resourceGroup": "kml_rg_main-8bf68d2ffd1e4dc4"
      },
      "type": "Microsoft.Network/networkInterfaces/ipConfigurations"
    }
  ],
  "location": "centralus",
  "macAddress": "70-A8-A5-AA-14-58",
  "name": "xfusion-nic",
  "nicType": "Standard",
  "primary": false,
  "provisioningState": "Succeeded",
  "resourceGroup": "kml_rg_main-8bf68d2ffd1e4dc4",
  "resourceGuid": "cb43c959-81e0-4782-971b-4c831d9285b3",
  "tapConfigurations": [],
  "type": "Microsoft.Network/networkInterfaces",
  "virtualMachine": {
    "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-8bf68d2ffd1e4dc4/providers/Microsoft.Compute/virtualMachines/xfusion-vm",
    "resourceGroup": "kml_rg_main-8bf68d2ffd1e4dc4"
  },
  "vnetEncryptionSupported": false
}

~ ➜  
```
## Day 10: Attach Public IP to Azure Virtual Machine

An existing VM named xfusion-vm-pip and a public IP address named xfusion-pip already exist.

Attach the public IP xfusion-pip to the network interface of the VM xfusion-vm-pip.
Make sure the VM is properly assigned the public IP.

 
# Concept: What you’re doing (Public IP ↔ VM NIC)

A public IP address is not “assigned to a VM directly” in most cloud platforms. Instead, it is attached to the **network interface (NIC)** that the VM uses.

So the chain looks like:

**Public IP → NIC (Network Interface Card) → VM**

This separation exists because:

- A VM can have multiple NICs
- A NIC can have multiple IP configurations (in some designs)
- IPs can be reassigned without touching the VM itself

In this case:

- VM: `xfusion-vm-pip`
- Public IP: `xfusion-pip`
- Task: attach `xfusion-pip` to the VM’s NIC

---

## How this maps in AWS (comparison)

| Concept | Azure-style (your task) | AWS equivalent |
| --- | --- | --- |
| Public IP resource | Public IP (`xfusion-pip`) | Elastic IP (EIP) |
| Network attachment point | NIC (Network Interface) | ENI (Elastic Network Interface) |
| VM | Virtual Machine | EC2 Instance |
| Association action | Attach Public IP to NIC | Associate EIP with ENI or EC2 instance |

### Key difference:

- **Azure**: Public IP is a standalone resource you attach to a NIC configuration.
- **AWS**: Elastic IP is explicitly “associated” with an instance or ENI.

---

 
 
 

 

## Summary

- You are not “assigning IP to VM directly”
- You are attaching it to the VM’s **NIC**
- Azure uses **Public IP resource + NIC binding**
- AWS uses **Elastic IP association with instance/ENI**
 

---

## AWS comparison (to make it clearer)

In AWS:

- NIC equivalent = **ENI (Elastic Network Interface)**
- You would do:
	```markdown
	aws ec2 describe-instances
	```
	then find:
	- `NetworkInterfaces → Description → NetworkInterfaceId`

---
 
 

 

 
 
 

---

## 🧠 Why this happened (important concept)

Azure NICs can auto-generate IP config names based on VM name:

| Component | Your value |
| --- | --- |
| NIC | xfusion-vm-pipVMNic |
| IP Config | ipconfigxfusion-vm-pip |
| Private IP | 10.0.0.4 |

So there is **no universal default like `ipconfig1`** unless explicitly created that way.

---

## 🔁 AWS comparison (to lock it in)

In AWS:

- ENI always has predictable:
	```markdown
	eth0
	```
- Elastic IP attaches without needing IP config names

In Azure:

- You MUST match:
	```markdown
	NIC → ipConfig name → public IP
	```
- If name is wrong → ResourceNotFoundError (exactly what you saw)

---

 

 
```
~ ➜  az login
To sign in, use a web browser to open the page https://login.microsoft.com/device and enter the code DQF36QHF3 to authenticate.

Retrieving tenants and subscriptions for the selection...

[Tenant and subscription selection]

No     Subscription name    Subscription ID                       Tenant
-----  -------------------  ------------------------------------  ----------------
[1] *  Azure Free Labs      f0c3bcdd-5ce2-4fa0-8cf3-41559747512b  azurefreekmlprod

 
 
~ ➜  az group list --output table
Name                          Location    Status
----------------------------  ----------  ---------
kml_rg_main-50c3279c710b45b2  eastus      Succeeded

~ ➜  export rg=kml_rg_main-50c3279c710b45b2

 

~ ✖ az vm nic list --resource-group $rg --vm-name xfusion-vm-pip
[
  {
    "deleteOption": null,
    "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-50c3279c710b45b2/providers/Microsoft.Network/networkInterfaces/xfusion-vm-pipVMNic",
    "primary": null,
    "resourceGroup": "kml_rg_main-50c3279c710b45b2"
  }
]

~ ➜  az vm nic list --resource-group $rg --vm-name xfusion-vm-pip -o table
ResourceGroup
----------------------------
kml_rg_main-50c3279c710b45b2

~ ➜  az vm nic list --resource-group $rg --vm-name xfusion-vm-pip --query "[].name" -o tsv

 
 

~ ✖ az network nic show \
  -g $rg \
  -n xfusion-vm-pipVMNic
{
  "auxiliaryMode": "None",
  "auxiliarySku": "None",
  "disableTcpStateTracking": false,
  "dnsSettings": {
    "appliedDnsServers": [],
    "dnsServers": [],
    "internalDomainNameSuffix": "xokict1comyudjiazfeid5ypja.dx.internal.cloudapp.net"
  },
  "enableIPForwarding": false,
  "etag": "W/\"97dc0e59-e571-43ce-9ce3-29d515169978\"",
  "hostedWorkloads": [],
  "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-50c3279c710b45b2/providers/Microsoft.Network/networkInterfaces/xfusion-vm-pipVMNic",
  "ipConfigurations": [
    {
      "etag": "W/\"97dc0e59-e571-43ce-9ce3-29d515169978\"",
      "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-50c3279c710b45b2/providers/Microsoft.Network/networkInterfaces/xfusion-vm-pipVMNic/ipConfigurations/ipconfigxfusion-vm-pip",
      "name": "ipconfigxfusion-vm-pip",
      "primary": true,
      "privateIPAddress": "10.0.0.4",
      "privateIPAddressVersion": "IPv4",
      "privateIPAllocationMethod": "Dynamic",
      "provisioningState": "Succeeded",
      "resourceGroup": "kml_rg_main-50c3279c710b45b2",
      "subnet": {
        "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-50c3279c710b45b2/providers/Microsoft.Network/virtualNetworks/xfusion-vm-pipVNET/subnets/xfusion-vm-pipSubnet",
        "resourceGroup": "kml_rg_main-50c3279c710b45b2"
      },
      "type": "Microsoft.Network/networkInterfaces/ipConfigurations"
    }
  ],
  "location": "westus",
  "macAddress": "00-0D-3A-37-F1-87",
  "name": "xfusion-vm-pipVMNic",
  "networkSecurityGroup": {
    "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-50c3279c710b45b2/providers/Microsoft.Network/networkSecurityGroups/xfusion-vm-pipNSG",
    "resourceGroup": "kml_rg_main-50c3279c710b45b2"
  },
  "nicType": "Standard",
  "primary": true,
  "provisioningState": "Succeeded",
  "resourceGroup": "kml_rg_main-50c3279c710b45b2",
  "resourceGuid": "c36421dc-3849-444d-b13c-d8e48aa643f0",
  "tags": {},
  "tapConfigurations": [],
  "type": "Microsoft.Network/networkInterfaces",
  "virtualMachine": {
    "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-50c3279c710b45b2/providers/Microsoft.Compute/virtualMachines/xfusion-vm-pip",
    "resourceGroup": "kml_rg_main-50c3279c710b45b2"
  },
  "vnetEncryptionSupported": false
}

~ ➜  az network nic ip-config update \
  --resource-group $rg \
  --nic-name xfusion-vm-pipVMNic \
  --name ipconfigxfusion-vm-pip \
  --public-ip-address xfusion-pip
{
  "etag": "W/\"9e2e7254-f654-4232-8063-b39fa1f6c114\"",
  "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-50c3279c710b45b2/providers/Microsoft.Network/networkInterfaces/xfusion-vm-pipVMNic/ipConfigurations/ipconfigxfusion-vm-pip",
  "name": "ipconfigxfusion-vm-pip",
  "primary": true,
  "privateIPAddress": "10.0.0.4",
  "privateIPAddressVersion": "IPv4",
  "privateIPAllocationMethod": "Dynamic",
  "provisioningState": "Succeeded",
  "publicIPAddress": {
    "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-50c3279c710b45b2/providers/Microsoft.Network/publicIPAddresses/xfusion-pip",
    "resourceGroup": "kml_rg_main-50c3279c710b45b2"
  },
  "resourceGroup": "kml_rg_main-50c3279c710b45b2",
  "subnet": {
    "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-50c3279c710b45b2/providers/Microsoft.Network/virtualNetworks/xfusion-vm-pipVNET/subnets/xfusion-vm-pipSubnet",
    "resourceGroup": "kml_rg_main-50c3279c710b45b2"
  },
  "type": "Microsoft.Network/networkInterfaces/ipConfigurations"
}

~ ➜  

```

## Day 11: Change Azure Virtual Machine Size Using Console

1) Change the VM size from Standard_B1s to Standard_B2s for the virtual machine named xfusion-vm.

2) Ensure the VM is in the running state after the size change is complete.

---

# Concept: What you are doing (VM resize)

You are **changing the VM “size” (SKU)** from:

- **Standard\_B1s → Standard\_B2s**

This does **not reinstall the OS** or change disks. It only changes:

- CPU count
- RAM
- performance tier
- cost

Think of it as **upgrading the hardware profile of a running machine**.

However:

- Azure may **stop (deallocate) the VM briefly**
- Then reallocate it with the new size
- So the VM may restart depending on configuration and availability

---
  
## 4) Key concept behind “Size change”

Azure VM sizes belong to a **family hierarchy**:

- B-series = burstable (cheap, baseline CPU + burst credits)
- B1s = very small (1 vCPU, low RAM)
- B2s = larger burstable (2 vCPU, more RAM)

So this upgrade:

- increases compute capacity
- increases cost
- improves performance headroom

---
 

 
## 6) Quick comparison table

| Cloud | Term | Action required | Unit changed |
| --- | --- | --- | --- |
| Azure | VM Size | Stop/Deallocate (often) | VM Size (B2s) |
| AWS | Instance Type | Stop instance | Instance Type (t3.small) |
| GCP | Machine Type | Stop VM | Machine Type (e2-small) |

---

## 7) Key takeaway

All three clouds do the same thing:

> “Resize compute resources by changing the VM hardware profile”

But:

- Azure calls it **VM Size**
- AWS calls it **Instance Type**
- GCP calls it **Machine Type**

---
 

```
~ ➜  az group list -o table
Name                          Location    Status
----------------------------  ----------  ---------
kml_rg_main-8c443cef38de4173  eastus      Succeeded

~ ➜  export RG=kml_rg_main-8c443cef38de4173

~ ➜  az vm get-instance-view -g $RG -n xfusion-vm
{
  "additionalCapabilities": null,
  "applicationProfile": null,
  "availabilitySet": null,
  "billingProfile": null,
  "capacityReservation": null,
  "diagnosticsProfile": null,
  "etag": "\"1\"",
  "evictionPolicy": null,
  "extendedLocation": null,
  "extensionsTimeBudget": null,
  "hardwareProfile": {
    "vmSize": "Standard_B1s",
    "vmSizeProperties": null
  },
  "host": null,
  "hostGroup": null,
  "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-8c443cef38de4173/providers/Microsoft.Compute/virtualMachines/xfusion-vm",
  "identity": null,
  "instanceView": {
    "assignedHost": null,
    "bootDiagnostics": null,
    "computerName": "xfusion-vm",
    "disks": [
      {
        "encryptionSettings": null,
        "name": "xfusion-vm_OsDisk_1_6012820ba6dd4414bec63e71efcbbfb8",
        "statuses": [
          {
            "code": "ProvisioningState/succeeded",
            "displayStatus": "Provisioning succeeded",
            "level": "Info",
            "message": null,
            "time": "2026-05-16T20:10:06.943863+00:00"
          }
        ]
      }
    ],
    "extensions": null,
    "hyperVGeneration": "V2",
    "isVmInStandbyPool": null,
    "maintenanceRedeployStatus": null,
    "osName": "ubuntu",
    "osVersion": "22.04",
    "patchStatus": null,
    "platformFaultDomain": null,
    "platformUpdateDomain": null,
    "rdpThumbPrint": null,
    "statuses": [
      {
        "code": "ProvisioningState/succeeded",
        "displayStatus": "Provisioning succeeded",
        "level": "Info",
        "message": null,
        "time": "2026-05-16T20:10:41.793495+00:00"
      },
      {
        "code": "PowerState/running",
        "displayStatus": "VM running",
        "level": "Info",
        "message": null,
        "time": null
      }
    ],
    "vmAgent": {
      "extensionHandlers": [],
      "statuses": [
        {
          "code": "ProvisioningState/succeeded",
          "displayStatus": "Ready",
          "level": "Info",
          "message": "Guest Agent is running",
          "time": "2026-05-16T20:22:56+00:00"
        }
      ],
      "vmAgentVersion": "2.15.1.3"
    },
    "vmHealth": null
  },
  "licenseType": null,
  "location": "westus",
  "managedBy": null,
  "name": "xfusion-vm",
  "networkProfile": {
    "networkApiVersion": null,
    "networkInterfaceConfigurations": null,
    "networkInterfaces": [
      {
        "deleteOption": null,
        "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-8c443cef38de4173/providers/Microsoft.Network/networkInterfaces/xfusion-vmVMNic",
        "primary": null,
        "resourceGroup": "kml_rg_main-8c443cef38de4173"
      }
    ]
  },
  "osProfile": {
    "adminPassword": null,
    "adminUsername": "azureuser",
    "allowExtensionOperations": true,
    "computerName": "xfusion-vm",
    "customData": null,
    "linuxConfiguration": {
      "disablePasswordAuthentication": true,
      "enableVmAgentPlatformUpdates": null,
      "patchSettings": {
        "assessmentMode": "ImageDefault",
        "automaticByPlatformSettings": null,
        "patchMode": "ImageDefault"
      },
      "provisionVmAgent": true,
      "ssh": {
        "publicKeys": [
          {
            "keyData": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCx10FeMG5ez3bS9kPJ102ZsrcxPZgJosiWdKAhLLm2yAeTjXbfYCAr1MwzG/8/Mabwz7mkfHDvnMaoCPrlj/C3AQ2Jwy8ru01YnFZZ8eKN2LtA9wWLGIITgc1TtRq9OSOEgIf4KBzsVnHgOVwqqCxNHmglKxesD+fEC8j2DD8XX9wiA/SSnb8LAmutJka3tdp7tO9iiC2NjzZ8dVMuLxWXcJXednKxDfrPMnq89PXsYXJuI+8+VS3EAZkyWla/Wt/U2IVh+1brL4CmvadyZO13ksgPX5pr3O1MBU/WtjL26AKqc6UlgKjJ4pGvNcnSt6+eW3o711HHUt77IH6pigcF root@azure-client\n",
            "path": "/home/azureuser/.ssh/authorized_keys"
          }
        ]
      }
    },
    "requireGuestProvisionSignal": true,
    "secrets": [],
    "windowsConfiguration": null
  },
  "plan": null,
  "platformFaultDomain": null,
  "priority": null,
  "provisioningState": "Succeeded",
  "proximityPlacementGroup": null,
  "resourceGroup": "kml_rg_main-8c443cef38de4173",
  "resources": null,
  "scheduledEventsPolicy": null,
  "scheduledEventsProfile": null,
  "securityProfile": {
    "encryptionAtHost": null,
    "encryptionIdentity": null,
    "proxyAgentSettings": null,
    "securityType": "TrustedLaunch",
    "uefiSettings": {
      "secureBootEnabled": true,
      "vTpmEnabled": true
    }
  },
  "storageProfile": {
    "dataDisks": [],
    "diskControllerType": "SCSI",
    "imageReference": {
      "communityGalleryImageId": null,
      "exactVersion": "22.04.202605030",
      "id": null,
      "offer": "0001-com-ubuntu-server-jammy",
      "publisher": "Canonical",
      "sharedGalleryImageId": null,
      "sku": "22_04-lts-gen2",
      "version": "latest"
    },
    "osDisk": {
      "caching": "ReadWrite",
      "createOption": "FromImage",
      "deleteOption": "Detach",
      "diffDiskSettings": null,
      "diskSizeGb": 30,
      "encryptionSettings": null,
      "image": null,
      "managedDisk": {
        "diskEncryptionSet": null,
        "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-8c443cef38de4173/providers/Microsoft.Compute/disks/xfusion-vm_OsDisk_1_6012820ba6dd4414bec63e71efcbbfb8",
        "resourceGroup": "kml_rg_main-8c443cef38de4173",
        "securityProfile": null,
        "storageAccountType": "Standard_LRS"
      },
      "name": "xfusion-vm_OsDisk_1_6012820ba6dd4414bec63e71efcbbfb8",
      "osType": "Linux",
      "vhd": null,
      "writeAcceleratorEnabled": null
    }
  },
  "tags": {},
  "timeCreated": "2026-05-16T20:10:03.969806+00:00",
  "type": "Microsoft.Compute/virtualMachines",
  "userData": null,
  "virtualMachineScaleSet": null,
  "vmId": "07fe64b1-f30c-4489-8846-2f8726ec6b80",
  "zones": null
}

~ ➜  az vm deallocate -g $RG -n xfusion-vm

~ ➜  az vm resize \
  -g $RG \
  -n xfusion-vm \
  --size Standard_B2s
{
  "additionalCapabilities": null,
  "applicationProfile": null,
  "availabilitySet": null,
  "billingProfile": null,
  "capacityReservation": null,
  "diagnosticsProfile": null,
  "etag": "\"5\"",
  "evictionPolicy": null,
  "extendedLocation": null,
  "extensionsTimeBudget": null,
  "hardwareProfile": {
    "vmSize": "Standard_B2s",
    "vmSizeProperties": null
  },
  "host": null,
  "hostGroup": null,
  "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-8c443cef38de4173/providers/Microsoft.Compute/virtualMachines/xfusion-vm",
  "identity": null,
  "instanceView": null,
  "licenseType": null,
  "location": "westus",
  "managedBy": null,
  "name": "xfusion-vm",
  "networkProfile": {
    "networkApiVersion": null,
    "networkInterfaceConfigurations": null,
    "networkInterfaces": [
      {
        "deleteOption": null,
        "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-8c443cef38de4173/providers/Microsoft.Network/networkInterfaces/xfusion-vmVMNic",
        "primary": null,
        "resourceGroup": "kml_rg_main-8c443cef38de4173"
      }
    ]
  },
  "osProfile": {
    "adminPassword": null,
    "adminUsername": "azureuser",
    "allowExtensionOperations": true,
    "computerName": "xfusion-vm",
    "customData": null,
    "linuxConfiguration": {
      "disablePasswordAuthentication": true,
      "enableVmAgentPlatformUpdates": null,
      "patchSettings": {
        "assessmentMode": "ImageDefault",
        "automaticByPlatformSettings": null,
        "patchMode": "ImageDefault"
      },
      "provisionVmAgent": true,
      "ssh": {
        "publicKeys": [
          {
            "keyData": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCx10FeMG5ez3bS9kPJ102ZsrcxPZgJosiWdKAhLLm2yAeTjXbfYCAr1MwzG/8/Mabwz7mkfHDvnMaoCPrlj/C3AQ2Jwy8ru01YnFZZ8eKN2LtA9wWLGIITgc1TtRq9OSOEgIf4KBzsVnHgOVwqqCxNHmglKxesD+fEC8j2DD8XX9wiA/SSnb8LAmutJka3tdp7tO9iiC2NjzZ8dVMuLxWXcJXednKxDfrPMnq89PXsYXJuI+8+VS3EAZkyWla/Wt/U2IVh+1brL4CmvadyZO13ksgPX5pr3O1MBU/WtjL26AKqc6UlgKjJ4pGvNcnSt6+eW3o711HHUt77IH6pigcF root@azure-client\n",
            "path": "/home/azureuser/.ssh/authorized_keys"
          }
        ]
      }
    },
    "requireGuestProvisionSignal": true,
    "secrets": [],
    "windowsConfiguration": null
  },
  "plan": null,
  "platformFaultDomain": null,
  "priority": null,
  "provisioningState": "Succeeded",
  "proximityPlacementGroup": null,
  "resourceGroup": "kml_rg_main-8c443cef38de4173",
  "resources": null,
  "scheduledEventsPolicy": null,
  "scheduledEventsProfile": null,
  "securityProfile": {
    "encryptionAtHost": null,
    "encryptionIdentity": null,
    "proxyAgentSettings": null,
    "securityType": "TrustedLaunch",
    "uefiSettings": {
      "secureBootEnabled": true,
      "vTpmEnabled": true
    }
  },
  "storageProfile": {
    "dataDisks": [],
    "diskControllerType": "SCSI",
    "imageReference": {
      "communityGalleryImageId": null,
      "exactVersion": "22.04.202605030",
      "id": null,
      "offer": "0001-com-ubuntu-server-jammy",
      "publisher": "Canonical",
      "sharedGalleryImageId": null,
      "sku": "22_04-lts-gen2",
      "version": "latest"
    },
    "osDisk": {
      "caching": "ReadWrite",
      "createOption": "FromImage",
      "deleteOption": "Detach",
      "diffDiskSettings": null,
      "diskSizeGb": null,
      "encryptionSettings": null,
      "image": null,
      "managedDisk": {
        "diskEncryptionSet": null,
        "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-8c443cef38de4173/providers/Microsoft.Compute/disks/xfusion-vm_OsDisk_1_6012820ba6dd4414bec63e71efcbbfb8",
        "resourceGroup": "kml_rg_main-8c443cef38de4173",
        "securityProfile": null,
        "storageAccountType": null
      },
      "name": "xfusion-vm_OsDisk_1_6012820ba6dd4414bec63e71efcbbfb8",
      "osType": "Linux",
      "vhd": null,
      "writeAcceleratorEnabled": null
    }
  },
  "tags": {},
  "timeCreated": "2026-05-16T20:10:03.969806+00:00",
  "type": "Microsoft.Compute/virtualMachines",
  "userData": null,
  "virtualMachineScaleSet": null,
  "vmId": "07fe64b1-f30c-4489-8846-2f8726ec6b80",
  "zones": null
}

~ ➜  az vm start -g $RG -n xfusion-vm

~ ➜  az vm get-instance-view -g $RG  -n xfusion-vm \
  --query "instanceView.statuses"
[
  {
    "code": "ProvisioningState/succeeded",
    "displayStatus": "Provisioning succeeded",
    "level": "Info",
    "message": null,
    "time": "2026-05-16T20:26:18.089110+00:00"
  }
]

~ ➜  az vm get-instance-view -g $RG  -n xfusion-vm   --query "instanceView.statuses"
[
  {
    "code": "ProvisioningState/succeeded",
    "displayStatus": "Provisioning succeeded",
    "level": "Info",
    "message": null,
    "time": "2026-05-16T20:26:18.089110+00:00"
  },
  {
    "code": "PowerState/running",
    "displayStatus": "VM running",
    "level": "Info",
    "message": null,
    "time": null
  }
]

~ ➜  
```
## Day 12: Add and Manage Tags for Azure Virtual Machines

```
 ➜  az vm list --query "[?name=='devops-vm'].[name,resourceGroup]" -o table
Column1    Column2
---------  ----------------------------
devops-vm  KML_RG_MAIN-90786F4F36744567

~ ➜  az group list -o table
Name                          Location    Status
----------------------------  ----------  ---------
kml_rg_main-90786f4f36744567  eastus      Succeeded

~ ➜  az resource tag \
  --tags Environment=dev \
  --resource-group kml_rg_main-90786f4f36744567 \
  --name devops-vm \
  --resource-type "Microsoft.Compute/virtualMachines"
{
  "etag": "\"2\"",
  "extendedLocation": null,
  "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-90786f4f36744567/providers/Microsoft.Compute/virtualMachines/devops-vm",
  "identity": null,
  "kind": null,
  "location": "eastus",
  "managedBy": null,
  "name": "devops-vm",
  "plan": null,
  "properties": {
    "hardwareProfile": {
      "vmSize": "Standard_B1s"
    },
    "networkProfile": {
      "networkInterfaces": [
        {
          "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-90786f4f36744567/providers/Microsoft.Network/networkInterfaces/devops-vmVMNic",
          "resourceGroup": "kml_rg_main-90786f4f36744567"
        }
      ]
    },
    "osProfile": {
      "adminUsername": "azureuser",
      "allowExtensionOperations": true,
      "computerName": "devops-vm",
      "linuxConfiguration": {
        "disablePasswordAuthentication": true,
        "patchSettings": {
          "assessmentMode": "ImageDefault",
          "patchMode": "ImageDefault"
        },
        "provisionVMAgent": true,
        "ssh": {
          "publicKeys": [
            {
              "keyData": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDXwSk5itb2/f90B8WnTEs+FR8PZ8VcCQYORx1TczxkaF3VNnhRJpb6uonM+qHGM4YNGeKfnGcQpvyquLJzw8YPMEl2SgH5PzI9e7LhkFCCr7/gh46JHkC5M6KvP1I8CFFt8iK7lOo/DcrM0kF3+8hMKCy9VfT2mGwQbkQ7KXb4ZNd7//bEPaBexDor12ixDARN9+MiQQK65Ttm2dFM9BEdmINBfjLrdqen0MLegk3+2/7EuovLsmfqkSCIciTXYwrlFQVMBeeZr/9zEqmtaZUPvBlyVRorlUj7Y/b/epJCgq9SOtB1ys+A03RzXQvf3GUpiWA4rve+zRVeaNjIVLUh root@azure-client\n",
              "path": "/home/azureuser/.ssh/authorized_keys"
            }
          ]
        }
      },
      "requireGuestProvisionSignal": true,
      "secrets": []
    },
    "provisioningState": "Succeeded",
    "securityProfile": {
      "securityType": "TrustedLaunch",
      "uefiSettings": {
        "secureBootEnabled": true,
        "vTpmEnabled": true
      }
    },
    "storageProfile": {
      "dataDisks": [],
      "diskControllerType": "SCSI",
      "imageReference": {
        "exactVersion": "22.04.202605030",
        "offer": "0001-com-ubuntu-server-jammy",
        "publisher": "Canonical",
        "sku": "22_04-lts-gen2",
        "version": "latest"
      },
      "osDisk": {
        "caching": "ReadWrite",
        "createOption": "FromImage",
        "deleteOption": "Detach",
        "diskSizeGB": 30,
        "managedDisk": {
          "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-90786f4f36744567/providers/Microsoft.Compute/disks/devops-vm_OsDisk_1_ec0d4bdbaef54a1ead6cb295881a4ad4",
          "resourceGroup": "kml_rg_main-90786f4f36744567",
          "storageAccountType": "Standard_LRS"
        },
        "name": "devops-vm_OsDisk_1_ec0d4bdbaef54a1ead6cb295881a4ad4",
        "osType": "Linux"
      }
    },
    "timeCreated": "2026-05-17T00:26:00.672783+00:00",
    "vmId": "f01beb08-95b1-49e8-a53c-5f21df6d6ac4"
  },
  "resourceGroup": "kml_rg_main-90786f4f36744567",
  "sku": null,
  "tags": {
    "Environment": "dev"
  },
  "type": "Microsoft.Compute/virtualMachines"
}

 

~ ✖ az vm show   --name devops-vm   --resource-group kml_rg_main-90786f4f36744567   --query tags
{
  "Environment": "dev"
}

~ ➜  

```

## Day 13: SSH into an Azure Virtual Machine
 

## 🔐 1. SSH access is controlled in multiple layers

You assumed “correct key = access”, but SSH actually evaluates several layers:

- `sshd_config` (server policy)
- `authorized_keys` (user key permissions)
- key restrictions (like forced commands)
- cloud/provider hardening (Azure default images)

👉 Lesson: **Always debug SSH as a system, not a single setting.**

---

## 🚫 2. `authorized_keys` can silently block login

This line was the real blocker:

```
command="echo ... exit 142"
```

That means:

- the key is accepted
- but login is forcibly replaced with a command that exits

👉 Lesson: **A valid key does NOT guarantee a usable shell.**

---

## ☁️ 3. Cloud images often include security overrides

Microsoft Azure Ubuntu images often ship with:

- root login discouraged or blocked
- forced “login as azureuser” behavior
- pre-hardened SSH configs

👉 Lesson: **Always check cloud image defaults before troubleshooting deeply.**

---

## 🔍 4. Always inspect `authorized_keys` fully, not just presence

You did this right eventually:

```
cat /root/.ssh/authorized_keys
```

That revealed the hidden restriction.

👉 Lesson: **SSH issues are often inside the key file, not outside it.**

---

## ⚙️ 5. `sshd_config` is only half the story

Even after:

```
PermitRootLogin prohibit-password
```

was visible, the real blocker was elsewhere.

👉 Lesson: **Config changes alone don’t guarantee behavior if key-level restrictions exist.**

---

## 🧠 6. Debugging mindset takeaway

A good SSH troubleshooting flow is:

1. Can I reach the host? (network/DNS)
2. Is the user allowed in sshd config?
3. Is the key present?
4. Is the key restricted?
5. Is cloud/security policy overriding it?

---

## 🚀 One-line summary

> SSH failures are rarely about missing keys — they are usually about *hidden restrictions in configuration, not connectivity.*

---

```
  ➜  az group list --output table
Name                          Location    Status
----------------------------  ----------  ---------
kml_rg_main-2713063366184204  eastus      Succeeded

~ ➜  ssh azureuser@datacenter-vm
ssh: Could not resolve hostname datacenter-vm: Name or service not known

~ ✖ az vm show --name datacenter-vm --resource-group  kml_rg_main-2713063366184204 -o json
{
  "additionalCapabilities": null,
  "applicationProfile": null,
  "availabilitySet": null,
  "billingProfile": null,
  "capacityReservation": null,
  "diagnosticsProfile": null,
  "etag": "\"1\"",
  "evictionPolicy": null,
  "extendedLocation": null,
  "extensionsTimeBudget": null,
  "hardwareProfile": {
    "vmSize": "Standard_B1s",
    "vmSizeProperties": null
  },
  "host": null,
  "hostGroup": null,
  "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-2713063366184204/providers/Microsoft.Compute/virtualMachines/datacenter-vm",
  "identity": null,
  "instanceView": null,
  "licenseType": null,
  "location": "eastus",
  "managedBy": null,
  "name": "datacenter-vm",
  "networkProfile": {
    "networkApiVersion": null,
    "networkInterfaceConfigurations": null,
    "networkInterfaces": [
      {
        "deleteOption": null,
        "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-2713063366184204/providers/Microsoft.Network/networkInterfaces/datacenter-vmVMNic",
        "primary": null,
        "resourceGroup": "kml_rg_main-2713063366184204"
      }
    ]
  },
  "osProfile": {
    "adminPassword": null,
    "adminUsername": "azureuser",
    "allowExtensionOperations": true,
    "computerName": "datacenter-vm",
    "customData": null,
    "linuxConfiguration": {
      "disablePasswordAuthentication": true,
      "enableVmAgentPlatformUpdates": null,
      "patchSettings": {
        "assessmentMode": "ImageDefault",
        "automaticByPlatformSettings": null,
        "patchMode": "ImageDefault"
      },
      "provisionVmAgent": true,
      "ssh": {
        "publicKeys": [
          {
            "keyData": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCo7kXaOV25GZ0SzGtJGLCWL8hkzzqnQgQg/+wuLFSR8sFmKLJHnutim0Z8Uab1haTJniODBUhIXSoEYZVb/ax1Xqj1vE2vEES0nIWhX8l1eZjJ70F5W3GCk1ETEZ5KU6DZLZM4ghI7aS9UBeyvQkRb7M3CwtnkHlwnJ76Wj4cYDjtELjiupbg22IKr+HariL7r0OV5+zbyPIIL5NVau5iIxiwruV3K0jrllhK7LcBrQXKb/AFRDVjhRL3hIOfxE9SLwsdNZ9VcrBEDldWV/rofSNdAc5wvSSMLi9oGhiqnddt50pS7QDBdSl9DpQF38jcYvLbZQKWrhPcCDORgHb0Z root@azure-client\n",
            "path": "/home/azureuser/.ssh/authorized_keys"
          }
        ]
      }
    },
    "requireGuestProvisionSignal": true,
    "secrets": [],
    "windowsConfiguration": null
  },
  "plan": null,
  "platformFaultDomain": null,
  "priority": null,
  "provisioningState": "Succeeded",
  "proximityPlacementGroup": null,
  "resourceGroup": "kml_rg_main-2713063366184204",
  "resources": null,
  "scheduledEventsPolicy": null,
  "scheduledEventsProfile": null,
  "securityProfile": {
    "encryptionAtHost": null,
    "encryptionIdentity": null,
    "proxyAgentSettings": null,
    "securityType": "TrustedLaunch",
    "uefiSettings": {
      "secureBootEnabled": true,
      "vTpmEnabled": true
    }
  },
  "storageProfile": {
    "dataDisks": [],
    "diskControllerType": "SCSI",
    "imageReference": {
      "communityGalleryImageId": null,
      "exactVersion": "22.04.202605030",
      "id": null,
      "offer": "0001-com-ubuntu-server-jammy",
      "publisher": "Canonical",
      "sharedGalleryImageId": null,
      "sku": "22_04-lts-gen2",
      "version": "latest"
    },
    "osDisk": {
      "caching": "ReadWrite",
      "createOption": "FromImage",
      "deleteOption": "Detach",
      "diffDiskSettings": null,
      "diskSizeGb": 30,
      "encryptionSettings": null,
      "image": null,
      "managedDisk": {
        "diskEncryptionSet": null,
        "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-2713063366184204/providers/Microsoft.Compute/disks/datacenter-vm_disk1_5946fd5a94684a92acce04aa3da5ede4",
        "resourceGroup": "kml_rg_main-2713063366184204",
        "securityProfile": null,
        "storageAccountType": "Standard_LRS"
      },
      "name": "datacenter-vm_disk1_5946fd5a94684a92acce04aa3da5ede4",
      "osType": "Linux",
      "vhd": null,
      "writeAcceleratorEnabled": null
    }
  },
  "tags": {},
  "timeCreated": "2026-05-17T17:01:14.195008+00:00",
  "type": "Microsoft.Compute/virtualMachines",
  "userData": null,
  "virtualMachineScaleSet": null,
  "vmId": "093aedf0-ecc8-41a7-a78c-357354dc564c",
  "zones": null
}

~ ➜  ssh azureuser@datacenter-vm
ssh: Could not resolve hostname datacenter-vm: Name or service not known

~ ✖ az vm list -o table
Name           ResourceGroup                 Location    Zones
-------------  ----------------------------  ----------  -------
datacenter-vm  KML_RG_MAIN-2713063366184204  eastus

~ ➜  ssh azureuser@datacenter-vm
ssh: Could not resolve hostname datacenter-vm: Name or service not known

~ ✖ az vm list-ip-addresses -g KML_RG_MAIN-2713063366184204 -n datacenter-vm -o table
VirtualMachine    PublicIPAddresses    PrivateIPAddresses
----------------  -------------------  --------------------
datacenter-vm     23.101.135.155       10.0.0.4

~ ➜  ssh azureuser@23.101.135.155

 ....

~ ✖ cat /root/.ssh/id_rsa.pub | ssh azureuser@23.101.135.155 "
sudo mkdir -p /root/.ssh &&
sudo chmod 700 /root/.ssh &&
sudo tee -a /root/.ssh/authorized_keys > /dev/null &&
sudo chmod 600 /root/.ssh/authorized_keys
"

~ ➜  ssh root@23.101.135.155
Please login as the user "azureuser" rather than the user "root".

^Z^CConnection to 23.101.135.155 closed.

~ ✖ ssh azureuser@23.101.135.155
Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 6.8.0-1052-azure x86_64)
 ..

Last login: Sun May 17 17:18:38 2026 from 65.108.255.62
azureuser@datacenter-vm:~$ cat /root/.ssh/authorized_keys
cat: /root/.ssh/authorized_keys: Permission denied
azureuser@datacenter-vm:~$ sudo cat /root/.ssh/authorized_keys
no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command="echo 'Please login as the user \"azureuser\" rather than the user \"root\".';echo;sleep 10;exit 142" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCo7kXaOV25GZ0SzGtJGLCWL8hkzzqnQgQg/+wuLFSR8sFmKLJHnutim0Z8Uab1haTJniODBUhIXSoEYZVb/ax1Xqj1vE2vEES0nIWhX8l1eZjJ70F5W3GCk1ETEZ5KU6DZLZM4ghI7aS9UBeyvQkRb7M3CwtnkHlwnJ76Wj4cYDjtELjiupbg22IKr+HariL7r0OV5+zbyPIIL5NVau5iIxiwruV3K0jrllhK7LcBrQXKb/AFRDVjhRL3hIOfxE9SLwsdNZ9VcrBEDldWV/rofSNdAc5wvSSMLi9oGhiqnddt50pS7QDBdSl9DpQF38jcYvLbZQKWrhPcCDORgHb0Z root@azure-client
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCo7kXaOV25GZ0SzGtJGLCWL8hkzzqnQgQg/+wuLFSR8sFmKLJHnutim0Z8Uab1haTJniODBUhIXSoEYZVb/ax1Xqj1vE2vEES0nIWhX8l1eZjJ70F5W3GCk1ETEZ5KU6DZLZM4ghI7aS9UBeyvQkRb7M3CwtnkHlwnJ76Wj4cYDjtELjiupbg22IKr+HariL7r0OV5+zbyPIIL5NVau5iIxiwruV3K0jrllhK7LcBrQXKb/AFRDVjhRL3hIOfxE9SLwsdNZ9VcrBEDldWV/rofSNdAc5wvSSMLi9oGhiqnddt50pS7QDBdSl9DpQF38jcYvLbZQKWrhPcCDORgHb0Z root@azure-client
azureuser@datacenter-vm:~$  sudo cat /root/.ssh/authorized_keys
no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command="echo 'Please login as the user \"azureuser\" rather than the user \"root\".';echo;sleep 10;exit 142" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCo7kXaOV25GZ0SzGtJGLCWL8hkzzqnQgQg/+wuLFSR8sFmKLJHnutim0Z8Uab1haTJniODBUhIXSoEYZVb/ax1Xqj1vE2vEES0nIWhX8l1eZjJ70F5W3GCk1ETEZ5KU6DZLZM4ghI7aS9UBeyvQkRb7M3CwtnkHlwnJ76Wj4cYDjtELjiupbg22IKr+HariL7r0OV5+zbyPIIL5NVau5iIxiwruV3K0jrllhK7LcBrQXKb/AFRDVjhRL3hIOfxE9SLwsdNZ9VcrBEDldWV/rofSNdAc5wvSSMLi9oGhiqnddt50pS7QDBdSl9DpQF38jcYvLbZQKWrhPcCDORgHb0Z root@azure-client
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCo7kXaOV25GZ0SzGtJGLCWL8hkzzqnQgQg/+wuLFSR8sFmKLJHnutim0Z8Uab1haTJniODBUhIXSoEYZVb/ax1Xqj1vE2vEES0nIWhX8l1eZjJ70F5W3GCk1ETEZ5KU6DZLZM4ghI7aS9UBeyvQkRb7M3CwtnkHlwnJ76Wj4cYDjtELjiupbg22IKr+HariL7r0OV5+zbyPIIL5NVau5iIxiwruV3K0jrllhK7LcBrQXKb/AFRDVjhRL3hIOfxE9SLwsdNZ9VcrBEDldWV/rofSNdAc5wvSSMLi9oGhiqnddt50pS7QDBdSl9DpQF38jcYvLbZQKWrhPcCDORgHb0Z root@azure-client
azureuser@datacenter-vm:~$ sudo grep PermitRootLogin /etc/ssh/sshd_config
#PermitRootLogin prohibit-password
# the setting of "PermitRootLogin without-password".
azureuser@datacenter-vm:~$ sudo vi /etc/ssh/sshd_config
azureuser@datacenter-vm:~$ uname -a
Linux datacenter-vm 6.8.0-1052-azure #58~22.04.1-Ubuntu SMP Thu Mar 26 05:02:21 UTC 2026 x86_64 x86_64 x86_64 GNU/Linux
azureuser@datacenter-vm:~$ sudo systemctl restart sshd
azureuser@datacenter-vm:~$ exit
logout
Connection to 23.101.135.155 closed.

~ ➜  ssh root@23.101.135.155
Please login as the user "azureuser" rather than the user "root".

Connection to 23.101.135.155 closed.

~ ✖ ssh azureuser@23.101.135.155
Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 6.8.0-1052-azure x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sun May 17 17:24:51 UTC 2026

  System load:  0.01              Processes:             109
  Usage of /:   5.8% of 28.89GB   Users logged in:       0
  Memory usage: 30%               IPv4 address for eth0: 10.0.0.4
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update
New release '24.04.4 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


Last login: Sun May 17 17:21:00 2026 from 65.108.255.62
azureuser@datacenter-vm:~$ sudo vi /etc/ssh/sshd_config
azureuser@datacenter-vm:~$ cat /root/.ssh/authorized_keys
cat: /root/.ssh/authorized_keys: Permission denied
azureuser@datacenter-vm:~$ sudo cat /root/.ssh/authorized_keys
no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command="echo 'Please login as the user \"azureuser\" rather than the user \"root\".';echo;sleep 10;exit 142" ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCo7kXaOV25GZ0SzGtJGLCWL8hkzzqnQgQg/+wuLFSR8sFmKLJHnutim0Z8Uab1haTJniODBUhIXSoEYZVb/ax1Xqj1vE2vEES0nIWhX8l1eZjJ70F5W3GCk1ETEZ5KU6DZLZM4ghI7aS9UBeyvQkRb7M3CwtnkHlwnJ76Wj4cYDjtELjiupbg22IKr+HariL7r0OV5+zbyPIIL5NVau5iIxiwruV3K0jrllhK7LcBrQXKb/AFRDVjhRL3hIOfxE9SLwsdNZ9VcrBEDldWV/rofSNdAc5wvSSMLi9oGhiqnddt50pS7QDBdSl9DpQF38jcYvLbZQKWrhPcCDORgHb0Z root@azure-client
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCo7kXaOV25GZ0SzGtJGLCWL8hkzzqnQgQg/+wuLFSR8sFmKLJHnutim0Z8Uab1haTJniODBUhIXSoEYZVb/ax1Xqj1vE2vEES0nIWhX8l1eZjJ70F5W3GCk1ETEZ5KU6DZLZM4ghI7aS9UBeyvQkRb7M3CwtnkHlwnJ76Wj4cYDjtELjiupbg22IKr+HariL7r0OV5+zbyPIIL5NVau5iIxiwruV3K0jrllhK7LcBrQXKb/AFRDVjhRL3hIOfxE9SLwsdNZ9VcrBEDldWV/rofSNdAc5wvSSMLi9oGhiqnddt50pS7QDBdSl9DpQF38jcYvLbZQKWrhPcCDORgHb0Z root@azure-client
azureuser@datacenter-vm:~$ sudo cat /etc/ssh/sshd_config

# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# This sshd was compiled with PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options override the
# default value.

Include /etc/ssh/sshd_config.d/*.conf

#Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

#HostKey /etc/ssh/ssh_host_rsa_key
#HostKey /etc/ssh/ssh_host_ecdsa_key
#HostKey /etc/ssh/ssh_host_ed25519_key

# Ciphers and keying
#RekeyLimit default none

# Logging
#SyslogFacility AUTH
#LogLevel INFO

# Authentication:

#LoginGraceTime 2m
PermitRootLogin prohibit-password
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10

PubkeyAuthentication yes

# Expect .ssh/authorized_keys2 to be disregarded by default in future.
#AuthorizedKeysFile     .ssh/authorized_keys .ssh/authorized_keys2

#AuthorizedPrincipalsFile none

#AuthorizedKeysCommand none
#AuthorizedKeysCommandUser nobody

# For this to work you will also need host keys in /etc/ssh/ssh_known_hosts
#HostbasedAuthentication no
# Change to yes if you don't trust ~/.ssh/known_hosts for
# HostbasedAuthentication
#IgnoreUserKnownHosts no
# Don't read the user's ~/.rhosts and ~/.shosts files
#IgnoreRhosts yes

# To disable tunneled clear text passwords, change to no here!
#PasswordAuthentication yes
#PermitEmptyPasswords no

# Change to yes to enable challenge-response passwords (beware issues with
# some PAM modules and threads)
KbdInteractiveAuthentication no

# Kerberos options
#KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosGetAFSToken no

# GSSAPI options
#GSSAPIAuthentication no
#GSSAPICleanupCredentials yes
#GSSAPIStrictAcceptorCheck yes
#GSSAPIKeyExchange no

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the KbdInteractiveAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via KbdInteractiveAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and KbdInteractiveAuthentication to 'no'.
UsePAM yes

#AllowAgentForwarding yes
#AllowTcpForwarding yes
#GatewayPorts no
X11Forwarding yes
#X11DisplayOffset 10
#X11UseLocalhost yes
#PermitTTY yes
PrintMotd no
#PrintLastLog yes
#TCPKeepAlive yes
#PermitUserEnvironment no
#Compression delayed
#ClientAliveInterval 0
#ClientAliveCountMax 3
#UseDNS no
#PidFile /run/sshd.pid
#MaxStartups 10:30:100
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none

# no default banner path
#Banner none

# Allow client to pass locale environment variables
AcceptEnv LANG LC_*

# override default of no subsystems
Subsystem       sftp    /usr/lib/openssh/sftp-server

# Example of overriding settings on a per-user basis
#Match User anoncvs
#       X11Forwarding no
#       AllowTcpForwarding no
#       PermitTTY no
#       ForceCommand cvs server
azureuser@datacenter-vm:~$ sudo vi /root/.ssh/authorized_keys
azureuser@datacenter-vm:~$ exit
logout
Connection to 23.101.135.155 closed.

~ ➜  ssh root@23.101.135.155
Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 6.8.0-1052-azure x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sun May 17 17:28:39 UTC 2026

  System load:  0.0               Processes:             109
  Usage of /:   5.8% of 28.89GB   Users logged in:       0
  Memory usage: 29%               IPv4 address for eth0: 10.0.0.4
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update
New release '24.04.4 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


Last login: Sun May 17 17:24:52 2026 from 65.108.255.62
root@datacenter-vm:~# exit
logout
Connection to 23.101.135.155 closed.

~ ➜  

~ ➜  

```

##

Create a managed disk with the following requirements: Name of the disk should be devops-disk. 
Disk type must be Standard_LRS. Disk size must be 2 GiB.

 
A **managed disk** is a cloud provider–managed block storage volume that behaves like a virtual hard drive for virtual machines. You don’t manage the underlying storage hardware, replication, or durability—only the disk itself (size, type, and attachment to compute).

---

# 🧠 What is an Azure Managed Disk?

In Microsoft Azure, a **managed disk** is:

- A **persistent block storage volume**
- Used primarily with **Azure Virtual Machines**
- Automatically handled for:
	- replication (LRS/ZRS/GRS depending on configuration)
		- availability
		- failure recovery
		- storage lifecycle

You simply define:

- Size (e.g., 2 GiB, 128 GiB)
- Performance tier (Standard HDD, Standard SSD, Premium SSD)
- Redundancy (e.g., Standard\_LRS)

Azure then manages the rest.

---

# ⚙️ Core characteristics of Azure Managed Disks

- Attached to VMs like a physical disk
- Independent of VM lifecycle (persists after VM deletion unless explicitly deleted)
- Automatically encrypted at rest
- Snapshot and backup support built-in
- Can be detached/reattached between VMs

---

# ☁️ Comparison: Azure vs AWS vs GCP

## 🟦 Azure Managed Disk vs AWS EBS

In Amazon Web Services, the equivalent service is **Elastic Block Store (EBS)**.

| Feature | Azure Managed Disk | AWS EBS |
| --- | --- | --- |
| Service type | Managed disk | Elastic Block Store |
| Attachment | VM-based | EC2-based |
| Persistence | Independent of VM | Independent of EC2 |
| Snapshot | Integrated snapshots | EBS snapshots to S3 |
| Encryption | Default at rest | Optional but commonly enabled |
| Performance tiers | Standard HDD/SSD, Premium SSD | gp3, gp2, io1, io2 |
| Multi-attach | Limited scenarios | Supported for some volume types |

👉 Key similarity: Both are **block storage volumes for VMs**.

---

## 🟩 Azure Managed Disk vs GCP Persistent Disk

In Google Cloud Platform, the equivalent is **Persistent Disk (PD)**.

| Feature | Azure Managed Disk | GCP Persistent Disk |
| --- | --- | --- |
| Service type | Managed disk | Persistent Disk |
| Types | HDD / SSD / Premium SSD | Standard / Balanced / SSD |
| Attachment | VM disk | Compute Engine disk |
| Resize | Supported (online/offline) | Supported (online) |
| Snapshots | Native snapshots | Native snapshots |
| Replication | LRS/ZRS/GRS options | Regional PD (multi-zone) |

👉 Key similarity: Both are **network-attached block storage with persistence beyond VM lifecycle**.

---

# 🔥 Key conceptual differences across all three

## 1\. Level of abstraction

- Azure Managed Disk: “fully managed disk resource”
- AWS EBS: volume-based abstraction tightly tied to EC2
- GCP PD: disk abstraction with strong regional options

---

## 2\. Resiliency model

- Azure: zone/region redundancy via disk SKU
- AWS: AZ-based volumes, snapshots in S3
- GCP: regional persistent disks (multi-zone replication built-in)

---

## 3\. Performance tuning approach

- Azure: choose disk SKU (Standard SSD, Premium SSD v2, etc.)
- AWS: choose volume type (gp3, io2, etc.)
- GCP: choose performance tier (balanced, SSD, extreme PD)

---

# 🧩 Mental model (important)

Think of all three like this:

- **Azure Managed Disk = “VM-attached smart disk resource”**
- **AWS EBS = “network-attached block volume for EC2”**
- **GCP Persistent Disk = “region-aware virtual disk for Compute Engine”**

---

# 🚀 DevOps takeaway

Across all clouds:

- Compute (VM/EC2/Compute Engine) is **stateless**
- Storage (managed disk/EBS/PD) is **stateful**
- You always design systems so:
	- compute can die
		- storage survives

```
~ ➜  az group list --output table
Name                          Location    Status
----------------------------  ----------  ---------
kml_rg_main-5247b653ca1f4607  eastus      Succeeded

~ ➜  az disk create \
  --name devops-disk \
  --resource-group kml_rg_main-5247b653ca1f4607 \
  --sku Standard_LRS \
  --size-gb 2
{
  "burstingEnabled": null,
  "burstingEnabledTime": null,
  "completionPercent": null,
  "creationData": {
    "createOption": "Empty",
    "elasticSanResourceId": null,
    "galleryImageReference": null,
    "imageReference": null,
    "logicalSectorSize": null,
    "performancePlus": null,
    "securityDataUri": null,
    "sourceResourceId": null,
    "sourceUniqueId": null,
    "sourceUri": null,
    "storageAccountId": null,
    "uploadSizeBytes": null
  },
  "dataAccessAuthMode": null,
  "diskAccessId": null,
  "diskIopsReadOnly": null,
  "diskIopsReadWrite": 500,
  "diskMBpsReadOnly": null,
  "diskMBpsReadWrite": 60,
  "diskSizeBytes": 2147483648,
  "diskSizeGb": 2,
  "diskState": "Unattached",
  "encryption": {
    "diskEncryptionSetId": null,
    "type": "EncryptionAtRestWithPlatformKey"
  },
  "encryptionSettingsCollection": null,
  "extendedLocation": null,
  "hyperVGeneration": null,
  "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-5247b653ca1f4607/providers/Microsoft.Compute/disks/devops-disk",
  "lastOwnershipUpdateTime": null,
  "location": "eastus",
  "managedBy": null,
  "managedByExtended": null,
  "maxShares": null,
  "name": "devops-disk",
  "networkAccessPolicy": "AllowAll",
  "optimizedForFrequentAttach": null,
  "osType": null,
  "propertyUpdatesInProgress": null,
  "provisioningState": "Succeeded",
  "publicNetworkAccess": "Enabled",
  "purchasePlan": null,
  "resourceGroup": "kml_rg_main-5247b653ca1f4607",
  "securityProfile": null,
  "shareInfo": null,
  "sku": {
    "name": "Standard_LRS",
    "tier": "Standard"
  },
  "supportedCapabilities": null,
  "supportsHibernation": null,
  "tags": {},
  "tier": null,
  "timeCreated": "2026-05-17T17:38:38.956332+00:00",
  "type": "Microsoft.Compute/disks",
  "uniqueId": "b5747813-d54b-43bb-9040-0fafaab4e063",
  "zones": null
}

~ ➜  az disk show \
  --name devops-disk \
  --resource-group kml_rg_main-5247b653ca1f4607
{
  "creationData": {
    "createOption": "Empty"
  },
  "diskIOPSReadWrite": 500,
  "diskMBpsReadWrite": 60,
  "diskSizeBytes": 2147483648,
  "diskSizeGB": 2,
  "diskState": "Unattached",
  "encryption": {
    "type": "EncryptionAtRestWithPlatformKey"
  },
  "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-5247b653ca1f4607/providers/Microsoft.Compute/disks/devops-disk",
  "location": "eastus",
  "name": "devops-disk",
  "networkAccessPolicy": "AllowAll",
  "provisioningState": "Succeeded",
  "publicNetworkAccess": "Enabled",
  "resourceGroup": "kml_rg_main-5247b653ca1f4607",
  "sku": {
    "name": "Standard_LRS",
    "tier": "Standard"
  },
  "tags": {},
  "timeCreated": "2026-05-17T17:38:38.9563329+00:00",
  "type": "Microsoft.Compute/disks",
  "uniqueId": "b5747813-d54b-43bb-9040-0fafaab4e063"
}

~ ➜  
```

###

 

 
create a network security group (NSG) with the following requirements: Name of the NSG should be datacenter-nsg. Add an inbound security rule named Allow-HTTP for HTTP service on port 80, with the source CIDR range of 0.0.0.0/0. Add another inbound security rule named Allow-SSH for SSH service on port 22, with the source CIDR range of 0.0.0.0/0. give using azur cli Use below given Azure Credentials: (You can run the showcreds command on the azure-client host to retrieve credentials)

---

**ChatGPT said**

## What is an Azure Network Security Group (NSG)?

A **Network Security Group (NSG)** in Azure is essentially a **virtual firewall for controlling network traffic** to and from Azure resources.

You attach an NSG to:

- a **subnet** (controls traffic for all resources in that subnet), or
- a **network interface (NIC)** of a VM (controls traffic for that specific VM)

---

## How NSG works (core concept)

An NSG contains **security rules** that define:

- **Direction**: Inbound or Outbound
- **Protocol**: TCP, UDP, Any
- **Port range**: e.g., 22, 80, 443
- **Source/Destination**: IP, CIDR, subnet, tag
- **Action**: Allow or Deny
- **Priority**: Lower number = higher priority (evaluated first)

### Example logic:

If a packet comes in:

1. Azure checks NSG rules top-down (by priority)
2. First match wins
3. If no rule matches → traffic is denied by default (inbound)

---

## Your example rules

You created:

- Allow HTTP (port 80) from anywhere
- Allow SSH (port 22) from anywhere

So effectively:

- Anyone on the internet can access web server (80)
- Anyone on the internet can SSH into VM (22) ⚠️ risky in real environments

---

## NSG vs AWS vs GCP (important comparison)

### 1\. Azure NSG vs AWS Security Groups vs GCP Firewall Rules

| Feature | Azure NSG | AWS Security Groups | GCP Firewall Rules |
| --- | --- | --- | --- |
| Scope | Subnet or NIC | Instance (ENI) | VPC-wide (tag-based) |
| Stateful | Yes | Yes | Yes |
| Default inbound | Deny all | Deny all | Deny all |
| Default outbound | Allow all | Allow all | Allow all |
| Rule evaluation | Priority-based | All rules evaluated together | Priority-based |
| Deny rules | Explicit support | No explicit deny | Yes (supports deny rules) |
| Attach to subnet | Yes | No | Yes (via network tags/service accounts indirectly) |

---

## Key Differences Explained

### 🔵 Azure NSG

- Can attach at **subnet OR NIC level**
- Supports **explicit deny rules**
- Uses **priority numbers**
- Very flexible but slightly more complex

---

### 🟠 AWS Security Groups

- Attach only to **ENI (instance-level NIC)**
- **Stateful**
- ❌ No explicit deny rules (only allow rules exist)
- If traffic not allowed → implicitly denied

👉 AWS model is simpler:

> “If allowed, it works. Otherwise, it’s blocked.”

---

### 🟢 GCP Firewall Rules

- Applied at **VPC level**
- Uses **tags or service accounts**
- Supports **priority + explicit deny rules**
- Very scalable for large environments

---

## Mental Model Comparison

### Azure NSG

> “Firewall rules attached to subnet or NIC with priority-based evaluation”

### AWS SG

> “Instance-level allow-list firewall (stateful, no deny rules)”

### GCP Firewall

> “Centralized VPC firewall using tags and priorities”

---

## Practical differences in real life

### 1\. Granularity

- Azure: subnet + VM level (very flexible)
- AWS: instance only
- GCP: network-wide with tagging abstraction

---

### 2\. Security posture

- Azure NSG: more control, but risk of misconfigured open rules (like `0.0.0.0/0`)
- AWS SG: safer by design (no deny, only allow)
- GCP: powerful but depends heavily on tagging discipline

---

### 3\. Example scenario (SSH access)

| Cloud | How you restrict SSH to your IP |
| --- | --- |
| Azure NSG | `source-address-prefixes = your IP /32` |
| AWS SG | Add inbound rule for your IP only |
| GCP Firewall | Use source ranges + tags |

---

## Important security insight

Your rule:

```
0.0.0.0/0 → port 22 (SSH)
```

Means:

> “The entire internet can attempt SSH login”

In real production setups:

- This is almost always replaced with:
	- Bastion host (Azure Bastion / AWS SSM / GCP IAP)
		- VPN access
		- IP-restricted access

---

## Summary

- **NSG = Azure’s virtual network firewall**
- Works at **subnet or NIC level**
- Uses **priority-based allow/deny rules**
- Closest equivalents:
	- AWS → Security Groups (simpler, no deny rules)
		- GCP → VPC Firewall Rules (more centralized + tag-based)

 

```

~ ➜  az group list --output table
Name                          Location    Status
----------------------------  ----------  ---------
kml_rg_main-387b956b5fb64279  eastus      Succeeded

~ ➜  az network nsg create \
  --name datacenter-nsg \
  --resource-group kml_rg_main-387b956b5fb64279 \
  --location eastus
{
  "NewNSG": {
    "defaultSecurityRules": [
      {
        "access": "Allow",
        "description": "Allow inbound traffic from all VMs in VNET",
        "destinationAddressPrefix": "VirtualNetwork",
        "destinationAddressPrefixes": [],
        "destinationPortRange": "*",
        "destinationPortRanges": [],
        "direction": "Inbound",
        "etag": "W/\"1f2d2628-d05d-4fc7-b953-6ffc62560d71\"",
        "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-387b956b5fb64279/providers/Microsoft.Network/networkSecurityGroups/datacenter-nsg/defaultSecurityRules/AllowVnetInBound",
        "name": "AllowVnetInBound",
        "priority": 65000,
        "protocol": "*",
        "provisioningState": "Succeeded",
        "resourceGroup": "kml_rg_main-387b956b5fb64279",
        "sourceAddressPrefix": "VirtualNetwork",
        "sourceAddressPrefixes": [],
        "sourcePortRange": "*",
        "sourcePortRanges": [],
        "type": "Microsoft.Network/networkSecurityGroups/defaultSecurityRules"
      },
      {
        "access": "Allow",
        "description": "Allow inbound traffic from azure load balancer",
        "destinationAddressPrefix": "*",
        "destinationAddressPrefixes": [],
        "destinationPortRange": "*",
        "destinationPortRanges": [],
        "direction": "Inbound",
        "etag": "W/\"1f2d2628-d05d-4fc7-b953-6ffc62560d71\"",
        "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-387b956b5fb64279/providers/Microsoft.Network/networkSecurityGroups/datacenter-nsg/defaultSecurityRules/AllowAzureLoadBalancerInBound",
        "name": "AllowAzureLoadBalancerInBound",
        "priority": 65001,
        "protocol": "*",
        "provisioningState": "Succeeded",
        "resourceGroup": "kml_rg_main-387b956b5fb64279",
        "sourceAddressPrefix": "AzureLoadBalancer",
        "sourceAddressPrefixes": [],
        "sourcePortRange": "*",
        "sourcePortRanges": [],
        "type": "Microsoft.Network/networkSecurityGroups/defaultSecurityRules"
      },
      {
        "access": "Deny",
        "description": "Deny all inbound traffic",
        "destinationAddressPrefix": "*",
        "destinationAddressPrefixes": [],
        "destinationPortRange": "*",
        "destinationPortRanges": [],
        "direction": "Inbound",
        "etag": "W/\"1f2d2628-d05d-4fc7-b953-6ffc62560d71\"",
        "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-387b956b5fb64279/providers/Microsoft.Network/networkSecurityGroups/datacenter-nsg/defaultSecurityRules/DenyAllInBound",
        "name": "DenyAllInBound",
        "priority": 65500,
        "protocol": "*",
        "provisioningState": "Succeeded",
        "resourceGroup": "kml_rg_main-387b956b5fb64279",
        "sourceAddressPrefix": "*",
        "sourceAddressPrefixes": [],
        "sourcePortRange": "*",
        "sourcePortRanges": [],
        "type": "Microsoft.Network/networkSecurityGroups/defaultSecurityRules"
      },
      {
        "access": "Allow",
        "description": "Allow outbound traffic from all VMs to all VMs in VNET",
        "destinationAddressPrefix": "VirtualNetwork",
        "destinationAddressPrefixes": [],
        "destinationPortRange": "*",
        "destinationPortRanges": [],
        "direction": "Outbound",
        "etag": "W/\"1f2d2628-d05d-4fc7-b953-6ffc62560d71\"",
        "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-387b956b5fb64279/providers/Microsoft.Network/networkSecurityGroups/datacenter-nsg/defaultSecurityRules/AllowVnetOutBound",
        "name": "AllowVnetOutBound",
        "priority": 65000,
        "protocol": "*",
        "provisioningState": "Succeeded",
        "resourceGroup": "kml_rg_main-387b956b5fb64279",
        "sourceAddressPrefix": "VirtualNetwork",
        "sourceAddressPrefixes": [],
        "sourcePortRange": "*",
        "sourcePortRanges": [],
        "type": "Microsoft.Network/networkSecurityGroups/defaultSecurityRules"
      },
      {
        "access": "Allow",
        "description": "Allow outbound traffic from all VMs to Internet",
        "destinationAddressPrefix": "Internet",
        "destinationAddressPrefixes": [],
        "destinationPortRange": "*",
        "destinationPortRanges": [],
        "direction": "Outbound",
        "etag": "W/\"1f2d2628-d05d-4fc7-b953-6ffc62560d71\"",
        "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-387b956b5fb64279/providers/Microsoft.Network/networkSecurityGroups/datacenter-nsg/defaultSecurityRules/AllowInternetOutBound",
        "name": "AllowInternetOutBound",
        "priority": 65001,
        "protocol": "*",
        "provisioningState": "Succeeded",
        "resourceGroup": "kml_rg_main-387b956b5fb64279",
        "sourceAddressPrefix": "*",
        "sourceAddressPrefixes": [],
        "sourcePortRange": "*",
        "sourcePortRanges": [],
        "type": "Microsoft.Network/networkSecurityGroups/defaultSecurityRules"
      },
      {
        "access": "Deny",
        "description": "Deny all outbound traffic",
        "destinationAddressPrefix": "*",
        "destinationAddressPrefixes": [],
        "destinationPortRange": "*",
        "destinationPortRanges": [],
        "direction": "Outbound",
        "etag": "W/\"1f2d2628-d05d-4fc7-b953-6ffc62560d71\"",
        "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-387b956b5fb64279/providers/Microsoft.Network/networkSecurityGroups/datacenter-nsg/defaultSecurityRules/DenyAllOutBound",
        "name": "DenyAllOutBound",
        "priority": 65500,
        "protocol": "*",
        "provisioningState": "Succeeded",
        "resourceGroup": "kml_rg_main-387b956b5fb64279",
        "sourceAddressPrefix": "*",
        "sourceAddressPrefixes": [],
        "sourcePortRange": "*",
        "sourcePortRanges": [],
        "type": "Microsoft.Network/networkSecurityGroups/defaultSecurityRules"
      }
    ],
    "etag": "W/\"1f2d2628-d05d-4fc7-b953-6ffc62560d71\"",
    "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-387b956b5fb64279/providers/Microsoft.Network/networkSecurityGroups/datacenter-nsg",
    "location": "eastus",
    "name": "datacenter-nsg",
    "provisioningState": "Succeeded",
    "resourceGroup": "kml_rg_main-387b956b5fb64279",
    "resourceGuid": "7ee17532-8f56-443d-9b72-01e1cfc45eb9",
    "securityRules": [],
    "type": "Microsoft.Network/networkSecurityGroups"
  }
}

~ ➜  az network nsg rule create \
  --resource-group kml_rg_main-387b956b5fb64279 \
  --nsg-name datacenter-nsg \
  --name Allow-HTTP \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes 0.0.0.0/0 \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 80
{
  "access": "Allow",
  "destinationAddressPrefix": "*",
  "destinationAddressPrefixes": [],
  "destinationPortRange": "80",
  "destinationPortRanges": [],
  "direction": "Inbound",
  "etag": "W/\"0e2aa7bd-3b7e-4218-abd2-a8cfd314bb3e\"",
  "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-387b956b5fb64279/providers/Microsoft.Network/networkSecurityGroups/datacenter-nsg/securityRules/Allow-HTTP",
  "name": "Allow-HTTP",
  "priority": 100,
  "protocol": "Tcp",
  "provisioningState": "Succeeded",
  "resourceGroup": "kml_rg_main-387b956b5fb64279",
  "sourceAddressPrefix": "0.0.0.0/0",
  "sourceAddressPrefixes": [],
  "sourcePortRange": "*",
  "sourcePortRanges": [],
  "type": "Microsoft.Network/networkSecurityGroups/securityRules"
}

~ ➜  az network nsg rule create \
  --resource-group kml_rg_main-387b956b5fb64279 \
  --nsg-name datacenter-nsg \
  --name Allow-SSH \
  --priority 110 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes 0.0.0.0/0 \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 22
{
  "access": "Allow",
  "destinationAddressPrefix": "*",
  "destinationAddressPrefixes": [],
  "destinationPortRange": "22",
  "destinationPortRanges": [],
  "direction": "Inbound",
  "etag": "W/\"a681b61a-af03-4ad8-8284-2ed73d4abf24\"",
  "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-387b956b5fb64279/providers/Microsoft.Network/networkSecurityGroups/datacenter-nsg/securityRules/Allow-SSH",
  "name": "Allow-SSH",
  "priority": 110,
  "protocol": "Tcp",
  "provisioningState": "Succeeded",
  "resourceGroup": "kml_rg_main-387b956b5fb64279",
  "sourceAddressPrefix": "0.0.0.0/0",
  "sourceAddressPrefixes": [],
  "sourcePortRange": "*",
  "sourcePortRanges": [],
  "type": "Microsoft.Network/networkSecurityGroups/securityRules"
}

~ ➜  az network nsg show \
  --name datacenter-nsg \
  --resource-group kml_rg_main-387b956b5fb64279 \
  --output table
Location    Name            ProvisioningState    ResourceGroup                 ResourceGuid
----------  --------------  -------------------  ----------------------------  ------------------------------------
eastus      datacenter-nsg  Succeeded            kml_rg_main-387b956b5fb64279  7ee17532-8f56-443d-9b72-01e1cfc45eb9

~ ➜  az network nsg rule list \
  --nsg-name datacenter-nsg \
  --resource-group kml_rg_main-387b956b5fb64279 \
  --output table
Name        ResourceGroup                 Priority    SourcePortRanges    SourceAddressPrefixes    SourceASG    Access    Protocol    Direction    DestinationPortRanges    DestinationAddressPrefixes    DestinationASG
----------  ----------------------------  ----------  ------------------  -----------------------  -----------  --------  ----------  -----------  -----------------------  ----------------------------  ----------------
Allow-HTTP  kml_rg_main-387b956b5fb64279  100         *                   0.0.0.0/0                None         Allow     Tcp         Inbound      80                       *                             None
Allow-SSH   kml_rg_main-387b956b5fb64279  110         *                   0.0.0.0/0                None         Allow     Tcp         Inbound      22                       *                             None

~ ➜  

```