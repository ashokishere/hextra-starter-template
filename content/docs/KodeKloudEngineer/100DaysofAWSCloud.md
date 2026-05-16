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
 aws-client ~ ➜  aws ssm get-parameters \
--names /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id \
--region us-east-1 \
--query "Parameters[0].Value" \
--output text
ami-00403f401ee6a4b98

 

aws-client ~ ✖ aws ec2 create-key-pair \
  --key-name devops-key \
  --query 'KeyMaterial' \
  --output text > devops-key.pem

aws-client ~ ➜  chmod 400 devops-key.pem

aws-client ~ ➜  aws ec2 describe-vpcs \
  --filters "Name=isDefault,Values=true" \
  --query "Vpcs[0].VpcId" \
  --output text
vpc-0788f791486f41af9

aws-client ~ ➜  aws ec2 create-security-group \
  --group-name devops-nginx-sg \
  --description "Security group for Nginx web server" \
  --vpc-id vpc-xxxxxxxx

An error occurred (InvalidVpcId.Malformed) when calling the CreateSecurityGroup operation: The vpc ID 'vpc-xxxxxxxx' is malformed

aws-client ~ ✖ aws ec2 create-security-group   --group-name devops-nginx-sg   --description "Security group for Nginx web server"   --vpc-id vpc-0788f791486f41af9
{
    "GroupId": "sg-05feaa25dcf6ee9e5",
    "SecurityGroupArn": "arn:aws:ec2:us-east-1:148255177852:security-group/sg-05feaa25dcf6ee9e5"
}

aws-client ~ ➜  aws ec2 authorize-security-group-ingress \
  --group-id sg-05feaa25dcf6ee9e5 \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-08bcb166cd0a2f265",
            "GroupId": "sg-05feaa25dcf6ee9e5",
            "GroupOwnerId": "148255177852",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 80,
            "ToPort": 80,
            "CidrIpv4": "0.0.0.0/0",
            "SecurityGroupRuleArn": "arn:aws:ec2:us-east-1:148255177852:security-group-rule/sgr-08bcb166cd0a2f265"
        }
    ]
}

aws-client ~ ➜  aws ec2 authorize-security-group-ingress \
  --group-id sg-05feaa25dcf6ee9e5 \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-0a2ea00db5415bff7",
            "GroupId": "sg-05feaa25dcf6ee9e5",
            "GroupOwnerId": "148255177852",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 22,
            "ToPort": 22,
            "CidrIpv4": "0.0.0.0/0",
            "SecurityGroupRuleArn": "arn:aws:ec2:us-east-1:148255177852:security-group-rule/sgr-0a2ea00db5415bff7"
        }
    ]
}

aws-client ~ ➜  aws ec2 run-instances \
  --image-id ami-053b0d53c279acc90 \
  --count 1 \
  --instance-type t2.micro \
  --key-name devops-key \
  --security-group-ids sg-05feaa25dcf6ee9e5 \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=devops-ec2}]' \
  --user-data '#!/bin/bash
apt update -y
apt install nginx -y
systemctl enable nginx
systemctl start nginx'
{
    "ReservationId": "r-04e46580313bd76c2",
    "OwnerId": "148255177852",
    "Groups": [],
    "Instances": [
        {
            "Architecture": "x86_64",
            "BlockDeviceMappings": [],
            "ClientToken": "f9da6342-c5cb-4f4a-91b7-181f35a5f629",
            "EbsOptimized": false,
            "EnaSupport": true,
            "Hypervisor": "xen",
            "NetworkInterfaces": [
                {
                    "Attachment": {
                        "AttachTime": "2026-05-15T05:31:02.000Z",
                        "AttachmentId": "eni-attach-01e5031dc8e3a41e2",
                        "DeleteOnTermination": true,
                        "DeviceIndex": 0,
                        "Status": "attaching",
                        "NetworkCardIndex": 0
                    },
                    "Description": "",
                    "Groups": [
                        {
                            "GroupId": "sg-05feaa25dcf6ee9e5",
                            "GroupName": "devops-nginx-sg"
                        }
                    ],
                    "Ipv6Addresses": [],
                    "MacAddress": "0e:db:6a:84:90:d9",
                    "NetworkInterfaceId": "eni-07a9fa70b29311b3e",
                    "OwnerId": "148255177852",
                    "PrivateDnsName": "ip-172-31-34-246.ec2.internal",
                    "PrivateIpAddress": "172.31.34.246",
                    "PrivateIpAddresses": [
                        {
                            "Primary": true,
                            "PrivateDnsName": "ip-172-31-34-246.ec2.internal",
                            "PrivateIpAddress": "172.31.34.246"
                        }
                    ],
                    "SourceDestCheck": true,
                    "Status": "in-use",
                    "SubnetId": "subnet-0331e1222fdb8da79",
                    "VpcId": "vpc-0788f791486f41af9",
                    "InterfaceType": "interface",
                    "Operator": {
                        "Managed": false
                    }
                }
            ],
            "RootDeviceName": "/dev/sda1",
            "RootDeviceType": "ebs",
            "SecurityGroups": [
                {
                    "GroupId": "sg-05feaa25dcf6ee9e5",
                    "GroupName": "devops-nginx-sg"
                }
            ],
            "SourceDestCheck": true,
            "StateReason": {
                "Code": "pending",
                "Message": "pending"
            },
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "devops-ec2"
                }
            ],
            "VirtualizationType": "hvm",
            "CpuOptions": {
                "CoreCount": 1,
                "ThreadsPerCore": 1
            },
            "CapacityReservationSpecification": {
                "CapacityReservationPreference": "open"
            },
            "MetadataOptions": {
                "State": "pending",
                "HttpTokens": "optional",
                "HttpPutResponseHopLimit": 1,
                "HttpEndpoint": "enabled",
                "HttpProtocolIpv6": "disabled",
                "InstanceMetadataTags": "disabled"
            },
            "EnclaveOptions": {
                "Enabled": false
            },
            "PrivateDnsNameOptions": {
                "HostnameType": "ip-name",
                "EnableResourceNameDnsARecord": false,
                "EnableResourceNameDnsAAAARecord": false
            },
            "MaintenanceOptions": {
                "AutoRecovery": "default",
                "RebootMigration": "default"
            },
            "CurrentInstanceBootMode": "legacy-bios",
            "Operator": {
                "Managed": false
            },
            "InstanceId": "i-02725862e0f81bab4",
            "ImageId": "ami-053b0d53c279acc90",
            "State": {
                "Code": 0,
                "Name": "pending"
            },
            "PrivateDnsName": "ip-172-31-34-246.ec2.internal",
            "PublicDnsName": "",
            "StateTransitionReason": "",
            "KeyName": "devops-key",
            "AmiLaunchIndex": 0,
            "ProductCodes": [],
            "InstanceType": "t2.micro",
            "LaunchTime": "2026-05-15T05:31:02.000Z",
            "Placement": {
                "AvailabilityZoneId": "use1-az6",
                "GroupName": "",
                "Tenancy": "default",
                "AvailabilityZone": "us-east-1a"
            },
            "Monitoring": {
                "State": "disabled"
            },
            "SubnetId": "subnet-0331e1222fdb8da79",
            "VpcId": "vpc-0788f791486f41af9",
            "PrivateIpAddress": "172.31.34.246"
        }
    ]
}

aws-client ~ ➜  aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=devops-ec2" \
  --query "Reservations[*].Instances[*].PublicIpAddress" \
  --output text
52.91.179.15

aws-client ~ ➜  

```
 
## Day 27: Configuring a Public VPC with an EC2 Instance for Internet Access
```


aws-client ~ ➜  showcreds
╒══════════════════════╤═════════════════════════════════════════════════════════════════════╕
│ Name                 │ Value                                                               │
╞══════════════════════╪═════════════════════════════════════════════════════════════════════╡
│ AWS Console URL      │ https://604248583746.signin.aws.amazon.com/console?region=us-east-1 │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS User Name        │ kk_labs_user_617766                                                 │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS Password         │ yoTeWgaay66f                                                        │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS Session End Time │ 2026-05-15T06:35:47Z                                                │
╘══════════════════════╧═════════════════════════════════════════════════════════════════════╛

aws-client ~ ➜  aws configure
AWS Access Key ID [****************UIIE]: ^C

aws-client ~ ✖ VPC_ID=$(aws ec2 create-vpc \
  --cidr-block 10.0.0.0/16 \
  --query 'Vpc.VpcId' \
  --output text)

echo $VPC_ID
vpc-085c943671b20eb8e

aws-client ~ ➜  aws ec2 create-tags \
  --resources $VPC_ID \
  --tags Key=Name,Value=xfusion-pub-vpc

aws-client ~ ➜  aws ec2 modify-vpc-attribute \
  --vpc-id $VPC_ID \
  --enable-dns-support "{\"Value\":true}"

aws ec2 modify-vpc-attribute \
  --vpc-id $VPC_ID \
  --enable-dns-hostnames "{\"Value\":true}"

aws-client ~ ➜  SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.1.0/24 \
  --availability-zone us-east-1a \
  --query 'Subnet.SubnetId' \
  --output text)

echo $SUBNET_ID
subnet-0f251be59cc8339d9

aws-client ~ ➜  aws ec2 create-tags \
  --resources $SUBNET_ID \
  --tags Key=Name,Value=xfusion-pub-subnet

aws-client ~ ➜  aws ec2 modify-subnet-attribute \
  --subnet-id $SUBNET_ID \
  --map-public-ip-on-launch

aws-client ~ ➜  IGW_ID=$(aws ec2 create-internet-gateway \
  --query 'InternetGateway.InternetGatewayId' \
  --output text)

echo $IGW_ID
igw-05ef1abda5a0ded82

aws-client ~ ➜  aws ec2 attach-internet-gateway \
  --internet-gateway-id $IGW_ID \
  --vpc-id $VPC_ID

aws-client ~ ➜  RT_ID=$(aws ec2 create-route-table \
  --vpc-id $VPC_ID \
  --query 'RouteTable.RouteTableId' \
  --output text)

echo $RT_ID
rtb-0006eb4cc1421d3ae

aws-client ~ ➜  aws ec2 create-route \
  --route-table-id $RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID
{
    "Return": true
}

aws-client ~ ➜  aws ec2 associate-route-table \
  --route-table-id $RT_ID \
  --subnet-id $SUBNET_ID
{
    "AssociationId": "rtbassoc-0701abf580b332b3f",
    "AssociationState": {
        "State": "associated"
    }
}

aws-client ~ ➜  SG_ID=$(aws ec2 create-security-group \
  --group-name xfusion-pub-sg \
  --description "Allow SSH" \
  --vpc-id $VPC_ID \
  --query 'GroupId' \
  --output text)

echo $SG_ID
sg-0db2efc14e127624d

aws-client ~ ➜  aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-0b6c3afcb98fbda09",
            "GroupId": "sg-0db2efc14e127624d",
            "GroupOwnerId": "604248583746",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 22,
            "ToPort": 22,
            "CidrIpv4": "0.0.0.0/0",
            "SecurityGroupRuleArn": "arn:aws:ec2:us-east-1:604248583746:security-group-rule/sgr-0b6c3afcb98fbda09"
        }
    ]
}

aws-client ~ ➜  aws ec2 create-key-pair \
  --key-name xfusion-key \
  --query 'KeyMaterial' \
  --output text > xfusion-key.pem

aws-client ~ ➜  aws ec2 create-key-pair \
  --key-name xfusion-key \
  --query 'KeyMaterial' \
  --output text > xfusion-key.pem

An error occurred (InvalidKeyPair.Duplicate) when calling the CreateKeyPair operation: The keypair already exists

aws-client ~ ✖ chmod 400 xfusion-key.pem

aws-client ~ ➜  AMI_ID=$(aws ssm get-parameters \
  --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 \
  --query 'Parameters[0].Value' \
  --output text)

echo $AMI_ID
ami-03fdf597129d2144d

aws-client ~ ➜  INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t2.micro \
  --key-name xfusion-key \
  --subnet-id $SUBNET_ID \
  --security-group-ids $SG_ID \
  --associate-public-ip-address \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=xfusion-pub-ec2}]' \
  --query 'Instances[0].InstanceId' \
  --output text)

echo $INSTANCE_ID
i-0cdb1a58b92ba8323

aws-client ~ ➜  aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress]' \
  --output table
------------------------------------------
|            DescribeInstances           |
+----------------------+-----------------+
|  i-0cdb1a58b92ba8323 |  98.87.160.183  |
+----------------------+-----------------+

aws-client ~ ➜  ssh -i xfusion-key.pem ec2-user@98.87.160.183
The authenticity of host '98.87.160.183 (98.87.160.183)' can't be established.
ECDSA key fingerprint is SHA256:Te9kwrLlteoUpOghBxXMcMSXvr1fsuRbATr03KvW6dg.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '98.87.160.183' (ECDSA) to the list of known hosts.
Load key "xfusion-key.pem": invalid format
ec2-user@98.87.160.183's password: 


aws-client ~ ✖ ssh -i xfusion-key ec2-user@98.87.160.183
Warning: Identity file xfusion-key not accessible: No such file or directory.
ec2-user@98.87.160.183: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).

aws-client ~ ✖ ssh -i xfusion-key.pem ec2-user@98.87.160.183
Load key "xfusion-key.pem": invalid format
ec2-user@98.87.160.183: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).

aws-client ~ ✖ ssh -i xfusion-key.pem ec2-user@98.87.160.183
Load key "xfusion-key.pem": invalid format
ec2-user@98.87.160.183: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).

aws-client ~ ✖ aws ec2 create-key-pair \
  --key-name xfusion-key \
  --query 'KeyMaterial' \
  --output text > xfusion-key.pem

An error occurred (InvalidKeyPair.Duplicate) when calling the CreateKeyPair operation: The keypair already exists

aws-client ~ ✖ rm xfusion-key.pem

 

aws-client ~ ✖ aws ec2 delete-key-pair --key-name xfusion-key
{
    "Return": true,
    "KeyPairId": "key-048cac98df66b2f06"
}

aws-client ~ ➜  rm -f xfusion-key.pem

aws-client ~ ➜  aws ec2 create-key-pair \
  --key-name xfusion-key \
  --query 'KeyMaterial' \
  --output text > xfusion-key.pem

aws-client ~ ➜  chmod 400 xfusion-key.pem

aws-client ~ ➜  aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=xfusion-pub-ec2" \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text
i-0cdb1a58b92ba8323

aws-client ~ ➜  aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=xfusion-pub-ec2" \
  --query 'Reservations[*].Instances[*].PublicIpAddress' \
  --output text
98.87.160.183

aws-client ~ ➜  ssh -i xfusion-key.pem ec2-user@98.87.160.183
ec2-user@98.87.160.183: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).

aws-client ~ ✖ aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=xfusion-pub-ec2" "Name=instance-state-name,Values=running" \ 
  --query 'Reservations[*].Instances[*].PublicIpAddress' \
  --output text
98.87.160.183

aws-client ~ ➜  ssh -i xfusion-key.pem ec2-user@98.87.160.183
ec2-user@98.87.160.183: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).

aws-client ~ ✖ aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

