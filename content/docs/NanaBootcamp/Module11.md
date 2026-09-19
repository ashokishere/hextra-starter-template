---
title:  Kubernetes on AWS - EKS
type: docs
prev: docs/NanaBootcamo/Module10
next: docs/NanaBootcamo/Module12
sidebar:
  open: true
---

# Kubernetes on AWS (Amazon EKS)

---

### 1\. Overview of AWS Container Services

AWS provides three primary container management and registry services:

* **Amazon Elastic Container Registry (ECR)**: A fully managed private Docker container registry used to securely store, manage, version, and deploy container images. It integrates natively with AWS container deployment services.
* **Amazon Elastic Container Service (ECS)**: AWS’s proprietary container orchestration tool. While the ECS Control Plane is free, it relies on proprietary AWS APIs, making cross-cloud migration complex.
* **Amazon Elastic Kubernetes Service (EKS)**: Amazon’s managed Kubernetes platform. It provides native Kubernetes APIs, allowing full portability, access to open-source Kubernetes tooling (such as Helm charts), and seamless migration across cloud environments.

---

### 2\. Amazon EKS Architecture &amp; How It Works

* **Managed Control Plane**: AWS automatically deploys, configures, and manages the Kubernetes Control Plane nodes (API Server, Scheduler, Controller Manager, and `etcd`).
* **High Availability**: The Control Plane is automatically replicated across multiple Availability Zones (AZs) within an AWS Region to eliminate single points of failure.
* **Control Plane-Worker Communication**: Unlike ECS (which uses a custom ECS Agent), EKS communicates with compute worker nodes through standard open-source Kubernetes processes (**Container Runtime**, **Kubelet**, and **Kube-proxy**).

---

### 3\. Worker Node Hosting Options

When deploying an EKS cluster, worker nodes can be hosted using three compute models:

1. **Self-Managed EC2 Instances**: You manually provision, configure, and maintain the underlying EC2 virtual machine infrastructure.
2. **EKS Managed Node Groups (Semi-Managed)**: AWS handles the automated provisioning, scaling, and lifecycle management (creation/deletion) of EC2 worker nodes. All required Kubernetes worker processes are pre-installed automatically.
3. **AWS Fargate (Fully-Managed / Serverless)**: A serverless execution engine that launches Pods on demand without requiring virtual machine or EC2 node management. Billing is strictly based on the exact compute resources used by running Pods.

---

### 4\. Step-by-Step EKS Cluster Provisioning Workflow

Provisioning an EKS cluster with a Managed Node Group involves the following key steps:

1. **Create EKS IAM Role**: Define an IAM role with policies that grant AWS EKS permission to create and configure networking components on your behalf.
2. **Provision a Custom VPC**: Create a Virtual Private Cloud (VPC) configured with both public and private subnets, alongside firewall rules for Control Plane-to-Worker communication.
3. **Provision the EKS Control Plane**: Launch the managed Control Plane nodes in AWS.
4. **Connect** **kubectl** **Locally**: Configure your local `kubeconfig` file with EKS cluster endpoint and authentication details to interact with the cluster API.
5. **Create EC2 IAM Role for Node Group**: Assign an IAM role with required policies to the worker nodes so `Kubelet` can manage Pods and interact with other AWS services.
6. **Create and Attach Managed Node Group**: Provision EC2 instances and attach them as Worker Nodes to the EKS Control Plane.
7. **Configure Cluster Auto-Scaling**: Deploy the `cluster-autoscaler` Pod component into the cluster and attach auto-scaling IAM policies to the Node Group Role to dynamically scale EC2 worker nodes based on workload demand.
8. **Deploy Workloads**: Apply Kubernetes YAML manifests to deploy containerized application Services and Deployments.

---

### 5\. Cluster Provisioning Methods

* **AWS Management Console (Manual)**: Involves step-by-step manual configuration, making replication across environments complex and error-prone.
* **eksctl** **CLI Tool**: An official command-line utility that automates cluster, VPC, and IAM role creation using simple single-line CLI commands.
* **Infrastructure as Code (Terraform)**: The recommended industry standard for automated, declarative, and version-controlled provisioning of EKS clusters, VPCs, and IAM roles using modular code.

---

### 6\. Continuous Deployment (CD) Pipeline with Jenkins, ECR, and EKS

