### Day 1: Create Key Pair

create a key pair with the following requirements:
    Name of the key pair should be xfusion-kp.
    Key pair type must be rsa

```
aws-client ~ ➜  showcreds
╒══════════════════════╤═════════════════════════════════════════════════════════════════════╕
│ Name                 │ Value                                                               │
╞══════════════════════╪═════════════════════════════════════════════════════════════════════╡
│ AWS Console URL      │ https://574542119612.signin.aws.amazon.com/console?region=us-east-1 │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS User Name        │ kk_labs_user_923063                                                 │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS Password         │ lrgRWm3ES@33                                                        │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS Session End Time │ 2026-04-25T22:31:53Z                                                │
╘══════════════════════╧═════════════════════════════════════════════════════════════════════╛

aws-client ~ ➜  aws ec2 create-key-pair \
  --key-name xfusion-kp \
  --key-type rsa \
  --region us-east-1 \
  --query 'KeyMaterial' \
  --output text > xfusion-kp.pem

aws-client ~ ➜  chmod 400 xfusion-kp.pem

aws-client ~ ➜  aws ec2 describe-key-pairs --key-names xfusion-kp --region us-east-1
{
    "KeyPairs": [
        {
            "KeyPairId": "key-0f212cad412ffaaca",
            "KeyType": "rsa",
            "Tags": [],
            "CreateTime": "2026-04-25T21:40:05.723Z",
            "KeyName": "xfusion-kp",
            "KeyFingerprint": "90:74:d1:f9:9a:b1:6f:eb:12:e2:d3:73:39:1a:5c:50:5f:97:9d:9c"
        }
    ]
}

aws-client ~ ➜  

```

create a security group under default VPC with the following requirements:

Name of the security group is datacenter-sg.

The description must be Security group for Nautilus App Servers

Add the inbound rule of type HTTP, with port range of 80. Enter the source CIDR range of 0.0.0.0/0.

Add another inbound rule of type SSH, with port range of 22. Enter the source CIDR range of 0.0.0.0/0.


```
# Execute
GROUP_ID=$(aws ec2 create-security-group \
  --group-name datacenter-sg \
  --description "Security group for Nautilus App Servers" \
  --region us-east-1 \
  --query 'GroupId' --output text)

aws ec2 authorize-security-group-ingress --group-id $GROUP_ID --protocol tcp --port 80 --cidr 0.0.0.0/0 --region us-east-1
aws ec2 authorize-security-group-ingress --group-id $GROUP_ID --protocol tcp --port 22 --cidr 0.0.0.0/0 --region us-east-1

echo "Security group created with ID: $GROUP_ID"


## Validate
aws ec2 describe-security-groups \
  --group-names datacenter-sg \
  --region us-east-1 \
  --query 'SecurityGroups[0].{Name:GroupName,Description:Description,InboundRules:IpPermissions}'

```

## Day 6: Launch EC2 Instance

```

#1. Set the region

aws configure set region us-east-1

#2. Create a new RSA Key Pair (devops-kp)

aws ec2 create-key-pair \
  --key-name devops-kp \
  --query "KeyMaterial" \
  --output text > devops-kp.pem

#Secure the key file
chmod 400 devops-kp.pem

#3. Get the latest Amazon Linux 2023 AMI ID
AMI_ID=$(aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64 --query "Parameters[0].Value" --output text)

echo $AMI_ID
#4. Get the Default Security Group ID
DEFAULT_SG=$(aws ec2 describe-security-groups \
  --filters "Name=group-name,Values=default" \
  --query "SecurityGroups[0].GroupId" \
  --output text)
echo $DEFAULT_SG
#5. Launch the EC2 Instance (devops-ec2)
aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t2.micro \
  --key-name devops-kp \
  --security-group-ids $DEFAULT_SG \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=devops-ec2}]' \
  --query "Instances[0].InstanceId" \
  --output text
```

Verify


```
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=devops-ec2" \
  --query "Reservations[0].Instances[0].{InstanceId:InstanceId,State:State.Name,PublicIpAddress:PublicIpAddress,PrivateIpAddress:PrivateIpAddress}"

# Get Public DNS / IP (for SSH):

aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=devops-ec2" \
  --query "Reservations[0].Instances[0].PublicDnsName" \
  --output text

```

## Day 7: Change EC2 Instance Type

```
#1. Set the correct region

aws configure set region us-east-1

#2. Stop the instance

aws ec2 stop-instances \
  --instance-ids $(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=xfusion-ec2" \
    --query "Reservations[0].Instances[0].InstanceId" \
    --output text)
#Wait until the instance is fully stopped.
#3. Check instance state (optional but recommended)

aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=xfusion-ec2" \
  --query "Reservations[0].Instances[0].{InstanceId:InstanceId,State:State.Name,InstanceType:InstanceType}" \
  --output table
#4. Change Instance Type to t2.nano

aws ec2 modify-instance-attribute \
  --instance-id $(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=xfusion-ec2" \
    --query "Reservations[0].Instances[0].InstanceId" \
    --output text) \
  --instance-type t2.nano

#5. Start the instance again

aws ec2 start-instances \
  --instance-ids $(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=xfusion-ec2" \
    --query "Reservations[0].Instances[0].InstanceId" \
    --output text)

#6. Final Verification

#Run this command to confirm the instance type is now t2.nano and the state is running:

aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=xfusion-ec2" \
  --query "Reservations[0].Instances[0].{InstanceId:InstanceId,InstanceType:InstanceType,State:State.Name}" \
  --output table

```

## Day 8: Enable Stop Protection for EC2 Instance

```
aws ec2 modify-instance-attribute \
  --instance-id $(aws ec2 describe-instances --filters "Name=tag:Name,Values=devops-ec2" --query "Reservations[0].Instances[0].InstanceId" --output text) \
  --disable-api-stop

```


## Day 9: Enable Termination Protection for EC2 Instance