An error occurred (InvalidPermission.Duplicate) when calling the AuthorizeSecurityGroupIngress operation: the specified rule "peer: 0.0.0.0/0, TCP, from port: 22, to port: 22, ALLOW" already exists

aws-client ~ ✖ chmod 400 xfusion-key.pem

aws-client ~ ➜  ssh -i xfusion-key.pem ec2-user@98.87.160.183
ec2-user@98.87.160.183: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).

aws-client ~ ✖ 
```
 
## Day 28: Creating a Private ECR Repository

Create a private ECR repository named nautilus-ecr. There is a Dockerfile under /root/pyapp directory on aws-client host, build a docker image using this Dockerfile and push the same to the newly created ECR repo, the image tag must be latest.


Use below given AWS Credentials: (You can run the showcreds command on aws-client host to retrieve these credentials)


```
aws-client ~ ➜  AWS_REGION=us-east-1
REPO_NAME=nautilus-ecr

aws-client ~ ➜  aws ecr create-repository \
  --repository-name $REPO_NAME \
  --region $AWS_REGION
{
    "repository": {
        "repositoryArn": "arn:aws:ecr:us-east-1:031744724431:repository/nautilus-ecr",
        "registryId": "031744724431",
        "repositoryName": "nautilus-ecr",
        "repositoryUri": "031744724431.dkr.ecr.us-east-1.amazonaws.com/nautilus-ecr",
        "createdAt": 1778858831.62,
        "imageTagMutability": "MUTABLE",
        "imageScanningConfiguration": {
            "scanOnPush": false
        },
        "encryptionConfiguration": {
            "encryptionType": "AES256"
        }
    }
}

aws-client ~ ➜  ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

aws-client ~ ➜  showcreds
╒══════════════════════╤═════════════════════════════════════════════════════════════════════╕
│ Name                 │ Value                                                               │
╞══════════════════════╪═════════════════════════════════════════════════════════════════════╡
│ AWS Console URL      │ https://031744724431.signin.aws.amazon.com/console?region=us-east-1 │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS User Name        │ kk_labs_user_708440                                                 │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS Password         │ Iae@8WnAWzsd                                                        │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS Session End Time │ 2026-05-15T16:24:38Z                                                │
╘══════════════════════╧═════════════════════════════════════════════════════════════════════╛

aws-client ~ ➜  aws ecr get-login-password --region $AWS_REGION | \
docker login --username AWS --password-stdin \
${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

WARNING! Your credentials are stored unencrypted in '/root/.docker/config.json'.
Configure a credential helper to remove this warning. See
https://docs.docker.com/go/credential-store/

Login Succeeded

aws-client ~ ➜  cat /root/.docker/config.json
{
        "auths": {
                "031744724431.dkr.ecr.us-east-1.amazonaws.com": {
                        "auth": "QVdTOmV5SndZWGxzYjJGa0lqb2ljelJXT1VacE16ZEZNeXRVU1dWdVRYRmxabVZDYVRaaWIycFZTVTl2WW1RMVZuRlZRVU42YW1JMk9IRklUWHByWm1GMlpqZElZa1JsWm5SNmNrVXlabmwzTlhSWVdHdGlWR2hJU1V3M2MzUlJVbE5OWkdZMWRrZEZZbGsyYkVWUGJtSkVPR0ZsY2xSclVGbHNNVEp2Wm5aVUsySkZUVWhaZWtKS01uSk9hVVZLV1VSTWRVaG1PV2hWYWxaVFNtWmFhWFZJWmxKdFpIaEdjRVZVVWtGdlMzWkVRMU14TUM5bU1IWlJjMGR3TkNzelprNUxURFpTWlhkdWVrbGhhMVZvT0ZsNlIxbHlhamxpV2xGaU56RnVOM1JYVkhSU1ZUTllTbUZGY25kVGNXeHRkRUZoTWtKQ1MxWnhXamhGTm05YWJrSnZPRFF4TldSclNYWldSMmhGT0hGNVFWUnhaemhDVFZaeEwxQlRTVVptYUc4cmFsUm1VVVpYVnpSU1NtUjNUaTh6VUhGSVNtbDJhakprYkZKMmJHZ3dVbTl3Umt4RGRYWjNkVzlTYWk4M2RWZElkRGQ2VFZJM1ZWVnBhVEl6U3poMmJsaGtTMGxZVVdGMlpFVlBOM0ptVmpCc015OUlZVXh1YVZoalZUaDJWMVpuWjJkNE1XcFROVk5RWW1OdFF6ZGtObXBMVjI4NE5XRkJlRmxWV2tNd04xbEVaVzVpYlVVNE5IRXJiVGRhVVVKVWNubEpRV3R1VkM5bldFVmlka1UxWkZsVVJISktVVWwxTXpack5GaEZlWHBHT1RWdWNXdFRjR2hRVWlzMlNXaFFUMWRqYUVwNmJ6TlNTWFJRYlVkc1VpOXFkSHBZTW14WGF6RmFORVZGVjBoaFNGaGlTVFI0WlhJdk4wcDJhVEpETkN0M1RWbGxRM2R3UkVsQ09Hc3ZPRTVXYkV0NFNGZDFSalpaVWtoSmFVRkpka1pIVjNKdmVUWm1WR2xNTm1Gak5GWlFORmhyTkdaSlZrdG5SMU4yUzJGQlFVMHphV1F5YVhWa1VpdDBNbTVPVXpkT1ltdDRNMVpYYVhZNFRFVktkbTFFT0RKWVRHbG9hblJ6Y0VVd01IazBWRGt4UTBZMVUyZFpjVFZSUXpsbU5VdEdablY1UjBocFdFeFdhbXhCWkdoUGRqSmtjVVF5TVNzdlNUVkNVMDFrYVM4clFWUjFhSGRETWtKcVNqRTBRVlJMUm5WeU9IZHZWV3B4UkdneFFsUlpaV0pDZFZvek5XaHhVQ3RPYldGVU5GQkdkR051WkZFeWRrVnNNbXN6ZGtneVNHWkdjVVZTT1ZRMWVEWTVaMDEzYmxSMVpVSjBlamRUU0RKTmNrZGxhR3hXU1RGVlduUjVSbXhNVG5SWVRGRjZjV1ZYTUU5UVdtMWphRU4zTjFsVVVXOUdPRzFSVG5Cc2NFWlZkVmc1ZFhZMVFuTmxia05aYldaUVlrdE9WMnRZYldGc2FIUnNORE5DUlRVdlVVRTFRVW92WjJoQk1XMXliMHM1UWtaNllrNU1ObmRoTldZeVFtSXhVMU5MWkUxTmNXdzFPRGhoYTJJeVdWaHFhVkU0TTBWck5rNHpiRTVXTm1KTk5GSk9jbU50Wm1ZMWFsaFFiMU5EZVdwcmJsbzBNbVl3U0hkVVZFdDJRbkJ6Y0dseGJWZG1NMlJPWm5jemRFTkZZVTlxZDNNNFdFMTZNbE5rWm5WdmVqUnJValUzU1hWRVFrWndZMjFqWmxnNWJ6VjBOMnBYTUZjM1dpdHlaeXR1YldKQ2IwWnpPVTFvVlRjNEx6ZERkM1JvZVRkYVQxWlNTeUlzSW1SaGRHRnJaWGtpT2lKQlVVVkNRVWhvZDIwd1dXRkpVMHBsVW5SS2JUVnVNVWMyZFhGbFpXdFlkVzlZV0ZCbE5WVkdZMlU1VW5FNEx6RTBkMEZCUVVnMGQyWkJXVXBMYjFwSmFIWmpUa0ZSWTBkdlJ6aDNZbEZKUWtGRVFtOUNaMnR4YUd0cFJ6bDNNRUpDZDBWM1NHZFpTbGxKV2tsQlYxVkVRa0ZGZFUxQ1JVVkVSa3g2WTBsVGJ6VjJVSFpPYnpjMEwyZEpRa1ZKUVRkWFZXVklSVE54UW5Wd1FsVnhLelZSYXpWSFJ6SmlTMFZ0ZHpGcVpFMTJNV1EyWlhSeGQxQkZRM3BXY25OUVRFZEVWemRSZDFsNmF5dHRlbFJvTW1GSk1FNTBiVzQwY0hOdFJqUkpOV2huUFNJc0luWmxjbk5wYjI0aU9pSXlJaXdpZEhsd1pTSTZJa1JCVkVGZlMwVlpJaXdpWlhod2FYSmhkR2x2YmlJNk1UYzNPRGt3TWpFeE1IMD0="
                }
        }
}
aws-client ~ ➜  cd /root/pyapp

aws-client ~/pyapp ➜  ls
app.py  Dockerfile  requirements.txt

aws-client ~/pyapp ➜  cat Dockerfile 
# Sample Dockerfile
FROM python:3.8-slim
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
CMD ["python", "app.py"]

aws-client ~/pyapp ➜  docker build -t ${REPO_NAME}:latest .
[+] Building 188.0s (9/9) FINISHED                                             docker:default
 => [internal] load build definition from Dockerfile                                     0.1s
 => => transferring dockerfile: 164B                                                     0.0s
 => [internal] load metadata for docker.io/library/python:3.8-slim                     122.2s
 => [internal] load .dockerignore                                                        0.1s
 => => transferring context: 2B                                                          0.0s
 => [internal] load build context                                                        0.1s
 => => transferring context: 259B                                                        0.0s
 => [1/4] FROM docker.io/library/python:3.8-slim@sha256:1d52838af602b4b5a831beb13a0e4d  61.8s
 => => resolve docker.io/library/python:3.8-slim@sha256:1d52838af602b4b5a831beb13a0e4d0  0.0s
 => => sha256:1d52838af602b4b5a831beb13a0e4d073280665ea7be7f69ce2382f 10.41kB / 10.41kB  0.0s
 => => sha256:314bc2fb0714b7807bf5699c98f0c73817e579799f2d91567ab7e9510 1.75kB / 1.75kB  0.0s
 => => sha256:b5f62925bd0f63f48cc8acd5e87d0c3a07e2f229cd2fb0a9586e68ed1 5.25kB / 5.25kB  0.0s
 => => sha256:302e3ee498053a7b5332ac79e8efebec16e900289fc1ecd1c754ce 29.13MB / 29.13MB  31.1s
 => => sha256:030d7bdc20a63e3d22192b292d006a69fa3333949f536d62865d1bd0 3.51MB / 3.51MB  30.7s
 => => sha256:a3f1dfe736c5f959143f23d75ab522a60be2da902efac236f4fb2a 14.53MB / 14.53MB  31.0s
 => => sha256:3971691a363796c39467aae4cdce6ef773273fe6bfc67154d01e1b589bef 248B / 248B  61.3s
 => => extracting sha256:302e3ee498053a7b5332ac79e8efebec16e900289fc1ecd1c754ce8fa047fc  1.3s
 => => extracting sha256:030d7bdc20a63e3d22192b292d006a69fa3333949f536d62865d1bd0506685  0.1s
 => => extracting sha256:a3f1dfe736c5f959143f23d75ab522a60be2da902efac236f4fb2a153cc14a  0.7s
 => => extracting sha256:3971691a363796c39467aae4cdce6ef773273fe6bfc67154d01e1b589befb9  0.0s
 => [2/4] COPY . /app                                                                    0.2s
 => [3/4] WORKDIR /app                                                                   0.1s
 => [4/4] RUN pip install -r requirements.txt                                            2.8s
 => exporting to image                                                                   0.3s 
 => => exporting layers                                                                  0.3s 
 => => writing image sha256:75bdc4680c1e6e05bfb622b08447716304b53ed80b4e34f9ea1e79a7b4b  0.0s 
 => => naming to docker.io/library/nautilus-ecr:latest                                   0.0s 
                                                                                              
aws-client ~/pyapp ➜  docker tag ${REPO_NAME}:latest \
${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:latest

aws-client ~/pyapp ➜  docker push \
${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}:latest
The push refers to repository [031744724431.dkr.ecr.us-east-1.amazonaws.com/nautilus-ecr]
f9120b9af790: Pushed 
5f70bf18a086: Pushed 
fb39b789ea7d: Pushed 
d2a2207b52a4: Pushed 
5d2d143f3d7f: Pushed 
c3772b569c3a: Pushed 
8d853c8add5d: Pushed 
latest: digest: sha256:b6aff50482f5c91c00bd242ad2d50f8d3d2667212c6945fe376f0f3f214b757c size: 1783

aws-client ~/pyapp ➜  aws ecr describe-images \
  --repository-name nautilus-ecr \
  --region us-east-1
{
    "imageDetails": [
        {
            "registryId": "031744724431",
            "repositoryName": "nautilus-ecr",
            "imageDigest": "sha256:b6aff50482f5c91c00bd242ad2d50f8d3d2667212c6945fe376f0f3f214b757c",
            "imageTags": [
                "latest"
            ],
            "imageSizeInBytes": 49724333,
            "imagePushedAt": 1778859183.778,
            "imageManifestMediaType": "application/vnd.docker.distribution.manifest.v2+json",
            "artifactMediaType": "application/vnd.docker.container.image.v1+json",
            "imageStatus": "ACTIVE"
        }
    ]
}

aws-client ~/pyapp ➜  

```
 
## Day 29: Establishing Secure Communication Between Public and Private VPCs via VPC Peering
```

aws-client ~ ➜  showcreds
╒══════════════════════╤═════════════════════════════════════════════════════════════════════╕
│ Name                 │ Value                                                               │
╞══════════════════════╪═════════════════════════════════════════════════════════════════════╡
│ AWS Console URL      │ https://705317504531.signin.aws.amazon.com/console?region=us-east-1 │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS User Name        │ kk_labs_user_658276                                                 │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS Password         │ wSW6B!^@zw5m                                                        │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS Session End Time │ 2026-05-15T20:13:15Z                                                │
╘══════════════════════╧═════════════════════════════════════════════════════════════════════╛

aws-client ~ ➜  DEFAULT_VPC_ID=$(aws ec2 describe-vpcs \
  --filters Name=isDefault,Values=true \
  --query 'Vpcs[0].VpcId' \
  --output text)

echo $DEFAULT_VPC_ID
vpc-0c006fe7577effb3d

aws-client ~ ➜  PRIVATE_VPC_ID=$(aws ec2 describe-vpcs \
  --filters Name=tag:Name,Values=datacenter-private-vpc \
  --query 'Vpcs[0].VpcId' \
  --output text)

echo $PRIVATE_VPC_ID
vpc-0191f13226372ad93

aws-client ~ ➜  DEFAULT_VPC_CIDR=$(aws ec2 describe-vpcs \
  --vpc-ids $DEFAULT_VPC_ID \
  --query 'Vpcs[0].CidrBlock' \
  --output text)

echo $DEFAULT_VPC_CIDR
172.31.0.0/16

aws-client ~ ➜  PEERING_ID=$(aws ec2 create-vpc-peering-connection \
  --vpc-id $DEFAULT_VPC_ID \
  --peer-vpc-id $PRIVATE_VPC_ID \
  --tag-specifications 'ResourceType=vpc-peering-connection,Tags=[{Key=Name,Value=datacenter-vpc-peering}]' \
  --query 'VpcPeeringConnection.VpcPeeringConnectionId' \
  --output text)

echo $PEERING_ID
pcx-0a6d83728fd408b30

aws-client ~ ➜  PRIVATE_RT=$(aws ec2 describe-route-tables \
  --filters Name=vpc-id,Values=$PRIVATE_VPC_ID \
  --query 'RouteTables[0].RouteTableId' \
  --output text)

echo $PRIVATE_RT
rtb-01ace815bd1125c87

aws-client ~ ➜  aws ec2 create-route \
  --route-table-id $PRIVATE_RT \
  --destination-cidr-block $DEFAULT_VPC_CIDR \
  --vpc-peering-connection-id $PEERING_ID
{
    "Return": true
}

aws-client ~ ➜  DEFAULT_RT=$(aws ec2 describe-route-tables \
  --filters Name=vpc-id,Values=$DEFAULT_VPC_ID \
  --query 'RouteTables[0].RouteTableId' \
  --output text)

echo $DEFAULT_RT
rtb-0619b0a5c72cfd19f

aws-client ~ ➜  aws ec2 create-route \
  --route-table-id $DEFAULT_RT \
  --destination-cidr-block 10.1.0.0/16 \
  --vpc-peering-connection-id $PEERING_ID
{
    "Return": true
}

aws-client ~ ➜  PRIVATE_SG=$(aws ec2 describe-instances \
  --filters Name=tag:Name,Values=datacenter-private-ec2 \
  --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' \
  --output text)

echo $PRIVATE_SG
sg-0c3403adc3f122937

aws-client ~ ➜  aws ec2 authorize-security-group-ingress \
  --group-id $PRIVATE_SG \
  --protocol icmp \
  --port -1 \
  --cidr $DEFAULT_VPC_CIDR
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-0fafddcb599a3c42b",
            "GroupId": "sg-0c3403adc3f122937",
            "GroupOwnerId": "705317504531",
            "IsEgress": false,
            "IpProtocol": "icmp",
            "FromPort": -1,
            "ToPort": -1,
            "CidrIpv4": "172.31.0.0/16",
            "SecurityGroupRuleArn": "arn:aws:ec2:us-east-1:705317504531:security-group-rule/sgr-0fafddcb599a3c42b"
        }
    ]
}

