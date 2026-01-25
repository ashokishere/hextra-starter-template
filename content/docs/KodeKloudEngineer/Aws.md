---
title: AWS Questions
type: docs
prev: docs/KodeKloudEngineer/Terraform
next: docs/KodeKloudEngineer/AWS
sidebar:
  open: true
---

## 1

``` 
showcreds

aws configure

aws ec2 create-key-pair \
  --key-name nautilus-kp \
  --key-type rsa \
  --region us-east-1 \
  --query 'KeyMaterial' \
  --output text > nautilus-kp.pem

chmod 400 nautilus-kp.pem

aws ec2 describe-key-pairs \
  --key-names nautilus-kp \
  --region us-east-1

```

## 2

```
aws ec2 describe-vpcs \
  --filters Name=isDefault,Values=true \
  --region us-east-1 \
  --query 'Vpcs[0].VpcId' \
  --output text

aws ec2 create-security-group \
  --group-name devops-sg \
  --description "Security group for Nautilus App Servers" \
  --vpc-id vpc-0b23b86a9efa4a4cb \
  --region us-east-1

Add HTTP (Port 80) Inbound Rule

aws ec2 authorize-security-group-ingress \
  --group-id sg-0549efd1460f35abb \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0 \
  --region us-east-1

Add SSH (Port 22) Inbound Rule

aws ec2 authorize-security-group-ingress \
  --group-id sg-0549efd1460f35abb \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --region us-east-1

Verify the Security Group

aws ec2 describe-security-groups \
  --group-ids sg-0549efd1460f35abb  \
  --region us-east-1
```

## 3 
```

aws ec2 describe-availability-zones \
  --region us-east-1 \
  --query 'AvailabilityZones[0].ZoneName' \
  --output text

aws ec2 create-volume \
  --availability-zone  us-east-1a \
  --size 2 \
  --volume-type gp3 \
  --tag-specifications 'ResourceType=volume,Tags=[{Key=Name,Value=xfusion-volume}]' \
  --region us-east-1

aws ec2 describe-volumes \
  --filters Name=tag:Name,Values=xfusion-volume \
  --region us-east-1

```

## 4

```

vpc-0b84fa5f953229d61


aws ec2 describe-availability-zones \
  --region us-east-1 \
  --query 'AvailabilityZones[0].ZoneName' \
  --output text

aws ec2 create-subnet \
  --vpc-id vpc-0b84fa5f953229d61 \
  --cidr-block 172.31.50.0/24 \
  --availability-zone us-east-1a \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=devops-subnet}]' \
  --region us-east-1

aws ec2 create-subnet \
  --vpc-id vpc-0b84fa5f953229d61 \
  --cidr-block 172.31.96.0/24 \
  --availability-zone us-east-1a \
  --tag-specifications 'ResourceType=subnet,Tags=[{Key=Name,Value=devops-subnet}]' \
  --region us-east-1


aws ec2 describe-subnets \
  --filters Name=vpc-id,Values=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --query 'Vpcs[0].VpcId' --output text) \
  --region us-east-1 \
  --query 'Subnets[].CidrBlock'

aws ec2 describe-subnets \
  --filters Name=tag:Name,Values=devops-subnet \
  --region us-east-1
```


  ## 5
```
  aws ec2 allocate-address \
  --domain vpc \
  --tag-specifications 'ResourceType=elastic-ip,Tags=[{Key=Name,Value=devops-eip}]' \
  --region us-east-1

aws ec2 describe-addresses \
  --filters Name=tag:Name,Values=devops-eip \
  --region us-east-1
```