```
aws ec2 modify-instance-attribute \
  --instance-id $(aws ec2 describe-instances --filters "Name=tag:Name,Values=xfusion-ec2" --query "Reservations[0].Instances[0].InstanceId" --output text) \
  --disable-api-termination
```

## Day 10: Attach Elastic IP to EC2 Instance

```
aws ec2 associate-address \
  --instance-id $(aws ec2 describe-instances --filters "Name=tag:Name,Values=devops-ec2" --query "Reservations[0].Instances[0].InstanceId" --output text) \
  --allocation-id $(aws ec2 describe-addresses --filters "Name=tag:Name,Values=devops-ec2-eip" --query "Addresses[0].AllocationId" --output text)

```

What is an Elastic IP?

An Elastic IP (EIP) is a static (fixed) public IPv4 address provided by AWS that you can attach to your EC2 instance.

When Do We Attach an Elastic IP?

We attach an Elastic IP in the following scenarios:

Production web servers (Nginx, Apache, etc.)
Application servers that need a fixed public endpoint
CI/CD tools like Jenkins, GitLab, or TeamCity
Bastion hosts or jump servers
Databases or services that require whitelisting of IP addresses
Any workload where a permanent public IP is needed
Disaster recovery and high availability setups


## Day 11: Attach Elastic Network Interface to EC2 Instance

```

aws-client ~ ➜  aws configure set region us-east-1

aws-client ~ ➜  # Get Instance ID
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=xfusion-ec2" \
  --query "Reservations[0].Instances[0].InstanceId" \
  --output text)

# Get Network Interface ID
ENI_ID=$(aws ec2 describe-network-interfaces \
  --filters "Name=tag:Name,Values=xfusion-eni" \
  --query "NetworkInterfaces[0].NetworkInterfaceId" \
  --output text)

echo "Instance ID : $INSTANCE_ID"
echo "ENI ID      : $ENI_ID"
Instance ID : i-0e18957dbd1513be1
ENI ID      : eni-0e5e19db142c5a5d0

aws-client ~ ➜  aws ec2 attach-network-interface \
  --network-interface-id $ENI_ID \
  --instance-id $INSTANCE_ID \
  --device-index 1
{
    "AttachmentId": "eni-attach-0c80802f1bb69b970",
    "NetworkCardIndex": 0
}

aws-client ~ ➜  aws ec2 describe-network-interfaces \
  --filters "Name=tag:Name,Values=xfusion-eni" \
  --query "NetworkInterfaces[0].{NetworkInterfaceId:NetworkInterfaceId, Attachment:Attachment}" \
  --output table
-----------------------------------------------------------
|                DescribeNetworkInterfaces                |
+--------------------------+------------------------------+
|  NetworkInterfaceId      |  eni-0e5e19db142c5a5d0       |
+--------------------------+------------------------------+
||                      Attachment                       ||
|+----------------------+--------------------------------+|
||  AttachTime          |  2026-05-09T18:44:17.000Z      ||
||  AttachmentId        |  eni-attach-0c80802f1bb69b970  ||
||  DeleteOnTermination |  False                         ||
||  DeviceIndex         |  1                             ||
||  InstanceId          |  i-0e18957dbd1513be1           ||
||  InstanceOwnerId     |  784813782937                  ||
||  NetworkCardIndex    |  0                             ||
||  Status              |  attached                      ||
|+----------------------+--------------------------------+|


```

## Day 12: Attach Volume to EC2 Instance

```

aws-client ~ ➜  aws configure set region us-east-1

aws-client ~ ➜  # Get Instance ID
INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=xfusion-ec2" \
  --query "Reservations[0].Instances[0].InstanceId" \
  --output text)

# Get Volume ID
VOLUME_ID=$(aws ec2 describe-volumes \
  --filters "Name=tag:Name,Values=xfusion-volume" \
  --query "Volumes[0].VolumeId" \
  --output text)

echo "Instance ID : $INSTANCE_ID"
echo "Volume ID   : $VOLUME_ID"
Instance ID : i-07f5bb8fe2bf144a4
Volume ID   : vol-010ac8bd0951e7844

aws-client ~ ➜  aws ec2 attach-volume \
  --volume-id $VOLUME_ID \
  --instance-id $INSTANCE_ID \
  --device /dev/sdb
{
    "VolumeId": "vol-010ac8bd0951e7844",
    "InstanceId": "i-07f5bb8fe2bf144a4",
    "Device": "/dev/sdb",
    "State": "attaching",
    "AttachTime": "2026-05-09T20:30:42.432Z"
}

aws-client ~ ➜  aws ec2 describe-volumes \
  --volume-ids $VOLUME_ID \
  --query "Volumes[0].{VolumeId:VolumeId, State:State, Attachment:Attachments[0]}" \
  --output table
-------------------------------------------------------
|                   DescribeVolumes                   |
+----------------+------------------------------------+
|  State         |  in-use                            |
|  VolumeId      |  vol-010ac8bd0951e7844             |
+----------------+------------------------------------+
||                    Attachment                     ||
|+----------------------+----------------------------+|
||  AttachTime          |  2026-05-09T20:30:42.000Z  ||
||  DeleteOnTermination |  False                     ||
||  Device              |  /dev/sdb                  ||
||  EbsCardIndex        |  0                         ||
||  InstanceId          |  i-07f5bb8fe2bf144a4       ||
||  State               |  attached                  ||
||  VolumeId            |  vol-010ac8bd0951e7844     ||
|+----------------------+----------------------------+|


```

## Day 13: Create AMI from EC2 Instance