aws-client ~ ➜  PUBLIC_IP=$(aws ec2 describe-instances \
  --filters Name=tag:Name,Values=datacenter-public-ec2 \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo $PUBLIC_IP
18.232.129.183

aws-client ~ ➜  ssh-copy-id -i /root/.ssh/id_rsa.pub ec2-user@$PUBLIC_IP
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"

^C

aws-client ~ ✖ ssh-copy-id -i /root/.ssh/id_rsa.pub ec2-user@$PUBLIC_IP
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
^C

aws-client ~ ✖ ssh-copy-id 
Usage: /usr/bin/ssh-copy-id [-h|-?|-f|-n] [-i [identity_file]] [-p port] [-F alternative ssh_config file] [[-o <ssh -o options>] ...] [user@]hostname
        -f: force mode -- copy keys without trying to check if they are already installed
        -n: dry run    -- no keys are actually copied
        -h|-?: print this help

aws-client ~ ✖ ssh-copy-id -i /root/.ssh/id_rsa.pub ec2-user@$PUBLIC_IP
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/root/.ssh/id_rsa.pub"
^C

aws-client ~ ✖ cat /root/.ssh/id_rsa.pub | ssh ec2-user@$PUBLIC_IP \
'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'
^C

aws-client ~ ✖ ssh ec2-user@$PUBLIC_IP
^C

aws-client ~ ✖ cat /root/.ssh/id_rsa.pub | ssh ec2-user@$PUBLIC_IP \
'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'
^C

aws-client ~ ✖ cat /root/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMCdNVItUzgUf5iIXjs35kh1o4n7Qk8zyVc+CYB+qwkOGuGTndFn6MnuNp+0NXt1BK6RWEazmwoOv+MTyQjVwcT2LME71yVrkDLORpl7RqcG+BlUgU4U4nZSEgSNHzbHQTuKKmWFdioJPMt4hefNpXHK2FA79/DDOMu/SWm9LB+TESq6mu5Kf9FqfEu0D+e3KPi6CN2VltIC5EE05ygHDnmVcMUogFA1Mi825uyepiiWco6agcb7ETQbdf/+nc/Q/2dH4yBYf0VQG9r5kYIexT6Ou6QdEE/qMLcpHL9r/TA07dpjab9PPJxrMaVA2jiNhOwvoaNquReH2TpUNJN8cf root@aws-client

aws-client ~ ➜  PUBLIC_SG=$(aws ec2 describe-instances \
  --filters Name=tag:Name,Values=datacenter-public-ec2 \
  --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' \
  --output text)

echo $PUBLIC_SG
sg-08826735f7fb70623

aws-client ~ ➜  aws ec2 authorize-security-group-ingress \
  --group-id $PUBLIC_SG \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-017c751c7d5e43b8c",
            "GroupId": "sg-08826735f7fb70623",
            "GroupOwnerId": "705317504531",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 22,
            "ToPort": 22,
            "CidrIpv4": "0.0.0.0/0",
            "SecurityGroupRuleArn": "arn:aws:ec2:us-east-1:705317504531:security-group-rule/sgr-017c751c7d5e43b8c"
        }
    ]
}

aws-client ~ ➜  aws ec2 describe-instances \
  --filters Name=tag:Name,Values=datacenter-public-ec2 \
  --query 'Reservations[0].Instances[0].[PublicIpAddress,State.Name]' \
  --output table
--------------------
| DescribeInstances|
+------------------+
|  18.232.129.183  |
|  running         |
+------------------+

aws-client ~ ➜  ssh -o StrictHostKeyChecking=no ec2-user@$PUBLIC_IP
Warning: Permanently added '18.232.129.183' (ECDSA) to the list of known hosts.
ec2-user@18.232.129.183: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).

aws-client ~ ✖ cat /root/.ssh/id_rsa.pub | ssh ec2-user@$PUBLIC_IP \
'mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'
ec2-user@18.232.129.183: Permission denied (publickey,gssapi-keyex,gssapi-with-mic).

aws-client ~ ✖ aws ec2 describe-instances \
  --filters Name=tag:Name,Values=datacenter-public-ec2 \
  --query 'Reservations[0].Instances[0].KeyName' \
  --output text
None

aws-client ~ ➜  aws ssm describe-instance-information \
  --query 'InstanceInformationList[*].[InstanceId,PingStatus]' \
  --output table

aws-client ~ ➜  PUBLIC_INSTANCE_ID=$(aws ec2 describe-instances \
  --filters Name=tag:Name,Values=datacenter-public-ec2 \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text)

AZ=$(aws ec2 describe-instances \
  --instance-ids $PUBLIC_INSTANCE_ID \
  --query 'Reservations[0].Instances[0].Placement.AvailabilityZone' \
  --output text)

echo $PUBLIC_INSTANCE_ID
echo $AZ
i-061fee98c807b84cc
us-east-1b

aws-client ~ ➜  aws ec2-instance-connect send-ssh-public-key \
  --instance-id $PUBLIC_INSTANCE_ID \
  --availability-zone $AZ \
  --instance-os-user ec2-user \
  --ssh-public-key file:///root/.ssh/id_rsa.pub
{
    "RequestId": "c2a8c6c1-3eb6-463d-915e-c7bc69266bb7",
    "Success": true
}

aws-client ~ ➜  ssh ec2-user@$PUBLIC_IP

A newer release of "Amazon Linux" is available.
  Version 2023.10.20260105:
  Version 2023.10.20260120:
  Version 2023.10.20260202:
  Version 2023.10.20260216:
  Version 2023.10.20260302:
  Version 2023.10.20260325:
  Version 2023.10.20260330:
  Version 2023.11.20260406:
  Version 2023.11.20260413:
  Version 2023.11.20260427:
  Version 2023.11.20260505:
  Version 2023.11.20260509:
  Version 2023.11.20260511:
  Version 2023.11.20260514:
  Version 2023.5.20241001:
  Version 2023.6.20241010:
  Version 2023.6.20241028:
  Version 2023.6.20241031:
  Version 2023.6.20241111:
  Version 2023.6.20241121:
  Version 2023.6.20241212:
  Version 2023.6.20250107:
  Version 2023.6.20250115:
  Version 2023.6.20250123:
  Version 2023.6.20250128:
  Version 2023.6.20250203:
  Version 2023.6.20250211:
  Version 2023.6.20250218:
  Version 2023.6.20250303:
  Version 2023.6.20250317:
  Version 2023.7.20250331:
  Version 2023.7.20250414:
  Version 2023.7.20250428:
  Version 2023.7.20250512:
  Version 2023.7.20250527:
  Version 2023.7.20250609:
  Version 2023.7.20250623:
  Version 2023.8.20250707:
  Version 2023.8.20250715:
  Version 2023.8.20250721:
  Version 2023.8.20250808:
  Version 2023.8.20250818:
  Version 2023.8.20250908:
  Version 2023.8.20250915:
  Version 2023.9.20250929:
  Version 2023.9.20251014:
  Version 2023.9.20251020:
  Version 2023.9.20251027:
  Version 2023.9.20251105:
  Version 2023.9.20251110:
  Version 2023.9.20251117:
  Version 2023.9.20251208:
Run "/usr/bin/dnf check-release-update" for full release and version update info
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
[ec2-user@ip-172-31-41-127 ~]$ exit
logout
Connection to 18.232.129.183 closed.

 

aws-client ~ ✖ aws ec2-instance-connect send-ssh-public-key   --instance-id $PUBLIC_INSTANCE_ID   --availability-zone $AZ   --instance-os-user ec2-user   --ssh-public-key file:///root/.ssh/id_rsa.pub
{
    "RequestId": "9e9a4e73-8c51-41f4-83f5-c4978a019248",
    "Success": true
}

aws-client ~ ➜  ssh ec2-user@$PUBLIC_IP

A newer release of "Amazon Linux" is available.
  Version 2023.10.20260105:
  Version 2023.10.20260120:
  Version 2023.10.20260202:
  Version 2023.10.20260216:
  Version 2023.10.20260302:
  ...
  ..

  Version 2023.9.20251117:
  Version 2023.9.20251208:
Run "/usr/bin/dnf check-release-update" for full release and version update info
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
Last login: Fri May 15 19:27:44 2026 from 65.108.255.62
 
          
[ec2-user@ip-172-31-41-127 ~]$ mkdir -p ~/.ssh
[ec2-user@ip-172-31-41-127 ~]$ chmod 700 ~/.ssh
[ec2-user@ip-172-31-41-127 ~]$ cat >> ~/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMCdNVItUzgUf5iIXjs35kh1o4n7Qk8zyVc+CYB+qwkOGuGTndFn6MnuNp+0NXt1BK6RWEazmwoOv+MTyQjVwcT2LME71yVrkDLORpl7RqcG+BlUgU4U4nZSEgSNHzbHQTuKKmWFdioJPMt4hefNpXHK2FA79/DDOMu/SWm9LB+TESq6mu5Kf9FqfEu0D+e3KPi6CN2VltIC5EE05ygHDnmVcMUogFA1Mi825uyepiiWco6agcb7ETQbdf/+nc/Q/2dH4yBYf0VQG9r5kYIexT6Ou6QdEE/qMLcpHL9r/TA07dpjab9PPJxrMaVA2jiNhOwvoaNquReH2TpUNJN8cf root@aws-client
[ec2-user@ip-172-31-41-127 ~]$ exit
logout
Connection to 18.232.129.183 closed.

 

 

aws-client ~ ✖ ssh ec2-user@$PUBLIC_IP

 

aws-client ~ ➜  PRIVATE_IP=$(aws ec2 describe-instances \
  --filters Name=tag:Name,Values=datacenter-private-ec2 \
  --query 'Reservations[0].Instances[0].PrivateIpAddress' \
  --output text)

echo $PRIVATE_IP
10.1.1.90

 

 

aws-client ~ ✖ ssh ec2-user@$PUBLIC_IP

A newer release of "Amazon Linux" is available.
  Version 2023.10.20260105:
  Version 2023.10.20260120:
  ...

Run "/usr/bin/dnf check-release-update" for full release and version update info
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
Last login: Fri May 15 19:33:35 2026 from 65.108.255.62
[ec2-user@ip-172-31-41-127 ~]$ ping 10.1.1.90
PING 10.1.1.90 (10.1.1.90) 56(84) bytes of data.
^C
--- 10.1.1.90 ping statistics ---
14 packets transmitted, 0 received, 100% packet loss, time 13513ms

[ec2-user@ip-172-31-41-127 ~]$ ping 10.1.1.90
PING 10.1.1.90 (10.1.1.90) 56(84) bytes of data.
^C
--- 10.1.1.90 ping statistics ---
5 packets transmitted, 0 received, 100% packet loss, time 4199ms

[ec2-user@ip-172-31-41-127 ~]$ exit
logout
Connection to 18.232.129.183 closed.

aws-client ~ ✖ aws ec2 describe-vpc-peering-connections \
  --query 'VpcPeeringConnections[*].[VpcPeeringConnectionId,Status.Code]' \
  --output table
-------------------------------------------------
|         DescribeVpcPeeringConnections         |
+------------------------+----------------------+
|  pcx-0a6d83728fd408b30 |  pending-acceptance  |
+------------------------+----------------------+

aws-client ~ ➜  aws ec2 accept-vpc-peering-connection \
  --vpc-peering-connection-id pcx-0a6d83728fd408b30
{
    "VpcPeeringConnection": {
        "AccepterVpcInfo": {
            "CidrBlock": "10.1.0.0/16",
            "CidrBlockSet": [
                {
                    "CidrBlock": "10.1.0.0/16"
                }
            ],
            "OwnerId": "705317504531",
            "PeeringOptions": {
                "AllowDnsResolutionFromRemoteVpc": false,
                "AllowEgressFromLocalClassicLinkToRemoteVpc": false,
                "AllowEgressFromLocalVpcToRemoteClassicLink": false
            },
            "VpcId": "vpc-0191f13226372ad93",
            "Region": "us-east-1"
        },
        "RequesterVpcInfo": {
            "CidrBlock": "172.31.0.0/16",
            "CidrBlockSet": [
                {
                    "CidrBlock": "172.31.0.0/16"
                }
            ],
            "OwnerId": "705317504531",
            "PeeringOptions": {
                "AllowDnsResolutionFromRemoteVpc": false,
                "AllowEgressFromLocalClassicLinkToRemoteVpc": false,
                "AllowEgressFromLocalVpcToRemoteClassicLink": false
            },
            "VpcId": "vpc-0c006fe7577effb3d",
            "Region": "us-east-1"
        },
        "Status": {
            "Code": "provisioning",
            "Message": "Provisioning"
        },
        "Tags": [],
        "VpcPeeringConnectionId": "pcx-0a6d83728fd408b30"
    }
}

aws-client ~ ➜  aws ec2 describe-vpc-peering-connections \
  --query 'VpcPeeringConnections[*].[VpcPeeringConnectionId,Status.Code]' \
  --output table
