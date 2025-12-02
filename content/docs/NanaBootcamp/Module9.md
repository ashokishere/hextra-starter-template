---
title:  AWS Services
type: docs
prev: docs/NanaBootcamo/Module8
next: docs/NanaBootcamo/Module10
sidebar:
  open: true
---


### Examples of AWS Services

- **EC2**: Virtual servers
- **S3**: Storage
- **VPC**: Virtual Private Cloud, including subnets
- **IAM**: Identity and Access Management for users and permissions
- **ECR**: Elastic Container Registry for storing container images
- **ECS**: Elastic Container Service for container orchestration
- **EKS**: Elastic Kubernetes Service for container orchestration with Kubernetes

### Services Scopes

- **Global**: e.g., IAM
- **Region**: e.g., S3, VPC
- **Availability Zone (AZ)**

### IAM - Identity and Access Management

IAM allows you to create users and assign permissions.

- **Best Practices**: 
  - Create an admin user with fewer privileges than the root user.
  - Use the admin user to create accounts for users and system users.
  - Create groups with specific permissions to simplify management.
  - Assign permissions to groups rather than individual users.
  - Policies can't be set directly for AWS services; you need to create an IAM role and attach the policy to it.

### Regions and Availability Zones (AZ)

- **Region**: Physical locations where data centers are clustered.
- **Availability Zone**: Each region typically has a minimum of two AZs, with new regions aiming for a minimum of three AZs.

### VPC - Virtual Private Cloud

- **Default VPC**: Automatically created for each region.
- **Subnet Configuration**: Subnets can be private or public.
- **Internet Gateway**: Connects VPC to the internet.
- **NACL (Network Access Control List)**: Configures access at the subnet level.
- **Security Groups**: Configures access at the instance level.

### CIDR Blocks

- **Definition**: Range of IP addresses.
- **Example**: `176.31.0.1/24` - Lower number after the slash indicates a higher range of IP addresses.

### AWS CLI

To get started with the AWS CLI, install it using a package manager (e.g., Homebrew on macOS: `brew install awscli`). Configure it with `aws configure`, providing your access key ID, secret access key, region, and output format.

#### EC2 Commands

- `aws ec2 run-instances --image-id xxxx --count x ...`
- `aws ec2 describe-vpcs`
- `aws ec2 create-security-group <attr>`
- `aws ec2 authorize-security-group-ingress <attr>`
- `aws ec2 create-key-pair <attr>`
- `aws ec2 describe-subnets`

#### IAM Commands

- `aws iam create-group <attr>`
- `aws iam create-user <attr>`
- `aws iam add-user-to-group <attr>`
- `aws iam get-user <attr>`
- `aws iam get-group <attr>`
- `aws iam list-policies <attr>`
- `aws iam attach-user-policy <attr>`
- `aws iam attach-group-policy <attr>`
- `aws iam list-attached-group-policies <attr>`
- `aws iam create-login-profile <attr>`
- `aws iam create-policy <attr>`
- `aws iam create-access-key <attr>`