```

aws-client ~ ➜  aws configure set region us-east-1

aws-client ~ ➜  INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=datacenter-ec2" \
  --query "Reservations[0].Instances[0].InstanceId" \
  --output text)

echo "Instance ID: $INSTANCE_ID"
Instance ID: i-04fb438c99cd210ae

aws-client ~ ➜  aws ec2 create-image \
  --instance-id $INSTANCE_ID \
  --name datacenter-ec2-ami \
  --description "AMI created from datacenter-ec2" \
  --tag-specifications 'ResourceType=image,Tags=[{Key=Name,Value=datacenter-ec2-ami}]' \
  --query "ImageId" \
  --output text
ami-04dbd589edcfe08b1

aws-client ~ ➜  IMAGE_ID=ami-04dbd589edcfe08b1


aws-client ~ ✖ aws ec2 wait image-available --image-ids $IMAGE_ID && echo "AMI is now Available!"
AMI is now Available!

aws-client ~ ➜  

```

## Day 14: Terminate EC2 Instance

```
aws-client ~ ➜  aws configure set region us-east-1

aws-client ~ ➜  INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=devops-ec2" \
  --query "Reservations[0].Instances[0].InstanceId" \
  --output text)

echo "Instance ID: $INSTANCE_ID"
Instance ID: i-01f9d17d179ff1400

aws-client ~ ➜  aws ec2 terminate-instances --instance-ids $INSTANCE_ID
{
    "TerminatingInstances": [
        {
            "InstanceId": "i-01f9d17d179ff1400",
            "CurrentState": {
                "Code": 32,
                "Name": "shutting-down"
            },
            "PreviousState": {
                "Code": 16,
                "Name": "running"
            }
        }
    ]
}

aws-client ~ ➜  aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID
echo "Instance has been successfully terminated!"
Instance has been successfully terminated!

aws-client ~ ➜  aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query "Reservations[0].Instances[0].{InstanceId:InstanceId, State:State.Name, Name:Tags[?Key=='Name'].Value|[0]}" \
  --output table
-----------------------------------------------------
|                 DescribeInstances                 |
+---------------------+--------------+--------------+
|     InstanceId      |    Name      |    State     |
+---------------------+--------------+--------------+
|  i-01f9d17d179ff1400|  devops-ec2  |  terminated  |
+---------------------+--------------+--------------+

aws-client ~ ➜  
```

## Day 15: Create Volume Snapshot

```
SNAPSHOT_ID=$(aws ec2 create-snapshot \
  --volume-id $(aws ec2 describe-volumes --filters "Name=tag:Name,Values=xfusion-vol" --query "Volumes[0].VolumeId" --output text) \
  --description "xfusion Snapshot" \
  --tag-specifications 'ResourceType=snapshot,Tags=[{Key=Name,Value=xfusion-vol-ss}]' \
  --query "SnapshotId" --output text)

echo "Created Snapshot: $SNAPSHOT_ID"

aws ec2 wait snapshot-completed --snapshot-ids $SNAPSHOT_ID && echo "✅ Snapshot is Completed and Ready!"

```

## Day 16: Create IAM User

```
aws-client ~ ➜  aws configure set region us-east-1

aws-client ~ ➜  aws iam create-user \
  --user-name iamuser_kirsty \
  --tags Key=Name,Value=iamuser_kirsty
{
    "User": {
        "Path": "/",
        "UserName": "iamuser_kirsty",
        "UserId": "AIDAX4727QWZ7MIJLHM6K",
        "Arn": "arn:aws:iam::543302845875:user/iamuser_kirsty",
        "CreateDate": "2026-05-09T20:45:22Z",
        "Tags": [
            {
                "Key": "Name",
                "Value": "iamuser_kirsty"
            }
        ]
    }
}

aws-client ~ ➜  aws iam get-user --user-name iamuser_kirsty
{
    "User": {
        "Path": "/",
        "UserName": "iamuser_kirsty",
        "UserId": "AIDAX4727QWZ7MIJLHM6K",
        "Arn": "arn:aws:iam::543302845875:user/iamuser_kirsty",
        "CreateDate": "2026-05-09T20:45:22Z",
        "Tags": [
            {
                "Key": "Name",
                "Value": "iamuser_kirsty"
            }
        ]
    }
}


```
## Day 17: Create IAM Group

```
aws-client ~ ✖ aws iam create-group \
  --group-name iamgroup_john
{
    "Group": {
        "Path": "/",
        "GroupName": "iamgroup_john",
        "GroupId": "AGPAUWHF2O3433XBOBJTX",
        "Arn": "arn:aws:iam::322604529401:group/iamgroup_john",
        "CreateDate": "2026-05-09T20:51:05Z"
    }
}

aws-client ~ ➜  aws iam list-groups \
  --query "Groups[?GroupName=='iamgroup_john']" \
  --output table
-----------------------------------------------------------------
|                          ListGroups                           |
+------------+--------------------------------------------------+
|  Arn       |  arn:aws:iam::322604529401:group/iamgroup_john   |
|  CreateDate|  2026-05-09T20:51:05Z                            |
|  GroupId   |  AGPAUWHF2O3433XBOBJTX                           |
|  GroupName |  iamgroup_john                                   |
|  Path      |  /                                               |
+------------+--------------------------------------------------+

aws-client ~ ➜  

```

## Day 18: Create Read-Only IAM Policy for EC2 Console Access