-------------------------------------
|   DescribeVpcPeeringConnections   |
+------------------------+----------+
|  pcx-0a6d83728fd408b30 |  active  |
+------------------------+----------+

aws-client ~ ➜  ssh ec2-user@$PUBLIC_IP

A newer release of "Amazon Linux" is available.
  Version 2023.10.20260105:
  Version 2023.10.20260120:
  
  Ve 
  Version 2023.9.20251208:
Run "/usr/bin/dnf check-release-update" for full release and version update info
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
Last login: Fri May 15 19:34:22 2026 from 65.108.255.62
[ec2-user@ip-172-31-41-127 ~]$ ping 10.1.1.90
PING 10.1.1.90 (10.1.1.90) 56(84) bytes of data.
64 bytes from 10.1.1.90: icmp_seq=1 ttl=127 time=1.88 ms
64 bytes from 10.1.1.90: icmp_seq=2 ttl=127 time=1.47 ms
64 bytes from 10.1.1.90: icmp_seq=3 ttl=127 time=1.40 ms
64 bytes from 10.1.1.90: icmp_seq=4 ttl=127 time=1.56 ms
64 bytes from 10.1.1.90: icmp_seq=5 ttl=127 time=1.37 ms
^C
--- 10.1.1.90 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4007ms
rtt min/avg/max/mdev = 1.370/1.532/1.877/0.183 ms
[ec2-user@ip-172-31-41-127 ~]$ 
```
 
## Day 30: Enable Internet Access for Private EC2 using NAT Instance
```

aws-client ~ ➜  # Variables
VPC_NAME="xfusion-priv-vpc"
PUB_SUBNET_NAME="xfusion-pub-subnet"
PRIV_SUBNET_NAME="xfusion-priv-subnet"
NAT_INSTANCE_NAME="xfusion-nat-instance"
SG_NAME="xfusion-nat-sg"
IGW_NAME="xfusion-igw"
PUB_RT_NAME="xfusion-pub-rt"
REGION="us-east-1"

aws-client ~ ➜  VPC_ID=$(aws ec2 describe-vpcs \
  --region $REGION \
  --filters "Name=tag:Name,Values=$VPC_NAME" \
  --query "Vpcs[0].VpcId" \
  --output text)

echo $VPC_ID
vpc-0c2b3be92919f705c

aws-client ~ ➜  PUB_SUBNET_ID=$(aws ec2 create-subnet \
  --region $REGION \
  --vpc-id $VPC_ID \
  --cidr-block 10.0.2.0/24 \
  --availability-zone ${REGION}a \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$PUB_SUBNET_NAME}]" \
  --query "Subnet.SubnetId" \
  --output text)

echo $PUB_SUBNET_ID

An error occurred (InvalidSubnet.Range) when calling the CreateSubnet operation: The CIDR '10.0.2.0/24' is invalid.


aws-client ~ ➜  aws ec2 describe-subnets \
  --filters "Name=vpc-id,Values=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=xfusion-priv-vpc" --query "Vpcs[0].VpcId" --output text)" \
  --query "Subnets[*].[SubnetId,CidrBlock,Tags[?Key=='Name'].Value|[0]]" \
  --output table
--------------------------------------------------------------------
|                          DescribeSubnets                         |
+---------------------------+--------------+-----------------------+
|  subnet-0de1579b6bfbdf134 |  10.1.1.0/24 |  xfusion-priv-subnet  |
+---------------------------+--------------+-----------------------+

aws-client ~ ➜  PUB_SUBNET_ID=$(aws ec2 create-subnet \
  --vpc-id $VPC_ID \
  --cidr-block 10.1.2.0/24 \
  --availability-zone ${REGION}a \
  --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=xfusion-pub-subnet}]" \
  --query "Subnet.SubnetId" \
  --output text)

echo $PUB_SUBNET_ID
subnet-084ed4f7bac0bc55d

aws-client ~ ➜  aws ec2 modify-subnet-attribute \
  --subnet-id $PUB_SUBNET_ID \
  --map-public-ip-on-launch

aws-client ~ ➜  IGW_ID=$(aws ec2 create-internet-gateway \
  --region $REGION \
  --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=$IGW_NAME}]" \
  --query "InternetGateway.InternetGatewayId" \
  --output text)

echo $IGW_ID
igw-02c03ea625963fca5

aws-client ~ ➜  PUB_RT_ID=$(aws ec2 create-route-table \
  --region $REGION \
  --vpc-id $VPC_ID \
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=$PUB_RT_NAME}]" \
  --query "RouteTable.RouteTableId" \
  --output text)

echo $PUB_RT_ID
rtb-0e47afc96dd444030

aws-client ~ ➜  aws ec2 create-route \
  --region $REGION \
  --route-table-id $PUB_RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID

An error occurred (InvalidParameterValue) when calling the CreateRoute operation: route table rtb-0e47afc96dd444030 and network gateway igw-02c03ea625963fca5 belong to different networks

aws-client ~ ✖ aws ec2 describe-route-tables \
  --route-table-ids $PUB_RT_ID \
  --query "RouteTables[0].VpcId" \
  --output text
vpc-0c2b3be92919f705c

aws-client ~ ➜  aws ec2 describe-internet-gateways \
  --internet-gateway-ids $IGW_ID \
  --query "InternetGateways[0].Attachments[0].VpcId" \
  --output text
None

aws-client ~ ➜  aws ec2 attach-internet-gateway \
  --internet-gateway-id $IGW_ID \
  --vpc-id $VPC_ID

aws-client ~ ➜  aws ec2 describe-internet-gateways \
  --internet-gateway-ids $IGW_ID \
  --query "InternetGateways[0].Attachments"
[
    {
        "State": "available",
        "VpcId": "vpc-0c2b3be92919f705c"
    }
]

aws-client ~ ➜  aws ec2 create-route \
  --route-table-id $PUB_RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID
{
    "Return": true
}

aws-client ~ ➜  PUB_RT_ID=$(aws ec2 create-route-table \
  --region $REGION \
  --vpc-id $VPC_ID \
  --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=$PUB_RT_NAME}]" \
  --query "RouteTable.RouteTableId" \
  --output text)

echo $PUB_RT_ID
rtb-0b45cdaf4da9cab4d

aws-client ~ ➜  aws ec2 create-route \
  --region $REGION \
  --route-table-id $PUB_RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id $IGW_ID
{
    "Return": true
}

aws-client ~ ➜  aws ec2 associate-route-table \
  --region $REGION \
  --subnet-id $PUB_SUBNET_ID \
  --route-table-id $PUB_RT_ID
{
    "AssociationId": "rtbassoc-0dd321c063c002d68",
    "AssociationState": {
        "State": "associated"
    }
}

aws-client ~ ➜  SG_ID=$(aws ec2 create-security-group \
  --region $REGION \
  --group-name $SG_NAME \
  --description "NAT Instance SG" \
  --vpc-id $VPC_ID \
  --query "GroupId" \
  --output text)

echo $SG_ID
sg-073f2ddfd9e4efc42

aws-client ~ ➜  VPC_CIDR=$(aws ec2 describe-vpcs \
  --region $REGION \
  --vpc-ids $VPC_ID \
  --query "Vpcs[0].CidrBlock" \
  --output text)

echo $VPC_CIDR
10.1.0.0/16

aws-client ~ ➜  aws ec2 authorize-security-group-ingress \
  --region $REGION \
  --group-id $SG_ID \
  --protocol -1 \
  --cidr $VPC_CIDR
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-05268547ea0284651",
            "GroupId": "sg-073f2ddfd9e4efc42",
            "GroupOwnerId": "139373540961",
            "IsEgress": false,
            "IpProtocol": "-1",
            "FromPort": -1,
            "ToPort": -1,
            "CidrIpv4": "10.1.0.0/16",
            "SecurityGroupRuleArn": "arn:aws:ec2:us-east-1:139373540961:security-group-rule/sgr-05268547ea0284651"
        }
    ]
}

aws-client ~ ➜  MYIP=$(curl -s ifconfig.me)

aws ec2 authorize-security-group-ingress \
  --region $REGION \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr ${MYIP}/32
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-097e4dc33cb9dee53",
            "GroupId": "sg-073f2ddfd9e4efc42",
            "GroupOwnerId": "139373540961",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 22,
            "ToPort": 22,
            "CidrIpv4": "65.108.255.62/32",
            "SecurityGroupRuleArn": "arn:aws:ec2:us-east-1:139373540961:security-group-rule/sgr-097e4dc33cb9dee53"
        }
    ]
}

aws-client ~ ➜  AMI_ID=$(aws ssm get-parameters \
  --region $REGION \
  --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --query "Parameters[0].Value" \
  --output text)

echo $AMI_ID
ami-0236922087fa98b6e

aws-client ~ ➜  INSTANCE_ID=$(aws ec2 run-instances \
  --region $REGION \
  --image-id $AMI_ID \
  --instance-type t2.micro \
  --key-name your-keypair \
  --subnet-id $PUB_SUBNET_ID \
  --security-group-ids $SG_ID \
  --associate-public-ip-address \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$NAT_INSTANCE_NAME}]" \
  --query "Instances[0].InstanceId" \
  --output text)

echo $INSTANCE_ID

An error occurred (InvalidKeyPair.NotFound) when calling the RunInstances operation: The key pair 'your-keypair' does not exist


aws-client ~ ➜  aws ec2 describe-key-pairs \
  --query "KeyPairs[*].KeyName" \
  --output table

aws-client ~ ➜  aws ec2 create-key-pair \
  --key-name xfusion-nat-key \
  --query "KeyMaterial" \
  --output text > xfusion-nat-key.pem

aws-client ~ ➜  chmod 400 xfusion-nat-key.pem

aws-client ~ ➜  INSTANCE_ID=$(aws ec2 run-instances \
  --region $REGION \
  --image-id $AMI_ID \
  --instance-type t2.micro \
  --key-name xfusion-nat-key.pem \
  --subnet-id $PUB_SUBNET_ID \
  --security-group-ids $SG_ID \
  --associate-public-ip-address \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$NAT_INSTANCE_NAME}]" \
  --query "Instances[0].InstanceId" \
  --output text)

echo $INSTANCE_ID

An error occurred (InvalidKeyPair.NotFound) when calling the RunInstances operation: The key pair 'xfusion-nat-key.pem' does not exist


aws-client ~ ➜  INSTANCE_ID=$(aws ec2 run-instances \
  --region $REGION \
  --image-id $AMI_ID \
  --instance-type t2.micro \
  --key-name xfusion-nat-key \
  --subnet-id $PUB_SUBNET_ID \
  --security-group-ids $SG_ID \
  --associate-public-ip-address \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$NAT_INSTANCE_NAME}]" \
  --query "Instances[0].InstanceId" \
  --output text)

aws-client ~ ➜  echo $INSTANCE_ID=$
i-0fb122a9f29613ebc=$

aws-client ~ ➜  echo $INSTANCE_ID=
i-0fb122a9f29613ebc=

aws-client ~ ➜  echo $INSTANCE_ID
i-0fb122a9f29613ebc

aws-client ~ ➜  aws ec2 modify-instance-attribute \
  --region $REGION \
  --instance-id $INSTANCE_ID \
  --no-source-dest-check

