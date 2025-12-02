---
title: Cloud & Infrastructure as a Service Basics with DigitalOcean
type: docs
prev: docs/NanaBootcamo/Module4
next: docs/NanaBootcamo/Module6
sidebar:
  open: true
---
 


DigitalOcean is a cloud provider that offers a variety of services as an **Infrastructure as a Service (IaaS)** provider. This means you can use DigitalOcean to create and manage virtual machines, databases, load balancers, and more.

DigitalOcean also provides several developer-friendly features. For example, you can create a **Droplet** (virtual machine) with a preinstalled Docker image, which makes it easy to run containers inside a VM.

### Setting Up a Virtual Machine

- **Image Selection:** Choose the OS or preconfigured image you want to use.
- **VM Size:** Select the CPU, RAM, and disk size.
- **SSH Keys:** Add an SSH key to the VM for secure and simple access.

### Networking Capabilities

- **Private Networking:** Connect multiple virtual machines together.
- **Port Exposure:** Open ports to the internet to expose applications.
  - Example: Exposing **Nexus** running directly on a VM.
  - Example: Exposing a Docker-based service running inside a VM, such as a **Jenkins** setup.

These features make it simple to deploy applications, manage infrastructure, and build cloud-based environments efficiently.