```
Day 18: Create Read-Only IAM Policy for EC2 Console Access

aws-client ~ ➜  vi iampolicy_kirsty.json

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EC2ReadOnlyAccess",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeImages",
        "ec2:DescribeSnapshots",
        "ec2:DescribeVolumes",
        "ec2:DescribeTags",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeSubnets",
        "ec2:DescribeVpcs",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeRegions",
        "ec2:DescribeKeyPairs",
        "ec2:DescribeInstanceStatus"
      ],
      "Resource": "*"
    }
  ]
}


aws-client ~ ➜  aws iam create-policy \
  --policy-name iampolicy_kirsty\
  --policy-document file://iampolicy_kirsty.json \
  --region us-east-1
{
    "Policy": {
        "PolicyName": "iampolicy_kirsty",
        "PolicyId": "ANPAZQ3DUELW57SQMM73X",
        "Arn": "arn:aws:iam::654654579437:policy/iampolicy_kirsty",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2026-05-10T17:10:44Z",
        "UpdateDate": "2026-05-10T17:10:44Z"
    }
}

aws-client ~ ➜  aws iam get-policy --policy-arn arn:aws:iam::<ACCOUNT_ID>:policy/iampolicy_ravi
bash: ACCOUNT_ID: No such file or directory

aws-client ~ ✖ showcreds
╒══════════════════════╤═════════════════════════════════════════════════════════════════════╕
│ Name                 │ Value                                                               │
╞══════════════════════╪═════════════════════════════════════════════════════════════════════╡
│ AWS Console URL      │ https://654654579437.signin.aws.amazon.com/console?region=us-east-1 │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS User Name        │ kk_labs_user_719911                                                 │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS Password         │ 9PicF5!hTgqy                                                        │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS Session End Time │ 2026-05-10T18:07:25Z                                                │
╘══════════════════════╧═════════════════════════════════════════════════════════════════════╛

 

aws-client ~ ✖ aws iam get-policy --policy-arn arn:aws:iam::654654579437:policy/iampolicy_kirsty
{
    "Policy": {
        "PolicyName": "iampolicy_kirsty",
        "PolicyId": "ANPAZQ3DUELW57SQMM73X",
        "Arn": "arn:aws:iam::654654579437:policy/iampolicy_kirsty",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
        "CreateDate": "2026-05-10T17:10:44Z",
        "UpdateDate": "2026-05-10T17:10:44Z",
        "Tags": []
    }
}

aws-client ~ ➜  

```
 
## Day 19: Attach IAM Policy to IAM User

Create an IAM user named iamuser_mark and a policy named iampolicy_mark already exist. 
Attach the IAM policy iampolicy_mark to the IAM user iamuser_mark.


```
aws-client ~ ➜  showcreds
╒══════════════════════╤═════════════════════════════════════════════════════════════════════╕
│ Name                 │ Value                                                               │
╞══════════════════════╪═════════════════════════════════════════════════════════════════════╡
│ AWS Console URL      │ https://251939665979.signin.aws.amazon.com/console?region=us-east-1 │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS User Name        │ kk_labs_user_785359                                                 │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS Password         │ T6^oc!Xmn!Ko                                                        │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS Session End Time │ 2026-05-10T18:16:34Z                                                │
╘══════════════════════╧═════════════════════════════════════════════════════════════════════╛

aws-client ~ ➜  export ACCOUNTID=251939665979

 

aws-client ~ ➜  aws sts get-caller-identity
{
    "UserId": "AIDATVKGGHA5YL23JVPMT",
    "Account": "251939665979",
    "Arn": "arn:aws:iam::251939665979:user/kk_labs_user_785359"
}


aws-client ~ ➜  aws iam attach-user-policy \
  --user-name iamuser_mark \
  --policy-arn arn:aws:iam::251939665979:policy/iampolicy_mark

aws-client ~ ➜  aws iam list-attached-user-policies \
  --user-name iamuser_mark
{
    "AttachedPolicies": [
        {
            "PolicyName": "iampolicy_mark",
            "PolicyArn": "arn:aws:iam::251939665979:policy/iampolicy_mark"
        }
    ]
}

 

```

## Day 20: Create IAM Role for EC2 with Policy Attachment

Create an IAM role as below: 
  1) IAM role name must be iamrole_siva. 
  2) Entity type must be AWS Service and use case must be EC2. 
  3) Attach a policy named iampolicy_siva.


```
aws-client ~ ✖ vi trust-policy.json

aws-client ~ ➜  aws iam create-role \
  --role-name iamrole_siva \
  --assume-role-policy-document file://trust-policy.json
{
    "Role": {
        "Path": "/",
        "RoleName": "iamrole_siva",
        "RoleId": "AROAWB5UIIVSLSG5MMYM3",
        "Arn": "arn:aws:iam::416452986212:role/iamrole_siva",
        "CreateDate": "2026-05-10T17:24:37Z",
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "ec2.amazonaws.com"
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        }
    }
}

aws-client ~ ➜  aws sts get-caller-identity
{
    "UserId": "AIDAWB5UIIVSGCY74UYVE",
    "Account": "416452986212",
    "Arn": "arn:aws:iam::416452986212:user/kk_labs_user_500493"
}

aws-client ~ ➜  aws iam attach-role-policy \
  --role-name iamrole_siva \
  --policy-arn arn:aws:iam::416452986212:policy/iampolicy_siva

aws-client ~ ➜  aws sts get-caller-identity
{
    "UserId": "AIDAWB5UIIVSGCY74UYVE",
    "Account": "416452986212",
    "Arn": "arn:aws:iam::416452986212:user/kk_labs_user_500493"
}

aws-client ~ ➜  aws iam attach-role-policy   --role-name iamrole_siva   --policy-arn arn:aws:iam::416452986212:policy/iampolicy_siva

 

aws-client ~ ✖ aws iam get-role \
  --role-name iamrole_siva
{
    "Role": {
        "Path": "/",
        "RoleName": "iamrole_siva",
        "RoleId": "AROAWB5UIIVSLSG5MMYM3",
        "Arn": "arn:aws:iam::416452986212:role/iamrole_siva",
        "CreateDate": "2026-05-10T17:24:37Z",
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "ec2.amazonaws.com"
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        },
        "MaxSessionDuration": 3600,
        "RoleLastUsed": {}
    }
}

aws-client ~ ➜  aws iam list-attached-role-policies \
  --role-name iamrole_siva
{
    "AttachedPolicies": [
        {
            "PolicyName": "iampolicy_siva",
            "PolicyArn": "arn:aws:iam::416452986212:policy/iampolicy_siva"
        }
    ]
}

aws-client ~ ➜  aws iam list-attached-role-policies \
  --role-name iamrole_siva
{
    "AttachedPolicies": [
        {
            "PolicyName": "iampolicy_siva",
            "PolicyArn": "arn:aws:iam::416452986212:policy/iampolicy_siva"
        }
    ]
}

 
```
 
