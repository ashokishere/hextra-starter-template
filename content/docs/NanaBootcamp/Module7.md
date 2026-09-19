---
title: Containers with Docker
type: docs
prev: docs/NanaBootcamo/Module7
next: docs/NanaBootcamo/Module8
sidebar:
  open: true
---

v
---

### 1\. Introduction to Containers &amp; Docker

* **Definition of Docker**: Docker is an **open-source containerization platform** that allows developers to package applications alongside all necessary dependencies and configuration files into standardized containers.
* **Definition of a Container**: A container is a **portable, isolated, and standardized artifact** designed for seamless software development, shipment, and deployment across diverse environments.
* **Core Benefits**:
  * Eliminates "it works on my machine" issues by standardizing application runtimes.
  * Reduces server configuration overhead—production servers only require a container runtime installed rather than individual application dependencies (such as Node.js, Java, or specific database versions).
  * Simplifies single-artifact delivery, replacing multiple moving file types (JAR, WAR, ZIP) with a single **Docker Image** artifact.

---

### 2\. Containers vs. Virtual Machines (VMs)

Both containers and Virtual Machines are virtualization tools, but they operate at different layers of abstraction:

* **Virtual Machines**:
  * **Hardware-level abstraction**: A hypervisor creates virtual CPUs, RAM, and storage from host computer resources.
  * Each VM includes a complete copy of a **Guest Operating System**.
  * **OS Compatibility**: Any OS VM can run on top of any physical host OS machine via hypervisors like Oracle VM VirtualBox.
* **Docker Containers**:
  * **Application-layer abstraction**: Containers share the physical host system's **OS Kernel** rather than running separate OS instances.
  * **Size &amp; Speed**: Docker images are significantly smaller in size, and containers launch almost instantaneously compared to VMs.
  * **OS Compatibility**: Linux containers cannot run directly on a Windows host kernel natively; however, **Docker Desktop** bridges this on Windows and macOS using lightweight virtualization.

---

### 3\. Application Lifecycle: Before vs. After Docker

#### **Application Development**

* **Before Containers**: Installation procedures differed across each developer's OS environment, leading to complex setup guides and dependency version conflicts.
* **After Containers**: Developers launch identical isolated environments with **1 single command**. Running multiple versions of the same service (e.g., two different PostgreSQL versions) on one local computer becomes effortless.

#### **Application Deployment**

* **Before Containers**: Extensive manual server configuration was necessary, accompanied by written deployment guides that often caused misunderstandings between Developers and Operations teams.
* **After Containers**: Developers and Operations collaborate to package the application inside a container. Deployment servers need no manual dependency setup—only a **Container Runtime** is required.

---

### 4\. Core Concepts: Docker Image vs. Docker Container

* **Docker Image**: The actual static file package or **artifact** consisting of multiple read-only layers (typically starting from a lightweight Linux Base Image with application layers stacked on top). Images are portable and remain in a non-running state.
* **Docker Container**: The **running instance** defined by an image. Containers execute the application inside an isolated virtual file system with mapped network ports.

---

### 5\. Docker Architecture &amp; Engine Components

The **Docker Engine** is a single application providing complete container lifecycle management:

1. **Docker CLI (Command Line Interface)**: The client user interface for executing Docker commands.
2. **Docker Server (Daemon)**: Manages container lifecycles, pulls images, builds images, handles data persistence, and configures container networking.
3. **Docker API**: Intermediary interface enabling communication between the CLI and the Docker Server.

#### **Lightweight Tooling Alternatives**

If specialized modular tools are preferred over the full Docker Engine:

* **Container Runtimes**: `containerd`, `CRI-O`.
* **Image Building Tool**: `buildah`.

---

### 6\. Essential Docker CLI &amp; Debug Commands

#### **Main Commands**

* `docker pull `: Downloads a container image from a remote repository.
* `docker run `: Creates and executes a new container from an image.
* `docker run -d `: Executes a container in **detached mode** (in the background).
* `docker run -p

### What is a container?

A container is an isolated environment that runs a process.  
It is a process that is isolated from the host system.  
It has its own file system, its own network stack, and its own process tree.

This makes it very easy to run multiple processes on the same machine efficiently.

A container consists of layers on top of a base image.  
The layers contain executed commands or updates to the base image.

You can install packages inside a container using a **Dockerfile**, which contains a list of commands that run inside a container.

Containers are easy to create and destroy, making them highly scalable.  
You can tag images (your application) and run multiple containers on the same host.

---

### Virtual Machines vs Containers

A **Virtual Machine (VM)** is a full operating system that runs on top of the host system.  
It uses more resources than a container because a VM includes its own kernel.

---

### Docker Architecture

- **Docker Engine**
  - Docker Server
  - Container Runtime
  - Volumes
  - Network
  - Image Builder
  - Docker API
  - Docker CLI

---

### Useful Docker Commands

- `docker images` — list all images
- `docker pull <IMAGE>` — download/pull an image
- `docker run <IMAGE>` — create + start container (attached mode)
- `docker run -d <IMAGE>` — start container in detached mode
- `docker stop <CONTAINER_ID>`
- `docker start <CONTAINER_ID>`
- `docker ps` — list running containers
- `docker ps -a` — list all containers (running + stopped)
- `docker run -p <HOST_PORT>:<CONTAINER_PORT> <IMAGE>` — bind ports
- `docker run --name <NAME> <IMAGE>` — name the container
- `docker logs <CONTAINER_ID or NAME>` — show logs
- `docker logs <CONTAINER_NAME> | tail` — show last logs
- `docker logs <CONTAINER_NAME> -f` — stream logs
- `docker exec -it <CONTAINER_ID> sh` — enter container shell
- `docker exec -u 0 -it <CONTAINER_ID> sh` — enter as root user
- `docker network ls` — list networks
- `docker network create <NAME>` — create network
- `docker build -t <IMG_NAME>:<TAG> .` — build image
- `docker rm <CONTAINER_ID>` — delete container
- `docker rmi <IMAGE_ID>` — delete image

---

### Docker Network

Docker networks create isolated environments where containers can communicate with each other.  
Containers inside the same network can refer to each other using container names.

---

### Docker Compose

Allows running multiple containers at once using a single configuration file.

Commands:

- `docker-compose -f <FILE> up`
- `docker-compose -f <FILE> down`

Docker Compose is often used together with Docker Swarm for service orchestration.

---

### Storage

Containers are ephemeral.  
If you delete a container without a volume, all data inside is lost.

Use **volumes** to persist data outside the container.

---

### Dockerfile Example

```dockerfile
# Dockerfile -> blueprint for building images
FROM <base-image>     # Image to build from
ENV <key>=<value>     # Environment variables
RUN <command>         # Execute Linux command inside the container
COPY <src> <dest>     # Copy files from host to container
CMD ["executable"]    # Entry point command (only one CMD allowed)
```

---

### Docker Repositories

Docker images can be stored in:

- Docker Hub
- Nexus
- GitLab Container Registry
- GitHub Packages
- AWS ECR
- Private self-hosted registries

Private registries require authentication using:

```
docker login
```

---

### Best Practices

- Use **official base images**
- Pin image versions for stability
- Keep images minimal — only install what you need
- Use `.dockerignore` to exclude unnecessary files
- Avoid running as root
- Scan images for vulnerabilities:

```
docker scan <IMAGE>
```

 