aws-client ~ ➜  PUBLIC_IP=$(aws ec2 describe-instances \
  --region $REGION \
  --instance-ids $INSTANCE_ID \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo $PUBLIC_IP
44.192.112.42

aws-client ~ ➜  ssh -i xfusion-nat-key.pem ec2-user@$PUBLIC_IP
The authenticity of host '44.192.112.42 (44.192.112.42)' can't be established.
ECDSA key fingerprint is SHA256:xZHzOykXoUxAKv/xjljZDlKFmgkV+z1eUawvmgfOtJ0.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '44.192.112.42' (ECDSA) to the list of known hosts.
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
[ec2-user@ip-10-1-2-237 ~]$ exit
logout
Connection to 44.192.112.42 closed.

aws-client ~ ➜  ssh -i xfusion-nat-key.pem ec2-user@$PUBLIC_IP
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
Last login: Fri May 15 20:14:57 2026 from 65.108.255.62
[ec2-user@ip-10-1-2-237 ~]$ sudo dnf install iptables-services -y
Amazon Linux 2023 Kernel Li     [===                        ] ---  B/s |   0  B     --:-- ETA
Amazon Linux 2023 Kernel Livepatch repository                 179 kB/s |  38 kB     00:00    
Dependencies resolved.
==============================================================================================
 Package                     Arch        Version                       Repository        Size
==============================================================================================
Installing:
 iptables-services           noarch      1.8.8-3.amzn2023.0.2          amazonlinux       18 k
Installing dependencies:
 iptables-libs               x86_64      1.8.8-3.amzn2023.0.2          amazonlinux      401 k
 iptables-nft                x86_64      1.8.8-3.amzn2023.0.2          amazonlinux      183 k
 iptables-utils              x86_64      1.8.8-3.amzn2023.0.2          amazonlinux       43 k
 libnetfilter_conntrack      x86_64      1.0.8-2.amzn2023.0.2          amazonlinux       58 k
 libnfnetlink                x86_64      1.0.1-19.amzn2023.0.2         amazonlinux       30 k
 libnftnl                    x86_64      1.2.2-2.amzn2023.0.2          amazonlinux       84 k

Transaction Summary
==============================================================================================
Install  7 Packages

Total download size: 816 k
Installed size: 2.9 M
Downloading Packages:
(1/7): iptables-services-1.8.8-3.amzn2023.0.2.noarch.rpm      421 kB/s |  18 kB     00:00    
(2/7): iptables-nft-1.8.8-3.amzn2023.0.2.x86_64.rpm           3.5 MB/s | 183 kB     00:00    
(3/7): iptables-libs-1.8.8-3.amzn2023.0.2.x86_64.rpm          6.5 MB/s | 401 kB     00:00    
(4/7): iptables-utils-1.8.8-3.amzn2023.0.2.x86_64.rpm         1.4 MB/s |  43 kB     00:00    
(5/7): libnetfilter_conntrack-1.0.8-2.amzn2023.0.2.x86_64.rpm 2.1 MB/s |  58 kB     00:00    
(6/7): libnfnetlink-1.0.1-19.amzn2023.0.2.x86_64.rpm          1.0 MB/s |  30 kB     00:00    
(7/7): libnftnl-1.2.2-2.amzn2023.0.2.x86_64.rpm               2.3 MB/s |  84 kB     00:00    
----------------------------------------------------------------------------------------------
Total                                                         4.5 MB/s | 816 kB     00:00     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                      1/1 
  Installing       : libnfnetlink-1.0.1-19.amzn2023.0.2.x86_64                            1/7 
  Installing       : libnetfilter_conntrack-1.0.8-2.amzn2023.0.2.x86_64                   2/7 
  Installing       : iptables-libs-1.8.8-3.amzn2023.0.2.x86_64                            3/7 
  Installing       : libnftnl-1.2.2-2.amzn2023.0.2.x86_64                                 4/7 
  Installing       : iptables-nft-1.8.8-3.amzn2023.0.2.x86_64                             5/7 
  Running scriptlet: iptables-nft-1.8.8-3.amzn2023.0.2.x86_64                             5/7 
  Installing       : iptables-utils-1.8.8-3.amzn2023.0.2.x86_64                           6/7 
  Installing       : iptables-services-1.8.8-3.amzn2023.0.2.noarch                        7/7 
  Running scriptlet: iptables-services-1.8.8-3.amzn2023.0.2.noarch                        7/7 
  Verifying        : iptables-libs-1.8.8-3.amzn2023.0.2.x86_64                            1/7 
  Verifying        : iptables-nft-1.8.8-3.amzn2023.0.2.x86_64                             2/7 
  Verifying        : iptables-services-1.8.8-3.amzn2023.0.2.noarch                        3/7 
  Verifying        : iptables-utils-1.8.8-3.amzn2023.0.2.x86_64                           4/7 
  Verifying        : libnetfilter_conntrack-1.0.8-2.amzn2023.0.2.x86_64                   5/7 
  Verifying        : libnfnetlink-1.0.1-19.amzn2023.0.2.x86_64                            6/7 
  Verifying        : libnftnl-1.2.2-2.amzn2023.0.2.x86_64                                 7/7 

Installed:
  iptables-libs-1.8.8-3.amzn2023.0.2.x86_64                                                   
  iptables-nft-1.8.8-3.amzn2023.0.2.x86_64                                                    
  iptables-services-1.8.8-3.amzn2023.0.2.noarch                                               
  iptables-utils-1.8.8-3.amzn2023.0.2.x86_64                                                  
  libnetfilter_conntrack-1.0.8-2.amzn2023.0.2.x86_64                                          
  libnfnetlink-1.0.1-19.amzn2023.0.2.x86_64                                                   
  libnftnl-1.2.2-2.amzn2023.0.2.x86_64                                                        

Complete!
[ec2-user@ip-10-1-2-237 ~]$ sudo sh -c 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf'
[ec2-user@ip-10-1-2-237 ~]$ sudo sysctl -p
net.ipv4.ip_forward = 1
[ec2-user@ip-10-1-2-237 ~]$ sudo iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
[ec2-user@ip-10-1-2-237 ~]$ sudo service iptables save
iptables: Saving firewall rules to /etc/sysconfig/iptables: [  OK  ]
[ec2-user@ip-10-1-2-237 ~]$ sudo systemctl enable iptables
Created symlink /etc/systemd/system/multi-user.target.wants/iptables.service → /usr/lib/systemd/system/iptables.service.
[ec2-user@ip-10-1-2-237 ~]$ sudo systemctl start iptables
[ec2-user@ip-10-1-2-237 ~]$ exit
logout
Connection to 44.192.112.42 closed.

aws-client ~ ➜  PRIV_SUBNET_ID=$(aws ec2 describe-subnets \
  --region $REGION \
  --filters "Name=tag:Name,Values=$PRIV_SUBNET_NAME" \
  --query "Subnets[0].SubnetId" \
  --output text)

echo $PRIV_SUBNET_ID
subnet-0de1579b6bfbdf134

aws-client ~ ➜  PRIV_RT_ID=$(aws ec2 describe-route-tables \
  --region $REGION \
  --filters "Name=association.subnet-id,Values=$PRIV_SUBNET_ID" \
  --query "RouteTables[0].RouteTableId" \
  --output text)

echo $PRIV_RT_ID
rtb-0d18a6608aca5cb8e

aws-client ~ ➜  aws ec2 create-route \
  --region $REGION \
  --route-table-id $PRIV_RT_ID \
  --destination-cidr-block 0.0.0.0/0 \
  --instance-id $INSTANCE_ID
{
    "Return": true
}

aws-client ~ ➜  aws s3 ls s3://xfusion-nat-12217/

aws-client ~ ➜  aws s3 ls s3://xfusion-nat-12217/

aws-client ~ ➜  aws s3 ls s3://xfusion-nat-12217/

aws-client ~ ➜  aws s3 ls s3://xfusion-nat-12217/

aws-client ~ ➜  aws s3 ls s3://xfusion-nat-12217/

aws-client ~ ➜  aws s3 ls s3://xfusion-nat-12217/

aws-client ~ ➜  aws ec2 describe-route-tables \
  --filters "Name=association.subnet-id,Values=$PRIV_SUBNET_ID" \
  --query "RouteTables[0].Routes"
[
    {
        "DestinationCidrBlock": "10.1.0.0/16",
        "GatewayId": "local",
        "Origin": "CreateRouteTable",
        "State": "active"
    },
    {
        "DestinationCidrBlock": "0.0.0.0/0",
        "InstanceId": "i-0fb122a9f29613ebc",
        "InstanceOwnerId": "139373540961",
        "NetworkInterfaceId": "eni-0a56614225a5996dd",
        "Origin": "CreateRoute",
        "State": "active"
    }
]

aws-client ~ ➜  aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query "Reservations[0].Instances[0].SourceDestCheck"
false

aws-client ~ ➜  aws ec2 describe-security-groups --group-ids $SG_ID
{
    "SecurityGroups": [
        {
            "GroupId": "sg-073f2ddfd9e4efc42",
            "IpPermissionsEgress": [
                {
                    "IpProtocol": "-1",
                    "UserIdGroupPairs": [],
                    "IpRanges": [
                        {
                            "CidrIp": "0.0.0.0/0"
                        }
                    ],
                    "Ipv6Ranges": [],
                    "PrefixListIds": []
                }
            ],
            "VpcId": "vpc-0c2b3be92919f705c",
            "SecurityGroupArn": "arn:aws:ec2:us-east-1:139373540961:security-group/sg-073f2ddfd9e4efc42",
            "OwnerId": "139373540961",
            "GroupName": "xfusion-nat-sg",
            "Description": "NAT Instance SG",
            "IpPermissions": [
                {
                    "IpProtocol": "-1",
                    "UserIdGroupPairs": [],
                    "IpRanges": [
                        {
                            "CidrIp": "10.1.0.0/16"
                        }
                    ],
                    "Ipv6Ranges": [],
                    "PrefixListIds": []
                },
                {
                    "IpProtocol": "tcp",
                    "FromPort": 22,
                    "ToPort": 22,
                    "UserIdGroupPairs": [],
                    "IpRanges": [
                        {
                            "CidrIp": "65.108.255.62/32"
                        }
                    ],
                    "Ipv6Ranges": [],
                    "PrefixListIds": []
                }
            ]
        }
    ]
}

aws-client ~ ➜  aws s3 ls s3://xfusion-nat-12217/

aws-client ~ ➜  ssh -i xfusion-nat-key.pem ec2-user@$PUBLIC_IP
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
Last login: Fri May 15 20:15:24 2026 from 65.108.255.62
[ec2-user@ip-10-1-2-237 ~]$ sysctl net.ipv4.ip_forward
net.ipv4.ip_forward = 1
[ec2-user@ip-10-1-2-237 ~]$ ip route | grep default
default via 10.1.2.1 dev enX0 proto dhcp src 10.1.2.237 metric 512 
[ec2-user@ip-10-1-2-237 ~]$ sudo iptables -t nat -L -n -v
Chain PREROUTING (policy ACCEPT 99 packets, 6068 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain INPUT (policy ACCEPT 1 packets, 60 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 65 packets, 4652 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain POSTROUTING (policy ACCEPT 163 packets, 10660 bytes)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 MASQUERADE  all  --  *      ens5    0.0.0.0/0            0.0.0.0/0           
[ec2-user@ip-10-1-2-237 ~]$ ip route
default via 10.1.2.1 dev enX0 proto dhcp src 10.1.2.237 metric 512 
10.1.0.2 via 10.1.2.1 dev enX0 proto dhcp src 10.1.2.237 metric 512 
10.1.2.0/24 dev enX0 proto kernel scope link src 10.1.2.237 metric 512 
10.1.2.1 dev enX0 proto dhcp scope link src 10.1.2.237 metric 512 
[ec2-user@ip-10-1-2-237 ~]$ exit
logout
Connection to 44.192.112.42 closed.

aws-client ~ ➜  aws ec2 describe-route-tables \
  --route-table-ids $PUB_RT_ID \
  --query "RouteTables[0].Routes"
[
    {
        "DestinationCidrBlock": "10.1.0.0/16",
        "GatewayId": "local",
        "Origin": "CreateRouteTable",
        "State": "active"
    },
    {
        "DestinationCidrBlock": "0.0.0.0/0",
        "GatewayId": "igw-02c03ea625963fca5",
        "Origin": "CreateRoute",
        "State": "active"
    }
]

aws-client ~ ➜  aws ec2 describe-route-tables \
  --filters "Name=association.subnet-id,Values=$PRIV_SUBNET_ID" \
  --query "RouteTables[0].Routes"
[
    {
        "DestinationCidrBlock": "10.1.0.0/16",
        "GatewayId": "local",
        "Origin": "CreateRouteTable",
        "State": "active"
    },
    {
        "DestinationCidrBlock": "0.0.0.0/0",
        "InstanceId": "i-0fb122a9f29613ebc",
        "InstanceOwnerId": "139373540961",
        "NetworkInterfaceId": "eni-0a56614225a5996dd",
        "Origin": "CreateRoute",
        "State": "active"
    }
]

aws-client ~ ➜  ssh -i xfusion-nat-key.pem ec2-user@$PUBLIC_IP
   ,     #_
   ~\_  ####_        Amazon Linux 2023
  ~~  \_#####\
  ~~     \###|
  ~~       \#/ ___   https://aws.amazon.com/linux/amazon-linux-2023
   ~~       V~' '->
    ~~~         /
      ~~._.   _/
         _/ _/
       _/m/'
Last login: Fri May 15 20:22:17 2026 from 65.108.255.62
[ec2-user@ip-10-1-2-237 ~]$ ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enX0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc fq_codel state UP group default qlen 1000
    link/ether 02:64:66:1c:6a:ff brd ff:ff:ff:ff:ff:ff
    altname eni-0a56614225a5996dd
    altname device-number-0.0
    inet 10.1.2.237/24 metric 512 brd 10.1.2.255 scope global dynamic enX0
       valid_lft 2848sec preferred_lft 2848sec
    inet6 fe80::64:66ff:fe1c:6aff/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
[ec2-user@ip-10-1-2-237 ~]$ sudo iptables -t nat -L -n -v
Chain PREROUTING (policy ACCEPT 175 packets, 10644 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain INPUT (policy ACCEPT 2 packets, 120 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 104 packets, 7424 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain POSTROUTING (policy ACCEPT 277 packets, 17948 bytes)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 MASQUERADE  all  --  *      ens5    0.0.0.0/0            0.0.0.0/0           
[ec2-user@ip-10-1-2-237 ~]$ sudo iptables -t nat -D POSTROUTING -o ens5 -j MASQUERADE
[ec2-user@ip-10-1-2-237 ~]$ sudo iptables -t nat -A POSTROUTING -o enX0 -j MASQUERADE
[ec2-user@ip-10-1-2-237 ~]$ sudo sysctl -w net.ipv4.ip_forward=1
net.ipv4.ip_forward = 1
[ec2-user@ip-10-1-2-237 ~]$ echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
net.ipv4.ip_forward=1
[ec2-user@ip-10-1-2-237 ~]$ sudo service iptables save
iptables: Saving firewall rules to /etc/sysconfig/iptables: [  OK  ]
[ec2-user@ip-10-1-2-237 ~]$ sudo iptables -t nat -L -n -v
Chain PREROUTING (policy ACCEPT 207 packets, 12564 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain INPUT (policy ACCEPT 2 packets, 120 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain OUTPUT (policy ACCEPT 123 packets, 8772 bytes)
 pkts bytes target     prot opt in     out     source               destination         

Chain POSTROUTING (policy ACCEPT 326 packets, 21064 bytes)
 pkts bytes target     prot opt in     out     source               destination         
    2   152 MASQUERADE  all  --  *      enX0    0.0.0.0/0            0.0.0.0/0           
[ec2-user@ip-10-1-2-237 ~]$ exit
logout
Connection to 44.192.112.42 closed.

aws-client ~ ➜  aws s3 ls s3://xfusion-nat-12217/
2026-05-15 20:29:08         18 xfusion-test.txt

aws-client ~ ➜  

```



## Lessons Learned : NAT Instance Setup for Private EC2 Internet Access 

## Objective

Enable internet access for the private EC2 instance `xfusion-priv-ec2` located in the private subnet `xfusion-priv-subnet` by using a **NAT Instance** instead of a NAT Gateway.

The private EC2 instance already had a cron job configured to upload a file named:

```markdown
xfusion-test.txt
```

to the S3 bucket:

```markdown
xfusion-nat-12217
```

Successful upload would confirm outbound internet connectivity.

---

## Existing Infrastructure

Already available in AWS:

| Component | Name |
| --- | --- |
| VPC | `xfusion-priv-vpc` |
| Private Subnet | `xfusion-priv-subnet` |
| Private EC2 | `xfusion-priv-ec2` |

Existing private subnet CIDR:

```markdown
10.1.1.0/24
```

---

## Architecture Overview

## Before NAT Configuration

```markdown
Private EC2
   ↓
Private Subnet
   ↓
NO Internet Access
```

Private subnet instances cannot directly access the internet because:

- they do not have public IPs
- they are isolated from the Internet Gateway

---

## After NAT Configuration

```markdown
Private EC2
   ↓
Private Route Table
   ↓
NAT Instance (Public Subnet)
   ↓
Internet Gateway
   ↓
Internet / S3
```

The NAT instance acts as an intermediary that forwards outbound traffic from private instances.

---

## Why NAT Instance Was Used

Instead of a managed NAT Gateway, a NAT Instance was used because:

- NAT Gateway is more expensive
- NAT Instance is cheaper for labs/testing
- Full control over routing and iptables

Tradeoffs:

- manual configuration required
- lower scalability
- single point of failure unless highly available

---

## Step-by-Step Implementation

---

## 1\. Created Public Subnet

A new public subnet was created inside the same VPC.

Subnet:

```markdown
xfusion-pub-subnet
```

CIDR:

```markdown
10.1.2.0/24
```

Why:

- public subnet is required for internet-facing resources
- NAT instance must live in a public subnet

---

## 2\. Created and Attached Internet Gateway

An Internet Gateway (IGW) was created and attached to the VPC.

Purpose:

- allows traffic between VPC and internet

Without IGW:

- no internet connectivity is possible

---

## 3\. Created Public Route Table

Public route table contained:

| Destination | Target |
| --- | --- |
| `10.1.0.0/16` | local |
| `0.0.0.0/0` | IGW |

Purpose:

- sends all internet-bound traffic to Internet Gateway

This route table was associated with:

```markdown
xfusion-pub-subnet
```

---

## 4\. Created NAT Instance

EC2 instance launched:

```markdown
xfusion-nat-instance
```

Using:

- Amazon Linux 2023 AMI

Placed in:

```markdown
xfusion-pub-subnet
```

Assigned:

- public IP address

Purpose:

- perform Network Address Translation (NAT)
- allow private subnet instances to access internet

---

## 5\. Disabled Source/Destination Check

By default, EC2 instances only accept traffic destined for themselves.

NAT instances must forward traffic for other instances.

So this setting was disabled:

```markdown
Source/Destination Check = Disabled
```

Without this:

- packet forwarding fails

---

## 6\. Enabled IP Forwarding

Linux kernel forwarding was enabled:

```markdown
sudo sysctl -w net.ipv4.ip_forward=1
```

Purpose:

- allows Linux to route packets between interfaces

Without this:

- instance behaves like a normal server, not a router

---

## 7\. Installed iptables

Amazon Linux 2023 does not include iptables by default.

Installed using:

```markdown
sudo dnf install iptables-services -y
```

Purpose:

- perform packet NAT translation

---

## 8\. Configured NAT (MASQUERADE)

iptables rule added:

```markdown
sudo iptables -t nat -A POSTROUTING -o enX0 -j MASQUERADE
```

Purpose:

- rewrite private source IPs into NAT instance public IP
- allows return traffic from internet

This is the core of NAT functionality.

---

## 9\. Updated Private Route Table

Private subnet route table was modified:

| Destination | Target |
| --- | --- |
| `0.0.0.0/0` | NAT Instance |

Purpose:

- all outbound internet traffic from private subnet goes to NAT instance

---

## Issue Encountered During Setup

## Problem

Initially, internet access still failed and S3 uploads did not work.

Observed issue:

```markdown
iptables MASQUERADE rule used interface ens5
```

But actual interface name was:

```markdown
enX0
```

Incorrect rule:

```markdown
sudo iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE
```

Result:

- NAT translation never occurred
- private EC2 traffic could not return from internet

---

## Resolution

Incorrect rule removed:

```markdown
sudo iptables -t nat -D POSTROUTING -o ens5 -j MASQUERADE
```

Correct rule added:

```markdown
sudo iptables -t nat -A POSTROUTING -o enX0 -j MASQUERADE
```

After correction:

- NAT translation worked
- private EC2 gained internet access
- S3 upload succeeded

---

## Verification

Verified successful upload:

```markdown
aws s3 ls s3://xfusion-nat-12217/
```

File observed:

```markdown
xfusion-test.txt
```

This confirmed:

- routing working
- NAT functioning
- internet access established
- S3 reachable from private subnet

---

## Final Working Traffic Flow

```markdown
xfusion-priv-ec2
        ↓
Private Route Table
        ↓
xfusion-nat-instance
        ↓
iptables MASQUERADE
        ↓
Internet Gateway
        ↓
Internet / Amazon S3
```

---

## Key Networking Concepts Learned

## Public Subnet

Subnet with route to Internet Gateway.

## Private Subnet

Subnet without direct internet route.

## Internet Gateway (IGW)

Enables internet connectivity for VPC.

## NAT Instance

Performs source NAT for private instances.

## Source NAT (SNAT)

Rewrites private source IP to public IP.

## IP Forwarding

Allows Linux to route packets.

## iptables MASQUERADE

Dynamically performs source NAT.

## Route Tables

Control packet forwarding inside VPC.

---

## Final Outcome

Successfully enabled internet access for:

```markdown
xfusion-priv-ec2
```

using:

```markdown
xfusion-nat-instance
```

and verified functionality through successful upload of:

```markdown
xfusion-test.txt
```

to:

```markdown
xfusion-nat-12217
```

## Day 31: Configuring a Private RDS Instance for Application Development
```

aws-client ~ ➜  showcreds
╒══════════════════════╤═════════════════════════════════════════════════════════════════════╕
│ Name                 │ Value                                                               │
╞══════════════════════╪═════════════════════════════════════════════════════════════════════╡
│ AWS Console URL      │ https://641147740220.signin.aws.amazon.com/console?region=us-east-1 │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS User Name        │ kk_labs_user_779386                                                 │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS Password         │ WftldS199kxr                                                        │
├──────────────────────┼─────────────────────────────────────────────────────────────────────┤
│ AWS Session End Time │ 2026-05-16T00:41:30Z                                                │
╘══════════════════════╧═════════════════════════════════════════════════════════════════════╛

 
 

aws-client ~ ✖ aws rds create-db-instance \
  --db-instance-identifier datacenter-rds \
  --db-instance-class db.t3.micro \
  --engine mysql \
  --engine-version 8.4 \
  --allocated-storage 20 \
  --max-allocated-storage 50 \
  --storage-type gp2 \
  --master-username admin \
  --master-user-password 'ChangeMe123!' \
  --no-publicly-accessible \
  --backup-retention-period 7 \
  --availability-zone us-east-1a
{
    "DBInstance": {
        "DBInstanceIdentifier": "datacenter-rds",
        "DBInstanceClass": "db.t3.micro",
        "Engine": "mysql",
        "DBInstanceStatus": "creating",
        "MasterUsername": "admin",
        "AllocatedStorage": 20,
        "PreferredBackupWindow": "04:01-04:31",
        "BackupRetentionPeriod": 7,
        "DBSecurityGroups": [],
        "VpcSecurityGroups": [
            {
                "VpcSecurityGroupId": "sg-042b383e3fe97ae5f",
                "Status": "active"
            }
        ],
        "DBParameterGroups": [
            {
                "DBParameterGroupName": "default.mysql8.4",
                "ParameterApplyStatus": "in-sync"
            }
        ],
        "AvailabilityZone": "us-east-1a",
        "DBSubnetGroup": {
            "DBSubnetGroupName": "default",
            "DBSubnetGroupDescription": "default",
            "VpcId": "vpc-0a2eb682e59606850",
            "SubnetGroupStatus": "Complete",
            "Subnets": [
                {
                    "SubnetIdentifier": "subnet-03b5f5b525c8109a4",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1d"
                    },
                    "SubnetOutpost": {},
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-0c9068986a8e617e0",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1b"
                    },
                    "SubnetOutpost": {},
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-0080bac0def5d1b8e",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1a"
                    },
                    "SubnetOutpost": {},
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-02e403bd820ca61e3",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1c"
                    },
                    "SubnetOutpost": {},
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-035e0beb92c2c0149",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1f"
                    },
                    "SubnetOutpost": {},
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-037607011ddabd764",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1e"
                    },
                    "SubnetOutpost": {},
                    "SubnetStatus": "Active"
                }
            ]
        },
        "PreferredMaintenanceWindow": "wed:08:33-wed:09:03",
        "UpgradeRolloutOrder": "second",
        "PendingModifiedValues": {
            "MasterUserPassword": "****"
        },
        "MultiAZ": false,
        "EngineVersion": "8.4.8",
        "AutoMinorVersionUpgrade": true,
        "ReadReplicaDBInstanceIdentifiers": [],
        "LicenseModel": "general-public-license",
        "StorageThroughput": 0,
        "OptionGroupMemberships": [
            {
                "OptionGroupName": "default:mysql-8-4",
                "Status": "in-sync"
            }
        ],
        "PubliclyAccessible": false,
        "StorageType": "gp2",
        "DbInstancePort": 0,
        "StorageEncrypted": false,
        "DbiResourceId": "db-Z6TISVXOVYBWMB7XTS2IZWCLCQ",
        "CACertificateIdentifier": "rds-ca-rsa2048-g1",
        "DomainMemberships": [],
        "CopyTagsToSnapshot": false,
        "MonitoringInterval": 0,
        "DBInstanceArn": "arn:aws:rds:us-east-1:641147740220:db:datacenter-rds",
        "IAMDatabaseAuthenticationEnabled": false,
        "DatabaseInsightsMode": "standard",
        "PerformanceInsightsEnabled": false,
        "DeletionProtection": false,
        "AssociatedRoles": [],
        "MaxAllocatedStorage": 50,
        "TagList": [],
        "CustomerOwnedIpEnabled": false,
        "NetworkType": "IPV4",
        "BackupTarget": "region",
        "CertificateDetails": {
            "CAIdentifier": "rds-ca-rsa2048-g1"
        },
        "DedicatedLogVolume": false,
        "EngineLifecycleSupport": "open-source-rds-extended-support"
    }
}

aws-client ~ ➜  aws rds describe-db-instances \
  --db-instance-identifier datacenter-rds \
  --query "DBInstances[0].DBInstanceStatus"
"creating"

aws-client ~ ➜  aws rds describe-db-instances   --db-instance-identifier datacenter-rds   --query "DBInstances[0].DBInstanceStatus"
"creating"

 

aws-client ~ ➜  aws rds describe-db-instances   --db-instance-identifier datacenter-rds   --query "DBInstances[0].DBInstanceStatus"
"available"

aws-client ~ ➜  
```
 
## Day 32: Snapshot and Restoration of an RDS Instance
```
aws-client ~ ➜  aws rds describe-db-instances \
  --db-instance-identifier nautilus-rds \
  --query "DBInstances[0].DBInstanceStatus"
"creating"

aws-client ~ ➜  aws rds describe-db-instances   --db-instance-identifier nautilus-rds   --query "DBInstances[0].DBInstanceStatus"
"creating"

aws-client ~ ➜  aws rds describe-db-instances   --db-instance-identifier nautilus-rds   --query "DBInstances[0].DBInstanceStatus"
"configuring-enhanced-monitoring"

aws-client ~ ➜  aws rds describe-db-instances   --db-instance-identifier nautilus-rds   --query "DBInstances[0].DBInstanceStatus"
"configuring-enhanced-monitoring"

aws-client ~ ➜  aws rds describe-db-instances   --db-instance-identifier nautilus-rds   --query "DBInstances[0].DBInstanceStatus"
"backing-up"

aws-client ~ ➜  aws rds describe-db-instances   --db-instance-identifier nautilus-rds   --query "DBInstances[0].DBInstanceStatus"
"available"

aws-client ~ ➜  aws rds create-db-snapshot \
  --db-instance-identifier nautilus-rds \
  --db-snapshot-identifier nautilus-snapshot
{
    "DBSnapshot": {
        "DBSnapshotIdentifier": "nautilus-snapshot",
        "DBInstanceIdentifier": "nautilus-rds",
        "Engine": "mysql",
        "AllocatedStorage": 5,
        "Status": "creating",
        "Port": 3306,
        "AvailabilityZone": "us-east-1c",
        "VpcId": "vpc-0bf7a3401e8740a31",
        "InstanceCreateTime": "2026-05-15T23:59:54.742Z",
        "MasterUsername": "nautilus_admin",
        "EngineVersion": "8.4.5",
        "LicenseModel": "general-public-license",
        "SnapshotType": "manual",
        "StorageThroughput": 0,
        "OptionGroupName": "default:mysql-8-4",
        "PercentProgress": 0,
        "StorageType": "gp2",
        "Encrypted": false,
        "BackupRetentionPeriod": 1,
        "PreferredBackupWindow": "08:28-08:58",
        "DBSnapshotArn": "arn:aws:rds:us-east-1:338912023448:snapshot:nautilus-snapshot",
        "IAMDatabaseAuthenticationEnabled": false,
        "ProcessorFeatures": [],
        "DbiResourceId": "db-UV4G25CVRKEMSMTU7IRXBMEP6I",
        "TagList": [],
        "SnapshotTarget": "region",
        "DedicatedLogVolume": false
    }
}

aws-client ~ ➜  aws rds describe-db-snapshots \
  --db-snapshot-identifier nautilus-snapshot \
  --query "DBSnapshots[0].Status"
"creating"

aws-client ~ ➜  aws rds describe-db-snapshots   --db-snapshot-identifier nautilus-snapshot   --query "DBSnapshots[0].Status"
"creating"

aws-client ~ ➜  aws rds describe-db-snapshots   --db-snapshot-identifier nautilus-snapshot   --query "DBSnapshots[0].Status"
"available"

aws-client ~ ➜  aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier nautilus-snapshot-restore \
  --db-snapshot-identifier nautilus-snapshot \
  --db-instance-class db.t3.micro
{
    "DBInstance": {
        "DBInstanceIdentifier": "nautilus-snapshot-restore",
        "DBInstanceClass": "db.t3.micro",
        "Engine": "mysql",
        "DBInstanceStatus": "creating",
        "MasterUsername": "nautilus_admin",
        "AllocatedStorage": 5,
        "PreferredBackupWindow": "08:28-08:58",
        "BackupRetentionPeriod": 1,
        "DBSecurityGroups": [],
        "VpcSecurityGroups": [
            {
                "VpcSecurityGroupId": "sg-02814c709e0cf76de",
                "Status": "active"
            }
        ],
        "DBParameterGroups": [
            {
                "DBParameterGroupName": "default.mysql8.4",
                "ParameterApplyStatus": "in-sync"
            }
        ],
        "DBSubnetGroup": {
            "DBSubnetGroupName": "default",
            "DBSubnetGroupDescription": "default",
            "VpcId": "vpc-0bf7a3401e8740a31",
            "SubnetGroupStatus": "Complete",
            "Subnets": [
                {
                    "SubnetIdentifier": "subnet-012e0fc5f12b7f116",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1c"
                    },
                    "SubnetOutpost": {},
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-0462b21c65b1d775e",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1a"
                    },
                    "SubnetOutpost": {},
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-0a5d3141083d295fd",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1e"
                    },
                    "SubnetOutpost": {},
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-0ab02205a026b2475",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1d"
                    },
                    "SubnetOutpost": {},
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-03cfc493fc0f50ec6",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1f"
                    },
                    "SubnetOutpost": {},
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-02860a1d588cb5d91",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1b"
                    },
                    "SubnetOutpost": {},
                    "SubnetStatus": "Active"
                }
            ]
        },
        "PreferredMaintenanceWindow": "sun:05:53-sun:06:23",
        "UpgradeRolloutOrder": "second",
        "PendingModifiedValues": {},
        "MultiAZ": false,
        "EngineVersion": "8.4.5",
        "AutoMinorVersionUpgrade": true,
        "ReadReplicaDBInstanceIdentifiers": [],
        "LicenseModel": "general-public-license",
        "StorageThroughput": 0,
        "OptionGroupMemberships": [
            {
                "OptionGroupName": "default:mysql-8-4",
                "Status": "pending-apply"
            }
        ],
        "PubliclyAccessible": true,
        "StorageType": "gp2",
        "DbInstancePort": 0,
        "StorageEncrypted": false,
        "DbiResourceId": "db-LKUBOV7X3C4GBCDUB6Z3ZP3TBM",
        "CACertificateIdentifier": "rds-ca-rsa2048-g1",
        "DomainMemberships": [],
        "CopyTagsToSnapshot": false,
        "MonitoringInterval": 0,
        "DBInstanceArn": "arn:aws:rds:us-east-1:338912023448:db:nautilus-snapshot-restore",
        "IAMDatabaseAuthenticationEnabled": false,
        "DatabaseInsightsMode": "standard",
        "PerformanceInsightsEnabled": false,
        "DeletionProtection": false,
        "AssociatedRoles": [],
        "TagList": [],
        "CustomerOwnedIpEnabled": false,
        "NetworkType": "IPV4",
        "BackupTarget": "region",
        "CertificateDetails": {
            "CAIdentifier": "rds-ca-rsa2048-g1"
        },
        "DedicatedLogVolume": false,
        "EngineLifecycleSupport": "open-source-rds-extended-support"
    }
}