### 6
```
aws ec2 create-key-pair \
  --key-name nautilus-kp \
  --key-type rsa \
  --region us-east-1 \
  --query 'KeyMaterial' \
  --output text > nautilus-kp.pem


aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" "Name=state,Values=available" \
  --region us-east-1 \
  --query 'Images | sort_by(@,&CreationDate) | [-1].ImageId' \
  --output text

aws ec2 describe-security-groups \
  --filters Name=group-name,Values=default \
  --region us-east-1 \
  --query 'SecurityGroups[0].GroupId' \
  --output text


aws ec2 run-instances \
  --image-id ami-026992d753d5622bc \
  --instance-type t2.micro \
  --key-name nautilus-kp \
  --security-group-ids sg-03e41e70871c07df9 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=nautilus-ec2}]' \
  --region us-east-1 \
  --count 1


aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=nautilus-ec2" \
  --region us-east-1 \
  --query 'Reservations[0].Instances[0].[InstanceId,State.Name,PublicIpAddress]' \
  --output table



aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=nautilus-ec2" \
  --region us-east-1 \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text


aws ec2 stop-instances \
  --instance-ids i-0d1a194c1ed888290 \
  --region us-east-1


aws ec2 stop-instances \
  --instance-ids i-0d1a194c1ed888290 \
  --region us-east-1


aws ec2 wait instance-stopped \
  --instance-ids i-0d1a194c1ed888290 \
  --region us-east-1

aws ec2 modify-instance-attribute \
  --instance-id i-0d1a194c1ed888290 \
  --instance-type "{\"Value\": \"t2.nano\"}" \
  --region us-east-1

aws ec2 start-instances \
  --instance-ids <INSTANCE_ID> \
  --region us-east-1


aws ec2 describe-instances \
  --instance-ids i-0d1a194c1ed888290 \
  --region us-east-1 \
  --query 'Reservations[0].Instances[0].[InstanceType,State.Name]' \
  --output table

``` 

## 37
```

aws ec2 create-key-pair \
  --key-name datacenter-kp \
  --key-type rsa \
  --region us-east-1 \
  --query 'KeyMaterial' \
  --output text > datacenter-kp.pem


chmod 400 datacenter-kp.pem

aws ec2 describe-security-groups \
  --filters Name=group-name,Values=default \
  --region us-east-1 \
  --query 'SecurityGroups[0].GroupId' \
  --output text


aws ec2 run-instances \
  --image-id ami-0cd59ecaf368e5ccf \
  --instance-type t2.micro \
  --key-name datacenter-kp \
  --security-group-ids sg-00464c8a93bfa813f \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=datacenter-ec2}]' \
  --region us-east-1 \
  --count 1


aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=datacenter-ec2" \
  --region us-east-1 \
  --query 'Reservations[0].Instances[0].[InstanceId,State.Name,PublicIpAddress]' \
  --output table
```
## 8


# Method 1: AWS Management Console (easiest)

Go to the AWS EC2 Console → https://console.aws.amazon.com/ec2/

In the top-right region selector, choose US East (N. Virginia) us-east-1.
In the left menu, click Instances.

Find and select the instance named xfusion-ec2 (you can search/filter by name tag or instance name).
Click Actions  Instance settings → Change stop protection.
Check the box Enable stop protection.
Click Save.

Done — the instance now has stop protection enabled.

# Method 2: AWS CLI (recommended for automation/scripting)

First, get the instance ID (since most commands require the ID, not the name tag):

```Bash
 aws ec2 describe-instances \
  --region us-east-1 \
  --filters "Name=tag:Name,Values=xfusion-ec2" \
  --query "Reservations[].Instances[].InstanceId" \
  --output text
```

This will output something like: <i-01230>

Then enable stop protection using that ID:

```Bash
aws ec2 modify-instance-attribute \
  --region us-east-1 \
  --instance-id i-0426155ab5c7bc489  \
  --disable-api-stop
```

aws ec2 modify-instance-attribute \
  --region us-east-1 \
  --instance-id i-0426155ab5c7bc489 \
  --disable-api-stop

--disable-api-stop = true (the confusing name means "disable the ability to stop via API", i.e. enable protection).

To disable protection later: --no-disable-api-stop or --disable-api-stop false

Verify it worked:

```Bash
aws ec2 describe-instance-attribute \
  --region us-east-1 \
  --instance-id i-0426155ab5c7bc489  \
  --attribute disableApiStop
```

You should see:

JSON{
    "DisableApiStop": {
        "Value": true
    },
    "InstanceId": "<i-01230>"
}

# Method 3: AWS SDK / Terraform / CloudFormation (if you're using IaC)

AWS SDK (boto3 example in Python):

```Python
import boto3

ec2 = boto3.client('ec2', region_name='us-east-1')

response = ec2.modify_instance_attribute(
    InstanceId='<i-01230>',
    DisableApiStop={'Value': True}
)
print("Stop protection enabled.")

```

Terraform (ec2 instance resource):

```hcl resource "aws_instance" "example" {
  # ... other settings ...
  disable_api_stop = true
}
```

## 9 

To enable termination protection (also called "Disable API Termination") for the EC2 instance named devops-ec2 in the us-east-1 region, follow these steps. 

Why we normally do??


This prevents accidental termination via the AWS Console, CLI, SDKs, or API (though it does not block termination from Auto Scaling Groups, spot interruptions, or scheduled actions).
Note:

Termination protection is controlled by the disableApiTermination attribute (set to true to enable protection).

This is separate from stop protection (disableApiStop), which you enabled earlier for xfusion-ec2.

You need IAM permissions like ec2:ModifyInstanceAttribute and ec2:DescribeInstances.

Step 1: Find the Instance ID

Since commands require the instance ID (not the name tag), run this AWS CLI command:

```Bash

aws ec2 describe-instances \
  --region us-east-1 \
  --filters "Name=tag:Name,Values=devops-ec2" \
  --query "Reservations[].Instances[?State.Name=='running' || State.Name=='stopped'].InstanceId" \
  --output text
  
```


This outputs the Instance ID (e.g., i-0123456789abcdef0).

If multiple instances match the name tag, narrow the filter or select the correct one manually from the console.

If no output appears, confirm the instance exists, is not terminated, and the tag is exactly "Name": "devops-ec2" (case-sensitive).

Step 2: Enable Termination Protection (AWS CLI - recommended)

Use the instance ID from above:

Bashaws ec2 modify-instance-attribute \
  --region us-east-1 \
  --instance-id i-0123456789abcdef0 \
  --disable-api-termination '{"Value": true}'

Or the shorter equivalent syntax:

Bashaws ec2 modify-instance-attribute \
  --region us-east-1 \
  --instance-id i-0123456789abcdef0 \
  --disable-api-termination

(To disable protection later, use --no-disable-api-termination or --disable-api-termination '{"Value": false}'.)

Step 3: Verify It Worked

Check the current setting:

```Bash
aws ec2 describe-instance-attribute \
  --region us-east-1 \
  --instance-id i-0123456789abcdef0 \
  --attribute disableApiTermination
```

Expected output:

JSON{
    "DisableApiTermination": {
        "Value": true
    },
    "InstanceId": "i-0123456789abcdef0"
}

# AWS Management Console (quick GUI method)

Open the EC2 Console: https://console.aws.amazon.com/ec2/
Set region to US East (N. Virginia) us-east-1.
Go to Instances in the left menu.
Search for or locate the instance named devops-ec2.
Select it → Actions → Instance settings → Change termination protection.
Check Enable (or the equivalent checkbox).
Choose Save.

That's it — termination protection is now active. Attempting to terminate the instance via console/CLI/API will show an error like:

" The instance 'i-0123456789abcdef0' is protected against termination."

 

## 11 Attach Elastic Network Interface to EC2 Instance

Method 1: AWS Management Console (GUI)

EC2 Console → Network Interfaces (left menu).
Find devops-eni (search by tag).
Select it → Actions → Attach.
Instance ID: search/select devops-ec2.
Device index: e.g., 1.
Attach.
Refresh and check attachment status → should go to "attached".

Once verified as attached, the task is complete.


Method 2

