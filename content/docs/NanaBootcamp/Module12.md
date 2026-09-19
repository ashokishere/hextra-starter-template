---
title:  Infrastructure as Code with Terraform
type: docs
prev: docs/NanaBootcamo/Module11
next: docs/NanaBootcamo/Module13
sidebar:
  open: true
---
 

Terraform is an open-source Infrastructure as Code (IaC) tool that allows you to define and manage infrastructure as code. It supports multiple cloud providers such as AWS, Azure, Google Cloud, and others via provider plugins.


# Terraform &amp; Infrastructure as Code

---

### 1\. Overview &amp; Core Concepts

* **Definition**: **HashiCorp Terraform** is an open-source **Infrastructure as Code (IaC)** tool designed to create, provision, manage, replicate, and share cloud and on-premises infrastructure using human-readable configuration files.
* **Declarative Approach**: Terraform follows a **declarative paradigm**, meaning you specify **WHAT** desired end-state infrastructure you want, and Terraform automatically determines **HOW** to reach that state. In contrast, imperative tools require explicit step-by-step instructions.
* **Scope of Provisioning**: Automates setup across virtual private networks (VPCs), virtual machine instances (EC2), security groups, container clusters (EKS), and third-party SaaS services.
* **Version Control**: Configuration files (`.tf`) are stored and versioned in Git repositories, establishing a traceable history of infrastructure changes and enabling team code reviews via pull/merge requests.

---

### 2\. How Terraform Works: State &amp; Core Workflow

#### **The Role of the State File**

* Terraform maintains a tracking file called the **state file** (`terraform.tfstate`), which records the actual real-world infrastructure currently running.
* By comparing the desired state in `.tf` config files against the actual state in `terraform.tfstate`, Terraform accurately determines which resources need to be created, modified, or destroyed.

#### **Core 3-Step Workflow**

1. **Write**: Define desired infrastructure resources in declarative configuration files (`main.tf`).
2. **Plan**: Execute `terraform plan` to create an **execution plan** that previews exact infrastructure changes before applying them.
3. **Apply**: Execute `terraform apply` to provision the resources via cloud APIs and update the state file.

---

### 3\. Architecture &amp; Core Components

* **Providers**: Plugins that allow Terraform to communicate with specific platform APIs (e.g., IaaS like AWS or Azure, PaaS like Kubernetes, SaaS like Fastly). Providers expose downloadable resources and data sources.
* **Resources vs. Data Sources**:
  * **Resources**: Declarative definitions used to create and manage new infrastructure objects (e.g., `aws_vpc`, `aws_instance`).
  * **Data Sources**: Read-only queries used to fetch information from existing infrastructure outside of Terraform's direct management.
* **Variables &amp; Outputs**:
  * **Input Variables**: Parameterize configuration files to adapt deployments without modifying core code. Values can be supplied interactively, via command-line flags (`-var`), in variable definition files (`.tfvars`), or via environment variables (`TF_VAR_name`).
  * **Outputs**: Return specific values or attributes (such as server IP addresses) to the console or downstream scripts.

---

### 4\. Provisioners vs. Configuration Management

* **Provisioners**: Built-in directives (`remote-exec`, `local-exec`, `file`) used to execute commands or upload files to virtual instances upon creation.
* **Drawbacks**: Provisioners break Terraform's core idempotency and state comparison mechanisms because Terraform cannot model arbitrary shell script actions within its plan.
* **Best Practice**: Use cloud initialization mechanisms (e.g., `user_data` in AWS) for basic setup, or hand off instance configuration to dedicated configuration management tools like **Ansible** once servers are provisioned.

---

### 5\. Modularization with Terraform Modules

* **Definition**: A **module** is a container grouping multiple related resources together into a reusable unit.
* **Purpose**: Prevents monolithic configuration files, simplifies replication across environments (DEV, STAGING, PROD) or regions, and enforces standardization.
* **Module Design Pattern**:
  * **Input Variables**: Act as function parameters.
  * **Output Values**: Act as return values.
  * Standard file layout: `main.tf`, `variables.tf`, `outputs.tf`, and `providers.tf`.
* **Registries**: Pre-built community modules (such as official AWS VPC or EKS modules) are available on the **Terraform Registry**.

---

### 6\. Remote State &amp; Team Collaboration

* **Local State Issue**: Storing state files locally on a single machine or checking them into Git creates synchronization issues, state drift, risk of data loss, and exposes sensitive data.
* **Remote Backends**: Terraform supports storing state files remotely in centralized stores like **Amazon S3**, Google Cloud Storage, Azure Blob Storage, or Terraform Cloud.
* **Remote State Best Practices**:
  * **State Locking**: Automatically locks state during execution to prevent concurrent runs by team members.
  * **S3 Bucket Versioning**: Enable versioning to allow state file recovery in case of accidental corruption.
  * **Encryption**: Enable mandatory encryption at rest on state storage buckets.
  * **Isolation**: Use 1 distinct state file per target environment.