aws-client ~ ➜  aws rds describe-db-instances \
  --db-instance-identifier nautilus-snapshot-restore \
  --query "DBInstances[0].DBInstanceStatus"
"creating"

aws-client ~ ➜  aws rds describe-db-instances   --db-instance-identifier nautilus-snapshot-restore   --query "DBInstances[0].DBInstanceStatus"
"configuring-enhanced-monitoring"

aws-client ~ ➜  aws rds describe-db-instances   --db-instance-identifier nautilus-snapshot-restore   --query "DBInstances[0].DBInstanceStatus"
"backing-up"

aws-client ~ ➜  aws rds describe-db-instances   --db-instance-identifier nautilus-snapshot-restore   --query "DBInstances[0].DBInstanceStatus"
"backing-up"

aws-client ~ ➜  aws rds describe-db-instances   --db-instance-identifier nautilus-snapshot-restore   --query "DBInstances[0].DBInstanceStatus"
"modifying"

aws-client ~ ➜  aws rds describe-db-instances   --db-instance-identifier nautilus-snapshot-restore   --query "DBInstances[0].DBInstanceStatus"
"available"

aws-client ~ ➜  

```
 
## Day 33: Create a Lambda Function

Create Lambda Function: Create a Lambda function named nautilus-lambda.

Runtime: Use the Runtime Python.

Deploy: The function should print the body Welcome to KKE AWS Labs!.

Status Code: Ensure the status code is 200.

IAM Role: Create and use the IAM role named lambda_execution_role.


```
aws-client ~ ➜  cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "lambda.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

