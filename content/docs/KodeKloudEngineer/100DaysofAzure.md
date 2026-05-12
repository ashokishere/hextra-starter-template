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
~ ✖ RG=kml_rg_main-7ed48485675246eb

~ ➜  az vm create \
  --resource-group $RG \
  --name devops-vm \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username azureuser \
  --generate-ssh-keys \
  --storage-sku Standard_LRS \
  --os-disk-size-gb 30 \
  --location centralus \
  --public-ip-sku Standard \
  --nsg-rule SSH \
  --output json
SSH key files '/root/.ssh/id_rsa' and '/root/.ssh/id_rsa.pub' have been generated under ~/.ssh to allow SSH access to the VM. If using machines without permanent storage, back up your keys to a safe location.
{
  "fqdns": "",
  "id": "/subscriptions/f0c3bcdd-5ce2-4fa0-8cf3-41559747512b/resourceGroups/kml_rg_main-7ed48485675246eb/providers/Microsoft.Compute/virtualMachines/devops-vm",
  "location": "centralus",
  "macAddress": "70-A8-A5-27-C2-DC",
  "powerState": "VM running",
  "privateIpAddress": "10.0.0.4",
  "publicIpAddress": "172.173.125.73",
  "resourceGroup": "kml_rg_main-7ed48485675246eb",
  "zones": ""
}

~ ➜  az vm show \
  --resource-group $RG \
  --name devops-vm \
  --show-details \
  --query "{Name:name, PowerState:powerState, PublicIP:publicIps}" \
  -o table
Name       PowerState    PublicIP
---------  ------------  --------------
devops-vm  VM running    172.173.125.73

```


