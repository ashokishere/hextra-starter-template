---
title:  AWS Services
type: docs
prev: docs/NanaBootcamo/Module8
next: docs/NanaBootcamo/Module10
sidebar:
  open: true
---

# Amazon Web Services (AWS):
---

### 1\. Overview &amp; Cloud Scopes

* **Amazon Web Services (AWS)**: A leading cloud computing platform featuring a vast ecosystem of infrastructure and application services.
* **Free Tier**: New accounts include 12 months of free tier access for basic resources, though certain high-level services are excluded.
* **Infrastructure Hierarchy &amp; Scopes**:
  * **Global Scope**: Account-wide services that operate globally across all regions (e.g., IAM, Billing, Route 53).
  * **Region Scope**: Geographical locations containing clusters of discrete data centers (e.g., S3, VPC, DynamoDB).
  * **Availability Zone (AZ) Scope**: One or more physical, isolated data centers within a Region (e.g., EC2 instances, EBS volumes, RDS databases).

---

### 2\. Identity and Access Management (IAM)

* **IAM Functionality**: Defines and manages identity permissions to specify who can access specific AWS services and resources.
* **ROOT User**: Created by default upon account registration with unlimited privileges. Best practices dictate securing the ROOT account and creating an administrative IAM user with fewer privileges for day-to-day management.
* **Types of IAM Users**:
  * **Human Users**: Accounts for team members accessing the AWS Management Console or CLI.
  * **System Users**: Programmatic accounts (e.g., Jenkins) requiring API credentials to deploy resources automatically.
* **Groups**: Collections of users that inherit shared permission policies.
* **IAM Roles**: Permission sets assumed temporarily by users or AWS services (e.g., allowing an EC2 instance or EKS cluster to communicate with other AWS services).
* **Security Best Practices**: Assign permission policies to Roles or Groups rather than directly to individual users, and strictly enforce the **Rule of Least Privilege**.

---

### 3\. Virtual Private Cloud (VPC) &amp; Networking

* **Virtual Private Cloud (VPC)**: An isolated virtual network infrastructure in the cloud where all server resources reside. Each AWS Region contains a default VPC that spans across all Availability Zones.
* **Subnets**: Subdivisions of a VPC's IP address range assigned to specific Availability Zones.
  * **Public Subnet**: Connected to the internet via an Internet Gateway, allowing public inbound and outbound traffic.
  * **Private Subnet**: Isolated from the public internet for sensitive internal workloads like databases.
* **Internet Gateway**: A VPC component enabling communication between public subnet resources and the internet.
* **Classless Inter-Domain Routing (CIDR)**: IP address range blocks assigned to VPCs and subdivided into subnet CIDRs.
* **Network Security Layers**:
  * **Network Access Control Lists (NACLs)**: Stateless firewall rules configured at the **subnet level**.
  * **Security Groups**: Stateful firewall rules configured at the individual **instance level**.

---

### 4\. Amazon Elastic Compute Cloud (EC2)

* **EC2 Instances**: Scalable virtual servers providing compute capacity in the cloud.
* **Instance Launch Workflow**: Involves selecting an OS image (AMI), choosing instance capacity/type (e.g., `t2.micro`), configuring VPC networking and subnets, adding storage volumes, assigning tags, and attaching Security Groups.
* **SSH Access**: Linux instances require an unencrypted PEM RSA private key for SSH authentication. Private key files should be stored in the local `~/.ssh/` directory with restricted read permissions (`chmod 400`).

---

### 5\. AWS Container Services

* **Elastic Container Registry (ECR)**: A fully managed private Docker image registry. To push images, developers authenticate the local Docker client using the AWS CLI, tag the built image with the ECR repository URI, and execute `docker push`.
* **Elastic Container Service (ECS)**: AWS's proprietary container orchestration service. The Control Plane is managed by AWS, while compute tasks run on EC2 instances (with the ECS Agent installed) or serverless compute.
* **Elastic Kubernetes Service (EKS)**: Amazon's managed Kubernetes platform. AWS manages and replicates Control Plane master nodes across Availability Zones, while worker nodes run on EC2 Node Groups.
* **AWS Fargate**: A serverless compute engine for ECS and EKS that provisions capacity on-demand so you pay only for used resources without managing underlying virtual machines.

---

### 6\. Management, Infrastructure as Code, &amp; Automation

* **AWS CLI**: Interacts with AWS services via commands structured as `aws


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