aws-client ~ ➜  aws iam create-role \
  --role-name lambda_execution_role \
  --assume-role-policy-document file://trust-policy.json
{
    "Role": {
        "Path": "/",
        "RoleName": "lambda_execution_role",
        "RoleId": "AROA5GAZYJG6HRUI3RTKK",
        "Arn": "arn:aws:iam::906292119996:role/lambda_execution_role",
        "CreateDate": "2026-05-16T00:17:01Z",
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Service": "lambda.amazonaws.com"
                    },
                    "Action": "sts:AssumeRole"
                }
            ]
        }
    }
}

aws-client ~ ➜  aws iam attach-role-policy \
  --role-name lambda_execution_role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

aws-client ~ ➜  cat > lambda_function.py <<EOF
def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": "Welcome to KKE AWS Labs!"
    }
EOF

aws-client ~ ➜  zip function.zip lambda_function.py
  adding: lambda_function.py (deflated 14%)

aws-client ~ ➜  aws lambda create-function \
  --function-name nautilus-lambda \
  --runtime python3.12 \
  --role arn:aws:iam::<ACCOUNT_ID>:role/lambda_execution_role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip \
  --description "Nautilus Lambda Function"
bash: ACCOUNT_ID: No such file or directory

aws-client ~ ✖ aws lambda create-function \
  --function-name nautilus-lambda \
  --runtime python3.12 \
  --role arn:aws:iam::906292119996:role/lambda_execution_role \
  --handler lambda_function.lambda_handler \
  --zip-file fileb://function.zip \
  --description "Nautilus Lambda Function"
{
    "FunctionName": "nautilus-lambda",
    "FunctionArn": "arn:aws:lambda:us-east-1:906292119996:function:nautilus-lambda",
    "Runtime": "python3.12",
    "Role": "arn:aws:iam::906292119996:role/lambda_execution_role",
    "Handler": "lambda_function.lambda_handler",
    "CodeSize": 293,
    "Description": "Nautilus Lambda Function",
    "Timeout": 3,
    "MemorySize": 128,
    "LastModified": "2026-05-16T00:18:54.183+0000",
    "CodeSha256": "0TCn9ur3T1KmvoZ01JnpAxduqFvEmv0Hrlml8sfgRV0=",
    "Version": "$LATEST",
    "TracingConfig": {
        "Mode": "PassThrough"
    },
    "RevisionId": "683f593c-05ce-4b0d-b55d-052c7f3ef2ea",
    "State": "Pending",
    "StateReason": "The function is being created.",
    "StateReasonCode": "Creating",
    "PackageType": "Zip",
    "Architectures": [
        "x86_64"
    ],
    "EphemeralStorage": {
        "Size": 512
    },
    "SnapStart": {
        "ApplyOn": "None",
        "OptimizationStatus": "Off"
    },
    "RuntimeVersionConfig": {
        "RuntimeVersionArn": "arn:aws:lambda:us-east-1::runtime:e4ab553846c4e081013ff7d1d608a5358d5b956bb5b81c83c66d2a31da8f6244"
    },
    "LoggingConfig": {
        "LogFormat": "Text",
        "LogGroup": "/aws/lambda/nautilus-lambda"
    }
}

aws-client ~ ➜  aws lambda invoke \
  --function-name nautilus-lambda \
  response.json
{
    "StatusCode": 200,
    "ExecutedVersion": "$LATEST"
}

aws-client ~ ➜  cat response.json
{"statusCode": 200, "body": "Welcome to KKE AWS Labs!"}
aws-client ~ ➜  
```
 
## Day 34: Create a Lambda Function Using CLI
```
aws-client ~ ➜  cat > lambda_function.py <<EOF
def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "body": "Welcome to KKE AWS Labs!"
    }
EOF

aws-client ~ ➜  zip function.zip lambda_function.py
  adding: lambda_function.py (deflated 14%)

aws-client ~ ➜  aws iam get-role \
  --role-name lambda_execution_role \
  --query "Role.Arn" \
  --output text
arn:aws:iam::017616195538:role/lambda_execution_role

 
 

aws-client ~ ✖ aws lambda create-function   --function-name devops-lambda-cli   --runtime python3.12   --role arn:aws:iam::017616195538:role/lambda_execution_role   --handler lambda_function.lambda_handler   --zip-file fileb://function.zip   --description "DevOps CLI Lambda function"
{
    "FunctionName": "devops-lambda-cli",
    "FunctionArn": "arn:aws:lambda:us-east-1:017616195538:function:devops-lambda-cli",
    "Runtime": "python3.12",
    "Role": "arn:aws:iam::017616195538:role/lambda_execution_role",
    "Handler": "lambda_function.lambda_handler",
    "CodeSize": 293,
    "Description": "DevOps CLI Lambda function",
    "Timeout": 3,
    "MemorySize": 128,
    "LastModified": "2026-05-16T00:29:04.007+0000",
    "CodeSha256": "XLumZbKNxSwtcf/q4BHKHiI691HijFBUJi+qWVDGlEw=",
    "Version": "$LATEST",
    "TracingConfig": {
        "Mode": "PassThrough"
    },
    "RevisionId": "87a09967-c361-4f7f-a8a8-bbbbc0fbbc93",
    "State": "Pending",
    "StateReason": "The function is being created.",
    "StateReasonCode": "Creating",
    "PackageType": "Zip",
    "Architectures": [
        "x86_64"
    ],
    "EphemeralStorage": {
        "Size": 512
    },
    "SnapStart": {
        "ApplyOn": "None",
        "OptimizationStatus": "Off"
    },
    "RuntimeVersionConfig": {
        "RuntimeVersionArn": "arn:aws:lambda:us-east-1::runtime:e4ab553846c4e081013ff7d1d608a5358d5b956bb5b81c83c66d2a31da8f6244"
    },
    "LoggingConfig": {
        "LogFormat": "Text",
        "LogGroup": "/aws/lambda/devops-lambda-cli"
    }
}

aws-client ~ ➜  aws lambda invoke \
  --function-name devops-lambda-cli \
  output.json
{
    "StatusCode": 200,
    "ExecutedVersion": "$LATEST"
}

aws-client ~ ➜  cat output.json
{"statusCode": 200, "body": "Welcome to KKE AWS Labs!"}
aws-client ~ ➜  

```
 
## Day 35: Deploying and Managing Applications on AWS
 ```

 
aws-client ~ via 🐘 ➜  eexport DB_NAME="devops_db"
export DB_ID="devops-rds"
export DB_USER="devops_admin"
export DB_PASS="Devops@12345"
export DB_CLASS="db.t3.micro"
export DB_ENGINE="mysql"
export DB_ENGINE_VERSION="8.4.5"
export DB_STORAGE="5"
export DB_STORAGE_TYPE="gp2"

export EC2_NAME="devops-ec2"
export KEY_FILE="key.pem"

aws-client ~ via 🐘 ➜  aaws rds create-db-instance \
  --db-instance-identifier $DB_ID \
  --db-instance-class $DB_CLASS \
  --engine $DB_ENGINE \
  --engine-version $DB_ENGINE_VERSION \
  --master-username $DB_USER \
  --master-user-password $DB_PASS \
  --allocated-storage $DB_STORAGE \
  --storage-type $DB_STORAGE_TYPE \
  --db-name $DB_NAME \
  --no-publicly-accessible

An error occurred (InvalidParameterValue) when calling the CreateDBInstance operation: The parameter MasterUserPassword is not a valid password. Only printable ASCII characters besides '/', '@', '"', ' ' may be used.

aws-client ~ via 🐘 ✖ eexport DB_PASS="Devops12345"

aws-client ~ via 🐘 ➜  eaws rds create-db-instance   --db-instance-identifier $DB_ID   --db-instance-class $DB_CLASS   --engine $DB_ENGINE   --engine-version $DB_ENGINE_VERSION   --master-username $DB_USER   --master-user-password $DB_PASS   --allocated-storage $DB_STORAGE   --storage-type $DB_STORAGE_TYPE   --db-name $DB_NAME   --no-publicly-accessible
{
    "DBInstance": {
        "DBInstanceIdentifier": "devops-rds",
        "DBInstanceClass": "db.t3.micro",
        "Engine": "mysql",
        "DBInstanceStatus": "creating",
        "MasterUsername": "devops_admin",
        "DBName": "devops_db",
        "AllocatedStorage": 5,
        "PreferredBackupWindow": "03:30-04:00",
        "BackupRetentionPeriod": 1,
        "DBSecurityGroups": [],
        "VpcSecurityGroups": [
            {
                "VpcSecurityGroupId": "sg-040fea01aa3db56e1",
                "Status": "active"
            }
        ],
        "DBParameterGroups": [
            {
                "DBParameterGroupName": "default.mysql8.4",
                "ParameterApplyStatus": "in-sync"
            }
        ],
        "DBSubnetGroup": {
            "DBSubnetGroupName": "default",
            "DBSubnetGroupDescription": "default",
            "VpcId": "vpc-052f5f6bee70a49ae",
            "SubnetGroupStatus": "Complete",
            "Subnets": [
                {
                    "SubnetIdentifier": "subnet-08b824132e3c37a9a",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1f"
                    },
                    "SubnetOutpost": {},
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-0839d86c55866a5d3",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1d"
                    },
                    "SubnetOutpost": {},
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-083c2df5092175916",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1b"
                    },
                    "SubnetOutpost": {},
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-04c3d801c3579fdf3",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1e"
                    },
                    "SubnetOutpost": {},
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-069950d846224e4fa",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1c"
                    },
                    "SubnetOutpost": {},
                    "SubnetStatus": "Active"
                },
                {
                    "SubnetIdentifier": "subnet-0b6a0194f8cc662e6",
                    "SubnetAvailabilityZone": {
                        "Name": "us-east-1a"
                    },
                    "SubnetOutpost": {},
                    "SubnetStatus": "Active"
                }
            ]
        },
        "PreferredMaintenanceWindow": "tue:06:02-tue:06:32",
        "UpgradeRolloutOrder": "second",
        "PendingModifiedValues": {
            "MasterUserPassword": "****"
        },
        "MultiAZ": false,
        "EngineVersion": "8.4.5",
        "AutoMinorVersionUpgrade": true,
        "ReadReplicaDBInstanceIdentifiers": [],
        "LicenseModel": "general-public-license",
        "StorageThroughput": 0,
        "OptionGroupMemberships": [
            {
                "OptionGroupName": "default:mysql-8-4",
                "Status": "in-sync"
            }
        ],
        "PubliclyAccessible": false,
        "StorageType": "gp2",
        "DbInstancePort": 0,
        "StorageEncrypted": false,
        "DbiResourceId": "db-D5FJ3S7TT27VZ7TYZJ2BZH6NGQ",
        "CACertificateIdentifier": "rds-ca-rsa2048-g1",
        "DomainMemberships": [],
        "CopyTagsToSnapshot": false,
        "MonitoringInterval": 0,
        "DBInstanceArn": "arn:aws:rds:us-east-1:422463611008:db:devops-rds",
        "IAMDatabaseAuthenticationEnabled": false,
        "DatabaseInsightsMode": "standard",
        "PerformanceInsightsEnabled": false,
        "DeletionProtection": false,
        "AssociatedRoles": [],
        "TagList": [],
        "CustomerOwnedIpEnabled": false,
        "NetworkType": "IPV4",
        "BackupTarget": "region",
        "CertificateDetails": {
            "CAIdentifier": "rds-ca-rsa2048-g1"
        },
        "DedicatedLogVolume": false,
        "EngineLifecycleSupport": "open-source-rds-extended-support"
    }
}

aws-client ~ via 🐘 ➜  aaws rds describe-db-instances \
  --db-instance-identifier $DB_ID \
  --query "DBInstances[0].DBInstanceStatus"
"creating"

aws-client ~ via 🐘 ➜  aws rds describe-db-instances   --db-instance-identifier $DB_ID   --query "DBInstances[0].DBInstanceStatus"
"creating"

aws-client ~ via 🐘 ➜  aws rds describe-db-instances   --db-instance-identifier $DB_ID   --query "DBInstances[0].DBInstanceStatus"
"creating"

aws-client ~ via 🐘 ➜  aws rds describe-db-instances   --db-instance-identifier $DB_ID   --query "DBInstances[0].DBInstanceStatus"
"configuring-enhanced-monitoring"

aws-client ~ via 🐘 ➜  aws rds describe-db-instances   --db-instance-identifier $DB_ID   --query "DBInstances[0].DBInstanceStatus"
"available"

aws-client ~ via 🐘 ➜  xexport EC2_SG=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=$EC2_NAME" \
  --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" \
  --output text)
bash: xexport: command not found

aws-client ~ via 🐘 ✖ export EC2_SG=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=$EC2_NAME" \
  --query "Reservations[0].Instances[0].SecurityGroups[0].GroupId" \
  --output text)

aws-client ~ via 🐘 ➜  export RDS_SG=$(aws rds describe-db-instances \
  --db-instance-identifier $DB_ID \
  --query "DBInstances[0].VpcSecurityGroups[0].VpcSecurityGroupId" \
  --output text)

aws-client ~ via 🐘 ➜  aaws ec2 authorize-security-group-ingress \
  --group-id $RDS_SG \
  --protocol tcp \
  --port 3306 \
  --source-group $EC2_SG
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-076e89863ba4e4c82",
            "GroupId": "sg-040fea01aa3db56e1",
            "GroupOwnerId": "422463611008",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 3306,
            "ToPort": 3306,
            "ReferencedGroupInfo": {
                "GroupId": "sg-040fea01aa3db56e1",
                "UserId": "422463611008"
            },
            "SecurityGroupRuleArn": "arn:aws:ec2:us-east-1:422463611008:security-group-rule/sgr-076e89863ba4e4c82"
        }
    ]
}

