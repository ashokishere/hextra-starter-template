---
title: Build Tools and Package Manager Tools
type: docs
prev: docs/NanaBootcamo/Module3
next: docs/NanaBootcamo/Module4
sidebar:
  open: true
---
 
# Docker &amp; Containerization

### Why Docker?

Docker simplifies packaging and running applications by using container images.

Benefits of Docker:
- **Consistency:** Same image runs on any machine (local, CI, or production).
- **Isolation:** Each container runs in its own environment.
- **Simplifies Dev → Test → Prod pipeline:** Same artifact (image) is used everywhere.
- **Reduces number of artifact types:** You can ship one artifact (the Docker image) instead of many language-specific ones.
- **Easy rollbacks:** Versioned images make deployments more controlled and repeatable.

In short, Docker makes applications portable, consistent, and easier to manage across different environments.

---

### 1\. Introduction to Containers &amp; Docker

* **Definition of Docker**: Docker is an **open-source containerization platform** that allows developers to package applications alongside all necessary dependencies and configuration files into standardized containers[1].
* **Definition of a Container**: A container is a **portable, isolated, and standardized artifact** designed for seamless software development, shipment, and deployment across diverse environments[1].
* **Core Benefits**:
  * Eliminates "it works on my machine" issues by standardizing application runtimes[1][2].
  * Reduces server configuration overhead—production servers only require a container runtime installed rather than individual application dependencies (such as Node.js, Java, or specific database versions)[3][4].
  * Simplifies single-artifact delivery, replacing multiple moving file types (JAR, WAR, ZIP) with a single **Docker Image** artifact[3][5].

---

### 2\. Containers vs. Virtual Machines (VMs)

Both containers and Virtual Machines are virtualization tools, but they operate at different layers of abstraction[6]:

* **Virtual Machines**:
  * **Hardware-level abstraction**: A hypervisor creates virtual CPUs, RAM, and storage from host computer resources[7].
  * Each VM includes a complete copy of a **Guest Operating System**[6].
  * **OS Compatibility**: Any OS VM can run on top of any physical host OS machine via hypervisors like Oracle VM VirtualBox[7][8].
* **Docker Containers**:
  * **Application-layer abstraction**: Containers share the physical host system's **OS Kernel** rather than running separate OS instances[6].
  * **Size &amp; Speed**: Docker images are significantly smaller in size, and containers launch almost instantaneously compared to VMs[6].
  * **OS Compatibility**: Linux containers cannot run directly on a Windows host kernel natively; however, **Docker Desktop** bridges this on Windows and macOS using lightweight virtualization[4][8].

---

### 3\. Application Lifecycle: Before vs. After Docker

#### **Application Development**

* **Before Containers**: Installation procedures differed across each developer's OS environment, leading to complex setup guides and dependency version conflicts[2].
* **After Containers**: Developers launch identical isolated environments with **1 single command**[2][9]. Running multiple versions of the same service (e.g., two different PostgreSQL versions) on one local computer becomes effortless[2][9].

#### **Application Deployment**

* **Before Containers**: Extensive manual server configuration was necessary, accompanied by written deployment guides that often caused misunderstandings between Developers and Operations teams[2][4].
* **After Containers**: Developers and Operations collaborate to package the application inside a container[4]. Deployment servers need no manual dependency setup—only a **Container Runtime** is required[4].

---

### 4\. Core Concepts: Docker Image vs. Docker Container

* **Docker Image**: The actual static file package or **artifact** consisting of multiple read-only layers (typically starting from a lightweight Linux Base Image with application layers stacked on top)[6][10]. Images are portable and remain in a non-running state[6].
* **Docker Container**: The **running instance** defined by an image[4][6]. Containers execute the application inside an isolated virtual file system with mapped network ports[4].

---

### 5\. Docker Architecture &amp; Engine Components

The **Docker Engine** is a single application providing complete container lifecycle management[8][11]:

1. **Docker CLI (Command Line Interface)**: The client user interface for executing Docker commands[8][11].
2. **Docker Server (Daemon)**: Manages container lifecycles, pulls images, builds images, handles data persistence, and configures container networking[8][11].
3. **Docker API**: Intermediary interface enabling communication between the CLI and the Docker Server[8][11].

#### **Lightweight Tooling Alternatives**

If specialized modular tools are preferred over the full Docker Engine[11]:

* **Container Runtimes**: `containerd`, `CRI-O`[11][12].
* **Image Building Tool**: `buildah`[11].

---

### 6\. Essential Docker CLI &amp; Debug Commands

#### **Main Commands**

* `docker pull `: Downloads a container image from a remote repository[11].
* `docker run `: Creates and executes a new container from an image[11].
* `docker run -d `: Executes a container in **detached mode** (in the background)[13].
* `docker run -p

### What is an artifact?

An **artifact** is a file produced during a build process. It can be a binary or source bundle used for deploying or distributing an application.

Examples of artifacts include:
- **JAR** files (Java)
- **WAR** files (Java web applications)
- **npm packages** (Node.js)
- **Docker images**

Artifacts are the output of your build pipeline and are essential for packaging and deploying applications.

---

### What is inside a JAR file?

A **JAR (Java ARchive)** file is essentially a ZIP file that contains:

- **Compiled `.class` files**  
- **Resource files** (images, configs, etc.)
- **A manifest file `MANIFEST.MF`**

The manifest file provides metadata such as:
- Main class (entry point)
- Version information
- Dependencies (sometimes)

Different ecosystems use different manifest-like files:
- **Maven**: `pom.xml`
- **Node.js**: `package.json`

These files describe the project structure, dependencies, and build instructions.

---

### What is an artifactory and why do we need it?

An **artifactory** is a repository manager used to store and manage artifacts generated by build tools.

Popular examples:
- **Nexus Repository**
- **JFrog Artifactory**
- **GitHub Packages**

Why we need an artifactory:
- Central storage for build outputs
- Version control for artifacts
- Dependency management
- Secure and reliable distribution of binary files
- Supports multiple repository types (Maven, npm, Docker, PyPI, etc.)

For example, Nexus can store:
- Built JAR/WAR files
- Third-party dependencies
- Docker images
- Helm charts
- Python wheels

---


