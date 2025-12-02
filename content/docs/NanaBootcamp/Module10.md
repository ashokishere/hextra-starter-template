---
title:  Container Orchestration with Kubernetes
type: docs
prev: docs/NanaBootcamo/Module9
next: docs/NanaBootcamo/Module11
sidebar:
  open: true
---
 

## Use Cases

Kubernetes (K8s) is used for deploying complex applications under a microservices architecture but can also handle monolithic applications efficiently.

## Pros

- **High Availability and No Downtime**: Ensures applications are always available.
- **Scalability and High Performance**: Easily scales applications to meet demand.
- **Disaster Recovery and Backup**: Provides mechanisms for backup and restore operations.

## Kubernetes Components

- **Node**: Physical or virtual servers that can be worker nodes or master nodes (e.g., AWS EC2 instances).
- **Pod**: Basic unit of deployment, an abstraction over containers, each with its own internal IP address.
- **Service**: Provides a permanent IP address to a set of Pods, acts as a load balancer between them.
- **Ingress**: Manages external access to the Services within the cluster.
- **ConfigMap**: Stores non-sensitive configuration data in key-value pairs.
- **Secret**: Stores sensitive information securely, base64 encoded.
- **Volumes**: Persists data beyond the life of a Pod.

## Kubernetes Commands

- **minikube**: Utility for testing Kubernetes clusters locally.
- **kubectl**: Command-line tool to interact with Kubernetes clusters:
  - `kubectl get nodes`, `kubectl get pods`, `kubectl get deployments`, etc.
  - `kubectl create`, `kubectl edit`, `kubectl logs`, `kubectl describe`, `kubectl exec`, `kubectl delete`, `kubectl apply`.

## Namespaces

- Logical partitions within a Kubernetes cluster:
  - **Default Namespaces**: `kube-system`, `kube-public`, `kube-node-lease`, `default`.
  - Best practices include grouping resources, avoiding conflicts, and managing access and resource limits.

## Services

- Abstraction layer providing a stable IP address and load balancing:
  - **ClusterIP**: Default type for intra-cluster communication.
  - **Headless**: Directly exposes Pod IPs, useful for stateful sets.
  - **NodePort**: Exposes Service on a static port on each node.
  - **LoadBalancer**: Integrates with cloud providers' load balancers for external access.

## Ingress

- Manages external access to Services within a Kubernetes cluster:
  - Supports multiple host names and paths, can configure HTTPS.

## Volumes

- Persists data in Kubernetes:
  - **Persistent Volume (PV)**: Needs to be managed and provisioned by admin users.
  - **Persistent Volume Claim (PVC)**: Claims storage from PV for Pods.
  - Supports various types including ConfigMap and Secret volumes.

## Managed Kubernetes Services

- Cloud providers offer managed Kubernetes services:
  - Automates cluster setup and scaling of worker nodes.
  - Integrates with infrastructure-as-code tools like Terraform.

## Helm

- Package manager for Kubernetes:
  - **Helm Charts**: Packages of pre-configured Kubernetes resources.
  - **Helm Hub**: Repository for sharing and discovering Helm Charts.
  - **Helmfile**: Declarative configuration for managing Helm releases.

## Operators

- Custom controllers to manage applications and their lifecycle:
  - Automates complex operational tasks for stateful applications.

## Authorization and RBAC (Role-Based Access Control)

- Granular control over access to Kubernetes resources:
  - Uses Roles and RoleBindings for namespace-specific permissions.
  - Uses ClusterRoles and ClusterRoleBindings for cluster-wide permissions.
  - Integrates with external authentication sources like LDAP.