Automating application deployments to EKS from a Jenkins CI/CD pipeline requires the following architecture:

* **Jenkins Server Dependencies**: Install `kubectl` CLI and `aws-iam-authenticator` inside the Jenkins environment, generate a `kubeconfig` file, and store AWS IAM credentials in Jenkins.
* **Image Delivery via ECR**:
  1. Authenticate Docker against the private AWS ECR registry (`aws ecr get-login-password`).
  2. Build and tag the Docker image with dynamic versioning.
  3. Push the image to the private ECR repository.
  4. Create a Kubernetes `docker-registry` Secret in EKS to authenticate image pulls.
  5. Update and apply Kubernetes manifests via the Jenkinsfile to trigger rolling updates on EKS.

---

### 7\. Production &amp; Security Best Practices

* **Network Isolation**: Best practices dictate placing EC2 Worker Nodes inside **Private Subnets**, using **Public Subnets** strictly for public-facing Elastic Load Balancers.
* **Secrets Encryption**: Enable envelope encryption for Kubernetes Secrets at rest using **AWS Key Management Service (KMS)** keys.
* **Least Privilege Access**: Apply the rule of least privilege by creating narrow IAM roles and Kubernetes Role-Based Access Control (RBAC) permissions specifically assigned to services, node groups, and CI/CD users.
* **Dynamic Auto-Scaling**: Combine Kubernetes Horizontal Pod Autoscaler (HPA) with the EKS Cluster Autoscaler to handle traffic spikes smoothly



## ECS (Elastic Container Service)

ECS, also known as Elastic Container Service, manages the lifecycle of containers on AWS. It operates by creating an ECS cluster that includes all necessary services for container management. Containers within ECS run on EC2 instances, similar to how Docker Swarm operates, but with management provided by ECS.

## ECS vs Fargate

- **ECS**: Requires managing EC2 instances where containers run. It provides more control over the underlying infrastructure.
  
- **Fargate**: A serverless compute engine for containers on AWS. It runs containers without requiring management of EC2 instances. Fargate automatically scales resources based on workload demands and handles underlying infrastructure maintenance, making it easier to operate.

## EKS (Elastic Kubernetes Service)

EKS allows for the management of Kubernetes clusters on AWS. It provides a Kubernetes control plane that integrates seamlessly with AWS services. Unlike ECS or Fargate, EKS is well-suited for organizations already using Kubernetes or seeking a more flexible container orchestration solution.

- **Vendor Lock-In**: EKS leverages Kubernetes, an open-source platform, reducing vendor lock-in compared to proprietary solutions like ECS or Fargate. Kubernetes compatibility across various cloud providers allows for easier migration using tools like Terraform.

- **Flexibility and Features**: EKS offers robust features and flexibility, making it suitable for complex application deployments under microservices architectures. It supports advanced Kubernetes functionalities and integrates with AWS services for enhanced scalability and reliability.

## Steps to Create an EKS Cluster

1. **Provision EKS Cluster**: Set up the Kubernetes control plane managed by AWS.
2. **Create NodeGroup**: Define a group of EC2 instances (nodes) that will run Kubernetes Pods.
3. **Connect NodeGroup to EKS Cluster**: Integrate the NodeGroup with the EKS cluster to enable Kubernetes to schedule Pods on the EC2 instances.

## ECR (Elastic Container Registry)

ECR is AWS's managed Docker container registry. It allows users to store, manage, and deploy Docker container images. While ECR integrates well with AWS services and is convenient for AWS-centric environments, some users prefer more flexible options like GitHub's container registry for its broader integration possibilities with CI/CD pipelines.

## Fargate

AWS Fargate is a serverless compute engine for containers, similar to Lambda for serverless functions. It abstracts away the need to manage EC2 instances, allowing users to run containers directly without provisioning or maintaining the underlying infrastructure. Fargate operates on a pay-per-use model, charging users only for the resources consumed by their containers.

Fargate is an excellent choice for scenarios where managing EC2 instances is impractical or where rapid scaling and resource efficiency are critical. It simplifies the deployment and management of containerized applications, making it ideal for serverless and event-driven architectures.

---

In summary, AWS offers a range of container management options from ECS to Kubernetes-based EKS and serverless Fargate, catering to different use cases and preferences for managing containerized applications on AWS infrastructure.

