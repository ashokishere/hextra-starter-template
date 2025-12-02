---
title:  Kubernetes on AWS - EKS
type: docs
prev: docs/NanaBootcamo/Module10
next: docs/NanaBootcamo/Module12
sidebar:
  open: true
---


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