aws-client ~ via 🐘 ➜  aws ec2 authorize-security-group-ingress \
  --group-id $EC2_SG \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-05afa57239afb594c",
            "GroupId": "sg-040fea01aa3db56e1",
            "GroupOwnerId": "422463611008",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 80,
            "ToPort": 80,
            "CidrIpv4": "0.0.0.0/0",
            "SecurityGroupRuleArn": "arn:aws:ec2:us-east-1:422463611008:security-group-rule/sgr-05afa57239afb594c"
        }
    ]
}

aws-client ~ via 🐘 ➜  aws ec2 authorize-security-group-ingress \
  --group-id $EC2_SG \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0
{
    "Return": true,
    "SecurityGroupRules": [
        {
            "SecurityGroupRuleId": "sgr-0e05577295fadfc16",
            "GroupId": "sg-040fea01aa3db56e1",
            "GroupOwnerId": "422463611008",
            "IsEgress": false,
            "IpProtocol": "tcp",
            "FromPort": 22,
            "ToPort": 22,
            "CidrIpv4": "0.0.0.0/0",
            "SecurityGroupRuleArn": "arn:aws:ec2:us-east-1:422463611008:security-group-rule/sgr-0e05577295fadfc16"
        }
    ]
}

aws-client ~ via 🐘 ➜  export EC2_IP=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=$EC2_NAME" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

aws-client ~ via 🐘 ➜  echo $EC2_IP
3.82.107.87

aws-client ~ via 🐘 ➜  [[ -f ~/.ssh/id_rsa ] || ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
Generating public/private rsa key pair.
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub
The key fingerprint is:
SHA256:ozUght09CzJzJnyQkRVOQZWiAGU35RGb5hxXolRo468 root@aws-client
The key's randomart image is:
+---[RSA 4096]----+
|.oo =B@B+..      |
| ..=oO=*.o       |
|  ..X+/o+        |
|   ..&.= o       |
|      o.S        |
|       o.o       |
|      ..         |
|      E          |
|                 |
+----[SHA256]-----+

aws-client ~ via 🐘 ➜  ssh -i $KEY_FILE ubuntu@$EC2_IP << 'EOF'
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "$(cat ~/.ssh/authorized_keys)" > ~/.ssh/authorized_keys
EOF
Warning: Identity file key.pem not accessible: No such file or directory.
Pseudo-terminal will not be allocated because stdin is not a terminal.
The authenticity of host '3.82.107.87 (3.82.107.87)' can't be established.
ECDSA key fingerprint is SHA256:elfEiqrQpNkZuR83ceCBPq+aZtVMLa86gIG+iAakYuc.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '3.82.107.87' (ECDSA) to the list of known hosts.
ubuntu@3.82.107.87: Permission denied (publickey).

aws-client ~ via 🐘 ✖ ls -l
total 4
-rw-r--r-- 1 root root 535 May 16 05:39 index.php

aws-client ~ via 🐘 ➜  eexport KEY_FILE=~/.ssh/id_rsa

aws-client ~ via 🐘 ➜  eexport EC2_IP=3.82.107.87
export KEY_FILE=~/.ssh/id_rsa

aws-client ~ via 🐘 ➜  sssh -i $KEY_FILE ubuntu@$EC2_IP "echo OK"
ubuntu@3.82.107.87: Permission denied (publickey).

aws-client ~ via 🐘 ✖ ssh -i $KEY_FILE ubuntu@$EC2_IP "echo OK"
ubuntu@3.82.107.87: Permission denied (publickey).

aws-client ~ via 🐘 ✖ aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=devops-ec2" \
  --query "Reservations[0].Instances[0].KeyName" \
  --output text
None

aws-client ~ via 🐘 ➜  cat ~/.ssh/id_rsa.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7eqqvnHucWFEYEW46TU2/hNXph9sxXC1j4nEl0Ftf/rXwRqDqBXWPc+PMfhI7rL6W87GSSF0Jc7iWcfPrjPqLySBfa40aiA9BnLnMb/Q4hkfUlVJV5WcWHX0pH0LWDEINnmCegZ19kY2nrdA2HECOEawRzlVkm+M+RS1QrZM6aFcg37BC3e933AqmE0dWqjdRHKGhO12xH2lswhjKlmmGaxaOVBasG1kcAg8QUfz/tYvozcn4QCvFMcx8LSRfDjAa0L28dA0l309IPkkGndWowGgqXdnL8orYJXsxzG7sGN00xDZD5psf15A+7vTlRNy/FKTMFuqhoosUODqydIknOXNHNbCmrCT7zSFKpbyalRq7WJ8b147qsbEOihw6tu5md0X+U8IL72S7AvyoNUrXTY8skA4PClA8p2dN9fBYnOn/GwXkL28rp/XzGZCeRY1TrwSalQnDzhFCfRNnWHcjLVDBX0Sk5RFvZfY0K4EaTZBQ9+xb/MrP59nnI+DoZo28Ap/ruKzdRxyKnlSsr5t4uSgO3Gr2kp3VHXFN07kod8k/k3jjRDl/nA86GGCbYNRu6iovM2J9g8mMPTXqZaZlu1PLn0aMiDFEqAXBRnN1NAgK8GKKrhKgOPaRWagT3FVaMAwRNVpTfSHDmGRpW2prgxPMXnMXNn/mddII12KKzw== root@aws-client

aws-client ~ via 🐘 ➜  ssh ubuntu@$EC2_IP
Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 6.5.0-1022-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sat May 16 06:01:30 UTC 2026

  System load:  0.02              Processes:             109
  Usage of /:   25.8% of 7.57GB   Users logged in:       1
  Memory usage: 24%               IPv4 address for eth0: 172.31.94.126
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

243 updates can be applied immediately.
167 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status

New release '24.04.4 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


Last login: Sat May 16 06:00:22 2026 from 18.206.107.28
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ubuntu@ip-172-31-94-126:~$ exit
logout
Connection to 3.82.107.87 closed.

aws-client ~ via 🐘 ➜  ssh -o BatchMode=yes -i ~/.ssh/id_rsa ubuntu@$EC2_IP "echo SSH_OK"
SSH_OK

aws-client ~ via 🐘 ➜  scp -i ~/.ssh/id_rsa /root/index.php ubuntu@$EC2_IP:/home/ubuntu/
index.php                                                                      100%  535     5.1KB/s   00:00    

aws-client ~ via 🐘 ➜  ssh -i ~/.ssh/id_rsa ubuntu@$EC2_IP << 'EOF'
sudo mv /home/ubuntu/index.php /var/www/html/
EOF
Pseudo-terminal will not be allocated because stdin is not a terminal.
Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 6.5.0-1022-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sat May 16 06:02:34 UTC 2026

  System load:  0.01              Processes:             109
  Usage of /:   25.8% of 7.57GB   Users logged in:       1
  Memory usage: 24%               IPv4 address for eth0: 172.31.94.126
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

243 updates can be applied immediately.
167 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status

New release '24.04.4 LTS' available.
Run 'do-release-upgrade' to upgrade to it.



aws-client ~ via 🐘 ➜  sssh -i ~/.ssh/id_rsa ubuntu@$EC2_IP
Welcome to Ubuntu 22.04.4 LTS (GNU/Linux 6.5.0-1022-aws x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Sat May 16 06:02:34 UTC 2026

  System load:  0.01              Processes:             109
  Usage of /:   25.8% of 7.57GB   Users logged in:       1
  Memory usage: 24%               IPv4 address for eth0: 172.31.94.126
  Swap usage:   0%


Expanded Security Maintenance for Applications is not enabled.

243 updates can be applied immediately.
167 of these updates are standard security updates.
To see these additional updates run: apt list --upgradable

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status

New release '24.04.4 LTS' available.
Run 'do-release-upgrade' to upgrade to it.


Last login: Sat May 16 06:01:31 2026 from 65.108.255.62
ubuntu@ip-172-31-94-126:~$ sudo nano /var/www/html/index.php
ubuntu@ip-172-31-94-126:~$ vi /var/www/html/index.php
ubuntu@ip-172-31-94-126:~$ sudo apt update -y
Hit:1 http://us-east-1.ec2.archive.ubuntu.com/ubuntu jammy InRelease
Hit:2 http://us-east-1.ec2.archive.ubuntu.com/ubuntu jammy-updates InRelease
Hit:3 http://us-east-1.ec2.archive.ubuntu.com/ubuntu jammy-backports InRelease
Hit:4 http://security.ubuntu.com/ubuntu jammy-security InRelease
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
220 packages can be upgraded. Run 'apt list --upgradable' to see them.
ubuntu@ip-172-31-94-126:~$ sudo apt install -y apache2 php libapache2-mod-php php-mysql
 attended-uWaiting for cache lock: Could not get lock /var/lib/dpkg/lock-frontend. It is held by process 10441 (unattended-upgr)       
 
ubuntu@ip-172-31-94-126:~$ watch ps aux | grep apt
ubuntu@ip-172-31-94-126:~$ sudo apt install -y apache2 php libapache2-mod-php php-mysql
Waiting for cache lock: Could not get lock /var/lib/dpkg/lock-frontend. It is held by process 10441 (unattended-uWaiting for cache lock: Could not get lock /var/lib/dpkg/lock-frontend. It is held by process 10441 (unattended-upgr)      
Waiting for cache lock: Could not get lock /var/lib/dpkg/lock-frontend. It is held by process 10441 (unattended-uWaiting for cache lock: Could not get lock /var/lib/dpkg/lock-frontend. It is held by process 10441 (unattended-upgr)      
Waiting for cache lock: Could not get lock /var/lib/dpkg/lock-frontend. It is held by process 10441 (unattended-uWaiting for cache lock: Could not get lock /var/lib/dpkg/lock-frontend. It is held by process 10441 (unattended-upgr)      
Waiting for cache lock: Could not get lock /var/lib/dpkg/lock-frontend. It is held by process 10441 (unattended-uWaiting for cache lock: Could not get lock /var/lib/dpkg/lock-frontend. It is held by process 10441 (unattended-upgr)      
Waiting for cache lock: Could not get lock /var/lib/dpkg/lock-frontend. It is held by process 10441 (unattended-u^Cr)... 4s
ubuntu@ip-172-31-94-126:~$ watch ps aux | grep apt
ubuntu@ip-172-31-94-126:~$ sudo systemctl stop unattended-upgrades
ubuntu@ip-172-31-94-126:~$ sudo apt install -y apache2 php libapache2-mod-php php-mysql
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
php is already the newest version (2:8.1+92ubuntu1).
php-mysql is already the newest version (2:8.1+92ubuntu1).
apache2 is already the newest version (2.4.52-1ubuntu4.20).
The following NEW packages will be installed:
  libapache2-mod-php
0 upgraded, 1 newly installed, 0 to remove and 189 not upgraded.
Need to get 2898 B of archives.
After this operation, 18.4 kB of additional disk space will be used.
Get:1 http://us-east-1.ec2.archive.ubuntu.com/ubuntu jammy/main amd64 libapache2-mod-php all 2:8.1+92ubuntu1 [2898 B]
Fetched 2898 B in 0s (171 kB/s)        
Selecting previously unselected package libapache2-mod-php.
(Reading database ... 66286 files and directories currently installed.)
Preparing to unpack .../libapache2-mod-php_2%3a8.1+92ubuntu1_all.deb ...
Unpacking libapache2-mod-php (2:8.1+92ubuntu1) ...
Setting up libapache2-mod-php (2:8.1+92ubuntu1) ...
Scanning processes...                                                                                            
Scanning candidates...                                                                                           
Scanning linux images...                                                                                         

Running kernel seems to be up-to-date.

Restarting services...
 /etc/needrestart/restart.d/systemd-manager
 systemctl restart chrony.service packagekit.service polkit.service serial-getty@ttyS0.service systemd-journald.service systemd-networkd.service systemd-resolved.service
Service restarts being deferred:
 systemctl restart getty@tty1.service
 systemctl restart networkd-dispatcher.service
 systemctl restart systemd-logind.service
 systemctl restart user@1000.service

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
ubuntu@ip-172-31-94-126:~$ sudo apt update -y
sudo apt install -y apache2 php libapache2-mod-php php-mysql
Hit:1 http://us-east-1.ec2.archive.ubuntu.com/ubuntu jammy InRelease
Hit:2 http://us-east-1.ec2.archive.ubuntu.com/ubuntu jammy-updates InRelease
Hit:3 http://us-east-1.ec2.archive.ubuntu.com/ubuntu jammy-backports InRelease
Hit:4 http://security.ubuntu.com/ubuntu jammy-security InRelease
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
189 packages can be upgraded. Run 'apt list --upgradable' to see them.
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
libapache2-mod-php is already the newest version (2:8.1+92ubuntu1).
php is already the newest version (2:8.1+92ubuntu1).
php-mysql is already the newest version (2:8.1+92ubuntu1).
apache2 is already the newest version (2.4.52-1ubuntu4.20).
0 upgraded, 0 newly installed, 0 to remove and 189 not upgraded.
ubuntu@ip-172-31-94-126:~$ sudo systemctl enable apache2
sudo systemctl restart apache2
Synchronizing state of apache2.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable apache2
ubuntu@ip-172-31-94-126:~$ http://$EC2_IP
-bash: http://: No such file or directory
ubuntu@ip-172-31-94-126:~$ http://devops-rds.cimiaz3wia2r.us-east-1.rds.amazonaws.com
-bash: http://devops-rds.cimiaz3wia2r.us-east-1.rds.amazonaws.com: No such file or directory
ubuntu@ip-172-31-94-126:~$ exit
logout
Connection to 3.82.107.87 closed.

 
 ```
## Day 36: Load Balancing EC2 Instances with Application Load Balancer
 ```
 ```
Day 37: Managing EC2 Access with S3 Role-based Permissions
 ```
 ```
Day 38: Deploying Containerized Applications with Amazon ECS
 ```
 ```
Day 39: Hosting a Static Website on AWS S3
 ```
 ```
Day 40: Troubleshooting Internet Accessibility for an EC2-Hosted Application
 
  ```
 ```
Day 41: Securing Data with AWS KMS
  ```
 ```
Day 42: Building and Managing NoSQL Databases with AWS DynamoDB
  ```
 ```
Day 43: Scaling and Managing Kubernetes Clusters with Amazon EKS
  ```
 ```
Day 44: Implementing Auto Scaling for High Availability in AWS
  ```
 ```
Day 45: Configure NAT Gateway for Internet Access in a Private VPC
  ```
 ```
Day 46: Event-Driven Processing with Amazon S3 and Lambda
  ```
 ```
Day 47: Integrating AWS SQS and SNS for Reliable Messaging
  ```
 ```
Day 48: Automating Infrastructure Deployment with AWS CloudFormation
  ```
 ```
Day 49: Centralized Audit Logging with VPC Peering
 
  ```
 ```
Day 50: Expanding EC2 Instance Storage for Development Needs
 ```
 ```