## Day 21: Setting Up an EC2 Instance with an Elastic IP for Application Hosting

Create an EC2 instance named datacenter-ec2 using any linux AMI like ubuntu, 
the Instance type must be t2.micro and 
associate an Elastic IP address with this instance, name it as datacenter-eip.


```
aws-client ~ ➜  AMI_ID=$(aws ssm get-parameters \
  --names /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id \ 
  --region us-east-1 \
  --query "Parameters[0].Value" \
  --output text)

aws-client ~ ➜  INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t2.micro \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=datacenter-ec2}]' \
  --region us-east-1 \
  --query 'Instances[0].InstanceId' \
  --output text)

aws-client ~ ➜  aws ec2 wait instance-running \
  --instance-ids $INSTANCE_ID \
  --region us-east-1

aws-client ~ ➜  ALLOCATION_ID=$(aws ec2 allocate-address \
  --domain vpc \
  --region us-east-1 \
  --query 'AllocationId' \
  --output text)

aws-client ~ ➜  echo $ALLOCATION_ID
eipalloc-09e5a3d47a366789e

aws-client ~ ➜  aws ec2 create-tags \
  --resources $ALLOCATION_ID \
  --tags Key=Name,Value=datacenter-eip \
  --region us-east-1

aws-client ~ ➜  aws ec2 associate-address \
  --instance-id $INSTANCE_ID \
  --allocation-id $ALLOCATION_ID \
  --region us-east-1
{
    "AssociationId": "eipassoc-005f164ccb2a47ee3"
}

aws-client ~ ➜  aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --region us-east-1 \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,Tags]'
[
    [
        [
            "i-0a03f6cd186060932",
            "running",
            "3.232.194.202",
            [
                {
                    "Key": "Name",
                    "Value": "datacenter-ec2"
                }
            ]
        ]
    ]
]

aws-client ~ ➜  aws ec2 describe-addresses \
  --allocation-ids $ALLOCATION_ID \
  --region us-east-1
{
    "Addresses": [
        {
            "AllocationId": "eipalloc-09e5a3d47a366789e",
            "AssociationId": "eipassoc-005f164ccb2a47ee3",
            "Domain": "vpc",
            "NetworkInterfaceId": "eni-0102341106f56346d",
            "NetworkInterfaceOwnerId": "453274592256",
            "PrivateIpAddress": "172.31.33.170",
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "datacenter-eip"
                }
            ],
            "PublicIpv4Pool": "amazon",
            "NetworkBorderGroup": "us-east-1",
            "InstanceId": "i-0a03f6cd186060932",
            "PublicIp": "3.232.194.202"
        }
    ]
}

aws-client ~ ➜  

```
 
## Day 22: Configuring Secure SSH Access to an EC2 Instance
 ```

  aws-client ~ ➜  aws configure set region us-east-1

aws-client ~ ➜  showcreds
╒══════════════════════╤═════════════════════════════════════════════════════════════════════╕
│ Name                 │ Value                                                               │
╞══════════════════════╪═════════════════════════════════════════════════════════════════════╡
│ AWS Console URL      │ https://574542119612.signin.aws.amazon.com/console?region=us-east-1 │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS User Name        │ kk_labs_user_200101                                                 │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS Password         │ 6oZehQ4%!Qcf                                                        │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS Session End Time │ 2026-05-10T19:55:29Z                                                │
╘══════════════════════╧═════════════════════════════════════════════════════════════════════╛

aws-client ~ ➜  mkdir -p /root/.ssh

aws-client ~ ➜   ssh-keygen -t rsa -b 2048 -f /root/.ssh/id_rsa -N ""
Generating public/private rsa key pair.
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:Uh9azQjQWIagked6x/cJhs6Fl6HlB0naIchROyLlGj4 root@aws-client
The key's randomart image is:
+---[RSA 2048]----+
|  .o+=o*+        |
|  .=+ +o+. +     |
|  +oo o=.o+ o    |
| . +...o*+ .     |
|  E. ..*S+.      |
|  ... *.O .      |
|   . + = + .     |
|      o   o      |
|                 |
+----[SHA256]-----+

aws-client ~ ➜  aws ec2 import-key-pair \
  --key-name datacenter-key \
  --public-key-material fileb:///root/.ssh/id_rsa.pub \
  --region us-east-1
{
    "KeyFingerprint": "e2:f7:d7:c9:6b:29:fa:34:12:95:c4:53:79:78:66:50",
    "KeyName": "datacenter-key",
    "KeyPairId": "key-0298096e8e2b5614e"
}

aws-client ~ ➜  AMI_ID=$(aws ssm get-parameters \
  --names /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id \ 
  --region us-east-1 \
  --query "Parameters[0].Value" \
  --output text)

aws-client ~ ➜  SG_ID=$(aws ec2 create-security-group \
  --group-name datacenter-ssh-sg \
  --description "Allow SSH" \
  --region us-east-1 \
  --query 'GroupId' \
  --output text)

aws-client ~ ➜  aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --region us-east-1
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-02a170d83e0cb722b",
            "GroupId": "sg-064b51cf9b1a8eaad",
            "GroupOwnerId": "574542119612",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 22,
            "ToPort": 22,
            "CidrIpv4": "0.0.0.0/0",
            "SecurityGroupRuleArn": "arn:aws:ec2:us-east-1:574542119612:security-group-rule/sgr-02a170d83e0cb722b"
        }
    ]
}

aws-client ~ ➜  INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t2.micro \
  --key-name datacenter-key \
  --security-group-ids $SG_ID \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=datacenter-ec2}]' \
  --region us-east-1 \
  --query 'Instances[0].InstanceId' \
  --output text)

aws-client ~ ➜  aws ec2 wait instance-running \
  --instance-ids $INSTANCE_ID \
  --region us-east-1

aws-client ~ ➜  PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --region us-east-1 \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo $PUBLIC_IP
18.234.75.65

 

 
 

aws-client ~ ➜  ssh -o StrictHostKeyChecking=no -i /root/.ssh/id_rsa ubuntu@$PUBLIC_IP "
sudo mkdir -p /root/.ssh &&
sudo cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys &&
sudo chmod 700 /root/.ssh &&
sudo chmod 600 /root/.ssh/authorized_keys
"

aws-client ~ ➜  ssh -i /root/.ssh/id_rsa root@$PUBLIC_IP
Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 6.8.0-1053-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sun May 10 19:01:47 UTC 2026

  System load:  0.15              Processes:             105
  Usage of /:   24.0% of 7.57GB   Users logged in:       0
  Memory usage: 20%               IPv4 address for eth0: 172.31.38.160
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update

Last login: Sun May 10 19:00:38 2026 from 65.108.255.62
root@ip-172-31-38-160:~# exit
logout
Connection to 18.234.75.65 closed.

 
```