---

### 7\. Comparisons: Terraform vs. Other DevOps Tools

* **Terraform vs. Ansible**:
  * Terraform excels at **infrastructure provisioning** (orchestrating cloud resources, VPCs, and cluster creation).
  * Ansible excels at **configuration management** (installing software and configuring OS settings inside running servers).
  * **Integration**: Terraform provisions infrastructure and can automatically invoke Ansible playbooks to configure the provisioned instances.
* **Terraform vs. Python (Boto3)**:
  * Terraform natively manages state, is declarative, and guarantees **idempotency** (rerunning the same code produces identical results without duplicating infrastructure).
  * Python scripts using cloud SDKs are imperative and lack built-in state management, requiring custom logic to check existing resource states and clean up failed provisioning steps.

---

### 8\. CLI Command Summary &amp; Security Best Practices

#### **Essential CLI Commands**

* `terraform init`: Initializes the working directory, downloads required provider plugins, and sets up module/backend configurations.
* `terraform plan`: Generates and displays an execution plan preview.
* `terraform apply`: Provisions or updates infrastructure to match the configuration.
* `terraform destroy`: Safely tears down and deletes all infrastructure resources managed by the configuration.

#### **Security &amp; Engineering Best Practices**

1. **Credentials Management**: Never hardcode cloud access keys or SSH private key files (`.pem`) inside configuration files or check them into Git. Use environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`) or secure secret managers.
2. **Naming Conventions**: Use underscores (`_`) instead of hyphens (`-`) for resource, data source, and variable names.
3. **Repository Structure**: Maintain separate Git repositories for application source code and Terraform infrastructure code.
4. **CI/CD Execution**: In production, execute `terraform apply` exclusively through automated CI/CD pipelines (e.g., Jenkins) rather than manually from developer laptops.


---

## Advantages

- **Version Control**: Track history of infrastructure changes.
- **Environment Replication**: Easily replicate infrastructure for different environments.
- **Simplified Cleanup**: Remove all infrastructure with one command.
- **Team Collaboration**: Easy to see and modify infrastructure changes.

---

## How Terraform Connects to Providers

Terraform connects to cloud providers using their APIs.  
For example, with AWS, you can deploy EC2 instances, manage VPCs, and other resources from a single repository.

---

## Terraform Files

| File | Purpose |
|------|---------|
| `main.tf` | Main Terraform configuration and resource definitions |
| `variables.tf` | Define input variables |
| `outputs.tf` | Define output values |
| `providers.tf` | Specify provider configurations |
| `terraform.tfvars` | Assign values to variables |
| `terraform.tfstate` | Stores current state of infrastructure |
| `terraform.tfstate.backup` | Backup of the state file |
| `.terraform/` | Contains plugins and provider binaries |

---

## Terraform Commands

- `terraform init` - Initialize Terraform and install plugins
- `terraform plan` - Show execution plan
- `terraform apply` - Apply configuration changes
- `terraform destroy` - Destroy infrastructure
- `terraform refresh` - Refresh state with real resources

---

## Modules and Providers

- **Modules**: Reusable groups of resources with inputs and outputs.
- **Providers**: Plugins to connect Terraform to cloud platforms (e.g., AWS, DigitalOcean).

---

## Types of Resources

- **Resource**: Creates and manages infrastructure components.
- **Data**: Queries existing resources without creating new ones.

---

## Variables

- Defined in `variables.tf` or `terraform.tfvars`.
- Can also be set via:
  - Command-line flag: `-var`
  - Environment variable: `TF_VAR_<name>`
  - Variable file: `-var-file <file>` (JSON or HCL format)
- Example: 

```bash
terraform apply -var-file <file>
```

## Provisioners

Used to run scripts or commands on resources after creation.

remote-exec - Execute commands on remote resources

local-exec - Execute commands locally

file - Copy files to remote resources

Note: Provisioners are not recommended by Terraform for production; consider using Ansible or Chef instead.

## Remote State

Stores Terraform state in a remote backend (e.g., AWS S3).

Facilitates collaboration, state locking, and backup/versioning.

## Best Practices

- Only change state via Terraform commands.
- Use a remote backend for shared state.
- Enable state locking to avoid conflicts.
- Backup and version state files.
- Use one state per environment.
- Host Terraform code in its own Git repository.
- Integrate Terraform into CI pipelines for testing.
- Apply infrastructure changes via CD pipelines.