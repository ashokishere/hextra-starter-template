---
title:  Infrastructure as Code with Terraform
type: docs
prev: docs/NanaBootcamo/Module11
next: docs/NanaBootcamo/Module13
sidebar:
  open: true
---
 

Terraform is an open-source Infrastructure as Code (IaC) tool that allows you to define and manage infrastructure as code. It supports multiple cloud providers such as AWS, Azure, Google Cloud, and others via provider plugins.

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