## Day 23: Data Migration Between S3 Buckets Using AWS CLI

```

#Create the new private S3 bucket
aws s3api create-bucket \
  --bucket xfusion-sync-3056 \
  --region us-east-1

 
# Verify bucket is private
aws s3api put-public-access-block \
  --bucket xfusion-sync-3056 \
  --public-access-block-configuration \
BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

#Sync data from source bucket to destination bucket

aws s3 sync s3://xfusion-s3-11353 s3://xfusion-sync-3056

#Verify data consistency
aws s3 ls s3://xfusion-s3-11353 --recursive | wc -l
aws s3 ls s3://xfusion-sync-3056 --recursive | wc -l
aws s3 sync s3://xfusion-s3-11353 s3://xfusion-sync-3056 --dryrun

```
 
## Day 24: Setting Up an Application Load Balancer for an EC2 Instance
```

aws-client ~ ➜  REGION=us-east-1
VPC_ID=$(aws ec2 describe-vpcs \
  --region $REGION \
  --query "Vpcs[0].VpcId" \
  --output text)

#. Create security group for ALB (datacenter-sg)

aws-client ~ ➜  ALB_SG_ID=$(aws ec2 create-security-group \
  --group-name datacenter-sg \
  --description "ALB security group" \
  --vpc-id $VPC_ID \
  --region $REGION \
  --query 'GroupId' \
  --output text)


# Get EC2 instance ID (datacenter-ec2)

aws-client ~ ➜  aws ec2 authorize-security-group-ingress \
  --group-id $ALB_SG_ID \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0 \
  --region $REGION
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-0c0f6e4eab1ca6a15",
            "GroupId": "sg-01b5a33c33547bac9",
            "GroupOwnerId": "495118158858",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 80,
            "ToPort": 80,
            "CidrIpv4": "0.0.0.0/0",
            "SecurityGroupRuleArn": "arn:aws:ec2:us-east-1:495118158858:security-group-rule/sgr-0c0f6e4eab1ca6a15"
        }
    ]
}

# Get EC2 instance ID (datacenter-ec2)

aws-client ~ ➜  INSTANCE_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=datacenter-ec2" \
  --region $REGION \
  --query "Reservations[0].Instances[0].InstanceId" \
  --output text)

#Get its security group:
aws-client ~ ➜  EC2_SG_ID=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --region $REGION \
  --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" \
  --output text)

# Allow ALB → EC2 traffic on port 80
aws-client ~ ➜  aws ec2 authorize-security-group-ingress \
  --group-id $EC2_SG_ID \
  --protocol tcp \
  --port 80 \
  --source-group $ALB_SG_ID \
  --region $REGION
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-06c2d68a203f10ed6",
            "GroupId": "sg-059958ff5ce5a159a",
            "GroupOwnerId": "495118158858",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 80,
            "ToPort": 80,
            "ReferencedGroupInfo": {
                "GroupId": "sg-01b5a33c33547bac9",
                "UserId": "495118158858"
            },
            "SecurityGroupRuleArn": "arn:aws:ec2:us-east-1:495118158858:security-group-rule/sgr-06c2d68a203f10ed6"
        }
    ]
}

# Create Target Group (datacenter-tg)
aws-client ~ ➜  TG_ARN=$(aws elbv2 create-target-group \
  --name datacenter-tg \
  --protocol HTTP \
  --port 80 \
  --vpc-id $VPC_ID \
  --target-type instance \
  --region $REGION \
  --query 'TargetGroups[0].TargetGroupArn' \
  --output text)

# Register EC2 instance to Target Group

aws-client ~ ➜  aws elbv2 register-targets \
  --target-group-arn $TG_ARN \
  --targets Id=$INSTANCE_ID \
  --region $REGION

# Create Application Load Balancer (datacenter-alb)

#Get subnet IDs:
aws-client ~ ➜  SUBNETS=$(aws ec2 describe-subnets \
  --region $REGION \
  --query "Subnets[*].SubnetId" \
  --output text)

#Create ALB:
aws-client ~ ➜  ALB_ARN=$(aws elbv2 create-load-balancer \
  --name datacenter-alb \
  --subnets $SUBNETS \
  --security-groups $ALB_SG_ID \
  --scheme internet-facing \
  --type application \
  --region $REGION \
  --query 'LoadBalancers[0].LoadBalancerArn' \
  --output text)

#Get ALB DNS:
aws-client ~ ➜  aws elbv2 describe-load-balancers \
  --load-balancer-arns $ALB_ARN \
  --region $REGION \
  --query 'LoadBalancers[0].DNSName' \
  --output text
datacenter-alb-171411087.us-east-1.elb.amazonaws.com

# Create Listener (HTTP:80 → Target Group)

aws-client ~ ➜  aws elbv2 create-listener \
  --load-balancer-arn $ALB_ARN \
  --protocol HTTP \
  --port 80 \
  --default-actions Type=forward,TargetGroupArn=$TG_ARN \
  --region $REGION
{
    "Listeners": [
        {
            "ListenerArn": "arn:aws:elasticloadbalancing:us-east-1:495118158858:listener/app/datacenter-alb/d525ebb41074ea39/bb2ed4ac0d0f8480",
            "LoadBalancerArn": "arn:aws:elasticloadbalancing:us-east-1:495118158858:loadbalancer/app/datacenter-alb/d525ebb41074ea39",
            "Port": 80,
            "Protocol": "HTTP",
            "DefaultActions": [
                {
                    "Type": "forward",
                    "TargetGroupArn": "arn:aws:elasticloadbalancing:us-east-1:495118158858:targetgroup/datacenter-tg/1330f4feb9f95f15",
                    "ForwardConfig": {
                        "TargetGroups": [
                            {
                                "TargetGroupArn": "arn:aws:elasticloadbalancing:us-east-1:495118158858:targetgroup/datacenter-tg/1330f4feb9f95f15",
                                "Weight": 1
                            }
                        ],
                        "TargetGroupStickinessConfig": {
                            "Enabled": false
                        }
                    }
                }
            ]
        }
    ]
}

# Final validation

aws-client ~ ➜  aws elbv2 describe-target-health \
  --target-group-arn $TG_ARN \
  --region $REGION
{
    "TargetHealthDescriptions": [
        {
            "Target": {
                "Id": "i-0ae5c0109241ef571",
                "Port": 80
            },
            "HealthCheckPort": "80",
            "TargetHealth": {
                "State": "initial",
                "Reason": "Elb.RegistrationInProgress",
                "Description": "Target registration is in progress"
            },
            "AdministrativeOverride": {
                "State": "no_override",
                "Reason": "AdministrativeOverride.NoOverride",
                "Description": "No override is currently active on target"
            }
        }
    ]
}

aws-client ~ ➜  
```
 