```
aws ec2 describe-instances \
  --region us-east-1 \
  --filters "Name=tag:Name,Values=devops-ec2" "Name=instance-state-name,Values=running" \
  --query "Reservations[].Instances[?State.Name=='running']|[0].InstanceId" \
  --output text
```
Expected output: i-0123456789abcdef0 (or similar).

 
```
aws ec2 start-instances --region us-east-1 --instance-ids <instance-id>
aws ec2 wait instance-running --region us-east-1 --instance-ids <instance-id>
```

Step 2: Get the Network Interface ID for devops-eni

```
aws ec2 describe-network-interfaces \
  --region us-east-1 \
  --filters "Name=tag:Name,Values=devops-eni" \
  --query "NetworkInterfaces[?Status!='available' || Status!='in-use'].NetworkInterfaceId" \
  --output text
```

Step 3: Attach the ENI

```
aws ec2 attach-network-interface \
  --region us-east-1 \
  --network-interface-id <ENI_ID> \
  --instance-id <INSTANCE_ID> \
  --device-index 1
```
Step 4: Wait and verify the attachment status is "attached"
Poll until attached (simple loop example - run manually or script it)

```
aws ec2 describe-network-interfaces \
  --region us-east-1 \
  --network-interface-ids <ENI_ID> \
  --query "NetworkInterfaces[0].Attachment.AttachmentStatus" \
  --output text
```


```
aws ec2 describe-network-interfaces \
  --region us-east-1 \
  --filters "Name=network-interface-id,Values=<ENI_ID>" \
  --query "NetworkInterfaces[0].{AttachmentStatus:Attachment.AttachmentStatus, InstanceId:Attachment.InstanceId, DeviceIndex:Attachment.DeviceIndex}" \
  --output table
```

## 12 Attach Volume to EC2 Instance

To attach the EBS volume named devops-volume (via its Name tag) to the EC2 instance named devops-ec2 in the us-east-1 region, specifying the device name /dev/sdb as requested, use the AWS CLI steps below.

Key notes:

The volume must be in the available state (not already attached elsewhere) and in the same Availability Zone as the instance.


Method 1 AWS Management Console (GUI)

EC2 Console → Volumes (left menu) → region us-east-1.
Find volume with Name tag devops-volume (or search by tag).
Select it → Actions → Attach volume.
Instance: search/select devops-ec2.
Device name: enter /dev/sdb (it auto-suggests, but override if needed).
Attach volume.
Refresh the volume list — status should change to in-use, and attachment details show /dev/sdb and the instance ID.

Method 2

Step 1: Confirm Instance is Ready (Running or Stopped)
```Bash
aws ec2 describe-instances \
  --region us-east-1 \
  --filters "Name=tag:Name,Values=devops-ec2" \
  --query "Reservations[].Instances[].{InstanceId:InstanceId, State:State.Name, AZ:Placement.AvailabilityZone}" \
  --output table
```

Look for State = running or stopped.
Note the AZ (e.g., us-east-1a) — the volume must match this AZ.
If not running/stopped or wrong AZ → fix first (start instance if needed, or recreate volume in correct AZ).

Copy the <INSTANCE_ID> (e.g., i-0123456789abcdef0).

Step 2: Get the Volume ID for devops-volume and confirm it's available + same AZ

``` Bash
aws ec2 describe-volumes \
  --region us-east-1 \
  --filters "Name=tag:Name,Values=devops-volume" \
  --query "Volumes[0].{VolumeId:VolumeId, State:State, Size:Size, AZ:AvailabilityZone, Attachment:Attachments[0].InstanceId || 'none'}" \
  --output table
```

Expected good output:

State: available

AZ: matches the instance's AZ from Step 1

Attachment: none

Copy the <VOLUME_ID> (e.g., vol-0123456789abcdef0).

If already attached (Attachment shows an instance ID) → detach first:

```Bash
aws ec2 
detach-volume --region us-east-1 --volume-id <VOLUME_ID>
aws ec2 wait volume-available --region us-east-1 --volume-ids <VOLUME_ID>
```


Step 3: Attach the Volume with Device Name /dev/sdb

``` aws ec2 attach-volume \
  --region us-east-1 \
  --volume-id <VOLUME_ID> \
  --instance-id <INSTANCE_ID> \
  --device /dev/sdb
```

