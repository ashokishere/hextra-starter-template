---
title: Containers with Docker
type: docs
prev: docs/NanaBootcamo/Module7
next: docs/NanaBootcamo/Module8
sidebar:
  open: true
---
  

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

 