## Day 25: Setting Up an EC2 Instance and CloudWatch Alarm

Launch EC2 Instance: Create an EC2 instance named nautilus-ec2 using any appropriate Ubuntu AMI.

Create CloudWatch Alarm: Create a CloudWatch alarm named nautilus-alarm with the following specifications:

Statistic: Average
Metric: CPU Utilization
Threshold: >= 90% for 1 consecutive 5-minute period.
Alarm Actions: Send a notification to nautilus-sns-topic.
```

aws-client ~ ➜  aws ec2 describe-images \
  --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" \
  --query 'Images[*].[ImageId,Name,CreationDate]' \
  --output table | sort -k3 -r | head -5
|  ami-09d76382cbfc09f06|  ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20260507  |  2026-05-07T11:45:29.000Z  |
|  ami-05cf1e9f73fbad2e2|  ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20260424  |  2026-04-24T10:54:31.000Z  |
|  ami-009d9173b44d0482b|  ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20260409  |  2026-04-09T14:13:23.000Z  |
|  ami-04eaa218f1349d88b|  ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20260321  |  2026-03-21T11:10:28.000Z  |
|  ami-0462ececcfe0a450f|  ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20260320  |  2026-03-20T11:01:46.000Z  |

aws-client ~ ➜  aws ec2 describe-key-pairs \
  --query 'KeyPairs[*].[KeyName,KeyPairId,KeyType,CreateTime]' \
  --output table

aws-client ~ ➜  showcreds
╒══════════════════════╤═════════════════════════════════════════════════════════════════════╕
│ Name                 │ Value                                                               │
╞══════════════════════╪═════════════════════════════════════════════════════════════════════╡
│ AWS Console URL      │ https://582762278555.signin.aws.amazon.com/console?region=us-east-1 │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS User Name        │ kk_labs_user_919972                                                 │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS Password         │ zJF!d@73Zb0Z                                                        │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS Session End Time │ 2026-05-14T04:24:57Z                                                │
╘══════════════════════╧═════════════════════════════════════════════════════════════════════╛

aws-client ~ ➜  aws ec2 create-key-pair \
  --key-name nautilus-key \
  --key-type rsa \
  --key-format pem \
  --query "KeyMaterial" \
  --output text > nautilus-key.pem

aws-client ~ ➜  chmod 400 nautilus-key.pem

aws-client ~ ➜  aws ec2 describe-key-pairs --key-names nautilus-key
{
    "KeyPairs": [
        {
            "KeyPairId": "key-07798cce56809e7f7",
            "KeyType": "rsa",
            "Tags": [],
            "CreateTime": "2026-05-14T03:29:53.548Z",
            "KeyName": "nautilus-key",
            "KeyFingerprint": "94:28:b6:0c:b8:44:0a:6c:76:77:1a:4c:0f:7a:f1:13:58:1d:83:6c"
        }
    ]
}

 
 

aws-client ~ ➜  aws ec2 describe-security-groups --filters "Name=group-name,Values=default" --query 'SecurityGroups[0].GroupId' --output text
sg-0ea9c34b630f0b7e9

aws-client ~ ➜  aws ec2 describe-subnets --filters "Name=map-public-ip-on-launch,Values=true" --query 'Subnets[0].SubnetId' --output text
subnet-0bb03eac9a40b63bf

aws-client ~ ➜  aws ec2 run-instances \
  --image-id ami-0462ececcfe0a450f \
  --instance-type t3.micro \
  --key-name nautilus-key \
  --security-group-ids sg-0ea9c34b630f0b7e9 \                                    
  --subnet-id subnet-0bb03eac9a40b63bf \                                           
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=nautilus-ec2}]' \
  --query 'Instances[0].InstanceId' \
  --output text
i-0937db8e8f9dda833

aws-client ~ ➜  aws sns create-topic --name nautilus-sns-topic
{
    "TopicArn": "arn:aws:sns:us-east-1:582762278555:nautilus-sns-topic"
}

aws-client ~ ➜  aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:582762278555:nautilus-sns-topic \
  --protocol email \
  --notification-endpoint ilovedevops2022@gmail.com
{
    "SubscriptionArn": "pending confirmation"
}

aws-client ~ ➜  aws cloudwatch put-metric-alarm \
  --alarm-name nautilus-alarm \
  --alarm-description "Alarm when CPU exceeds 90% for 5 minutes" \
  --metric-name CPUUtilization \
  --namespace AWS/EC2 \
  --statistic Average \
  --period 300 \
  --evaluation-periods 1 \
  --threshold 90 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --dimensions "Name=InstanceId,Value=i-0937db8e8f9dda833" \
  --alarm-actions arn:aws:sns:us-east-1:582762278555:nautilus-sns-topic \
  --unit Percent

 

aws-client ~ ✖ 


```
 