Successful response example:

JSON{
    "AttachTime": "2026-01-24T18:57:00Z",
    "Device": "/dev/sdb",
    "InstanceId": "i-0123456789abcdef0",
    "State": "attaching",
    "VolumeId": "vol-0123456789abcdef0"
}

The state starts as attaching and quickly becomes attached.

Step 4: Verify Attachment Completed

Wait and check:
 
``` 
aws ec2 wait volume-in-use --region us-east-1 --volume-ids <VOLUME_ID>

```

## 13 Create AMI from EC2 Instance

AWS Management Console (GUI)

Go to EC2 Console → Instances → region us-east-1.
Select the instance xfusion-ec2.
Actions → Image and templates → Create image.
Image name: xfusion-ec2-ami
Description: optional (e.g., "From xfusion-ec2").
No reboot: check if you want to avoid reboot (not recommended unless necessary).
Create image.
Go to AMIs (left menu) → wait for status to change from pending → available (refresh periodically).

## 14 Terminate EC2 Instance

AWS Management Console (GUI)

EC2 Console → Instances → region us-east-1.
Search for nautilus-ec2.

Select it → Instance state → Terminate instance.

Confirm the termination.
Refresh the list periodically until State shows terminated.

Important warnings:

Termination protection (if enabled) will block this — disable it first as noted.
No charges accrue for a terminated instance (only for attached EBS volumes if not deleted).
If the instance is part of an Auto Scaling Group, it may be replaced automatically.

## 15 Create Volume Snapshot

In the left navigation pane, under Elastic Block Store, click Volumes.

In the Volumes list, locate the volume with the Name tag datacenter-vol (use the search/filter box at the top if needed, typing "datacenter-vol" in the Name filter).

Confirm it exists and note its Volume ID (e.g., vol-0123456789abcdef0) and State (should be "in-use" or "available").

Select the checkbox next to the volume datacenter-vol.

Click the Actions button (orange dropdown) at the top → choose Create snapshot.

In the Create snapshot dialog:

Resource type should default to Volume (or select it if prompted).
Volume should already show the selected volume (datacenter-vol).

In the Snapshot settings section:

Snapshot name → enter: datacenter-vol-ss

(This sets the Name tag for easy identification.)

Description → enter: datacenter Snapshot

(Optional but recommended) Add any additional tags if needed.
Leave other settings at defaults unless you have specific requirements.

Click Create snapshot at the bottom.

After creation starts, you'll see a success message. Click View all snapshots (or go manually: left navigation pane → Snapshots under Elastic Block Store).

In the Snapshots list:

Find the new snapshot by searching/filtering for Name = datacenter-vol-ss or check the Description column for "datacenter Snapshot".

Look at the Status column:

It starts as pending.
Refresh the page periodically (or click the refresh icon).
Wait until the Status changes to completed (this usually takes a few minutes to ~30+ minutes depending on volume size and data changed; larger volumes take longer).


Once the status shows completed:
The snapshot is fully ready and consistent.
You can verify details: select the snapshot → check Snapshot ID, Volume ID (matches datacenter-vol), Size, Start time, State = completed, and tags/description.

## 16 Create IAM User


## 39


```
aws s3api create-bucket \
  --bucket xfusion-s3-2373 \
  --region us-east-1

aws s3api put-public-access-block \
  --bucket xfusion-s3-2373 \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true \
  --region us-east-1


aws s3api get-public-access-block \
  --bucket xfusion-s3-2373 \
  --region us-east-1

```

## 40

``
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=datacenter-ec2" \
  --region us-east-1 \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text



aws ec2 terminate-instances \
  --instance-ids i-0b787299f930ed895 \
  --region us-east-1


aws ec2 wait instance-terminated \
  --instance-ids i-0b787299f930ed895 \
  --region us-east-1

  aws ec2 describe-instances \
  --instance-ids i-0b787299f930ed895 \
  --region us-east-1 \
  --query 'Reservations[0].Instances[0].State.Name'

```