## Day 26: Configuring an EC2 Instance as a Web Server with Nginx

As a member of the Nautilus DevOps Team, your task is to create an EC2 instance with the following specifications:

Instance Name: The EC2 instance must be named devops-ec2.

AMI: Use any available Ubuntu AMI to create this instance.

User Data Script: Configure the instance to run a user data script during its launch. This script should:

Install the Nginx package.
Start the Nginx service.
Security Group: Ensure that the instance allows HTTP traffic on port 80 from the internet.

```
aws-client ~ ➜  aws ec2 create-key-pair \
  --key-name nautilus-key \
  --key-type rsa \
  --key-format pem \
  --query "KeyMaterial" \
  --output text > nautilus-key.pem

aws-client ~ ➜  chmod 400 nautilus-key.pem

aws-client ~ ➜  aws ec2 describe-key-pairs --key-names nautilus-key
{
    "KeyPairs": [
        {
            "KeyPairId": "key-0c1b3bef691a1be30",
            "KeyType": "rsa",
            "Tags": [],
            "CreateTime": "2026-05-14T04:20:10.683Z",
            "KeyName": "nautilus-key",
            "KeyFingerprint": "4e:9d:fb:17:b3:08:54:e5:43:9e:9b:f6:4f:f0:ef:c4:f4:eb:04:9e"
        }
    ]
}

aws-client ~ ➜   aws ec2 describe-subnets --filters "Name=map-public-ip-on-launch,Values=true" --query 'Subnets[0].SubnetId' --output text
subnet-07525cfa19b92ee96

aws-client ~ ➜  aws ec2 describe-security-groups --filters "Name=group-name,Values=default" --query 'SecurityGroups[0].GroupId' --output text
sg-04e57b00614827ce9


aws-client ~ ➜  aws ec2 describe-security-groups \
  --group-ids sg-04e57b00614827ce9 \
  --query 'SecurityGroups[0].IpPermissions[?ToPort==`80`]' \
  --output table

ws-client ~ ✖ aws ec2 authorize-security-group-ingress \
  --group-id sg-04e57b00614827ce9 \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-0af66caa19742d534",
            "GroupId": "sg-04e57b00614827ce9",
            "GroupOwnerId": "254597876252",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 80,
            "ToPort": 80,
            "CidrIpv4": "0.0.0.0/0",
            "SecurityGroupRuleArn": "arn:aws:ec2:us-east-1:254597876252:security-group-rule/sgr-0af66caa19742d534"
        }
    ]
}

aws-client ~ ➜  aws ec2 authorize-security-group-ingress \
  --group-id sg-04e57b00614827ce9 \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-0f9bdd99d6456f24e",
            "GroupId": "sg-04e57b00614827ce9",
            "GroupOwnerId": "254597876252",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 22,
            "ToPort": 22,
            "CidrIpv4": "0.0.0.0/0",
            "SecurityGroupRuleArn": "arn:aws:ec2:us-east-1:254597876252:security-group-rule/sgr-0f9bdd99d6456f24e"
        }
    ]
}

aws-client ~ ➜  ssh -i nautilus-key.pem ubuntu@98.93.144.59
The authenticity of host '98.93.144.59 (98.93.144.59)' can't be established.
ECDSA key fingerprint is SHA256:GEV2bL9lGFrz3Y7508g4wrEi33KQTby+MDSbtcUbSMQ.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '98.93.144.59' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 24.04.4 LTS (GNU/Linux 6.17.0-1013-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 

```
 
Day 27: Configuring a Public VPC with an EC2 Instance for Internet Access
```
```
 
Day 28: Creating a Private ECR Repository
```
```
 
Day 29: Establishing Secure Communication Between Public and Private VPCs via VPC Peering
 
Day 30: Enable Internet Access for Private EC2 using NAT Instance
 
Day 31: Configuring a Private RDS Instance for Application Development
 
Day 32: Snapshot and Restoration of an RDS Instance
 
Day 33: Create a Lambda Function
 
Day 34: Create a Lambda Function Using CLI
 
Day 35: Deploying and Managing Applications on AWS
 
Day 36: Load Balancing EC2 Instances with Application Load Balancer
 
Day 37: Managing EC2 Access with S3 Role-based Permissions
 
Day 38: Deploying Containerized Applications with Amazon ECS
 
Day 39: Hosting a Static Website on AWS S3
 
Day 40: Troubleshooting Internet Accessibility for an EC2-Hosted Application
 
Day 41: Securing Data with AWS KMS
 
Day 42: Building and Managing NoSQL Databases with AWS DynamoDB
 
Day 43: Scaling and Managing Kubernetes Clusters with Amazon EKS
 
Day 44: Implementing Auto Scaling for High Availability in AWS
 
Day 45: Configure NAT Gateway for Internet Access in a Private VPC
 
Day 46: Event-Driven Processing with Amazon S3 and Lambda
 
Day 47: Integrating AWS SQS and SNS for Reliable Messaging
 
Day 48: Automating Infrastructure Deployment with AWS CloudFormation
 
Day 49: Centralized Audit Logging with VPC Peering
 
 
Day 50: Expanding EC2 Instance Storage for Development Needs
