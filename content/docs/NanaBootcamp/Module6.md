---
title: Artifact Repository Manager with Nexus
type: docs
prev: docs/NanaBootcamo/Module5
next: docs/NanaBootcamo/Module7
sidebar:
  open: true
---
 


# Sonatype Nexus Repository Manager

 

Nexus supports a wide range of artifact types such as Docker images, npm packages, and Maven packages, making it a versatile choice for an artifact repository. It is easy to set up and use, although its extensive features can sometimes make the interface feel cluttered.

**Recommended use cases:**  
Use Nexus primarily for storing:
- Docker images  
- Composer (PHP) packages  
- Maven packages  


### 1\. Overview &amp; Core Concepts

* **Artifact Repository Manager**: A private central storage location for build artifacts (compiled single-file applications like JAR, WAR, ZIP, TAR files, and Docker images) produced by continuous integration pipelines[1][2].
* **Purpose**: Decouples application source code from compiled build artifacts, making binaries available for automated deployment across development, staging, and production environments[1][2].
* **Key Functionality**: Supports hosting private internal company artifacts and proxying public artifact repositories so software development teams can fetch all dependencies from a single central source[2].
* **Component vs Asset**:
  * **Component**: An abstract term referring to the item or package version uploaded and managed in Nexus (1 component contains 1 or more assets)[3].
  * **Asset**: The actual physical binary file or package stored on disk within a component (e.g., a `.jar`, `.pom`, `.tar.gz`, or container image layer file)[3].

---

### 2\. Supported Formats &amp; Repository Types

#### **Supported Package Formats**

Nexus supports technology-specific repository formats, including **maven2** (Java JAR/WAR artifacts), **docker** (Docker container images), **nuget** (.NET packages), Python packages, npm, and more[2].

#### **Repository Types**

* **Hosted**: Used for hosting company-internal build artifacts and private software packages[4].
* **Proxy**: Acts as an intermediary to remote public repositories (such as Maven Central), caching fetched dependencies locally to speed up future downloads and guarantee availability[2][4].
* **Group**: Combines multiple repositories (both hosted and proxy repositories) under a single URL endpoint so build tools can query one aggregated location[4].

---

### 3\. Installation &amp; Configuration on Linux (DigitalOcean Cloud Server)

#### **System Requirements &amp; Network Setup**

* **Server Specifications**: Minimum of **4 GB RAM, 2 CPUs, and 160 GB SSD disk** space (e.g., an Ubuntu Cloud Droplet)[6].
* **Network Ports**: Open **SSH port 22** for administration and **HTTP port 8081** on the server firewall to access the Nexus web UI from a browser[4].
* **Java Requirement**: **Java 8 JRE** (`openjdk-8-jre-headless`)[6][8].

#### **Directory Architecture**

When extracted into `/opt`, Nexus creates two primary directories[6][8]:

1. **Nexus Application Directory** (`nexus-3.xx.x-01`): Contains the application runtime, executables, and internal configuration[6].
2. **Sonatype Work Directory** (`sonatype-work/nexus3/`): Stores user configuration, logs, blob stores, uploaded files, metadata, and temporary files (this directory should be targeted for backups)[6].

#### **Installation Procedure &amp; CLI Commands**

```
# Update package index and install Java 8 JRE and net-tools
apt update
apt install openjdk-8-jre-headless net-tools -y

# Download and extract Nexus in /opt
cd /opt
wget https://download.sonatype.com/nexus/3/latest-unix.tar.gz
tar -zxvf latest-unix.tar.gz

# Best Practice: Create dedicated 'nexus' system user (services should not run as root)
adduser nexus

# Set folder ownership to nexus user
chown -R nexus:nexus nexus-3.35.0-01
chown -R nexus:nexus sonatype-work

# Configure Nexus service to run as nexus user
vim nexus-3.35.0-01/bin/nexus.rc
# Add line: run_as_user="nexus"

# Switch to nexus user and start application
su - nexus
/opt/nexus-3.35.0-01/bin/nexus start

# Verify running process
ps aux | grep nexus

```

*(Source citations:*[6]*)*

---

### 4\. Deployment via Docker

Nexus can also be run as a containerized application[10][11]:

1. Install Docker on the host server[10].
2. Create a named **Docker Volume** to persist the `sonatype-work` data directory on the host host system[10].
3. Launch the container using the official `sonatype/nexus3` image, mapping port `8081`[10][12].

---

### 5\. Publishing Artifacts &amp; Integration

#### **Maven &amp; Gradle Integration**

Build tools (like Maven or Gradle) publish compiled binaries directly to Nexus using native commands (`mvn publish` or Gradle publish tasks)[5][13].

* **Configuration**: The project build configuration (`pom.xml` or `build.gradle`) must be updated with the Nexus repository URL and credentials[5][14].
* **User Roles**: Create a dedicated user in Nexus with artifact upload permissions rather than using the default `admin` account[4][15].

#### **Private Docker Registry Setup**

To use Nexus as a private Docker registry[11][16]:

1. Create a **Hosted Docker Repository** in Nexus[16].
2. Create a dedicated **User Role** for the Docker repository[16].
3. Configure a **Repository Connector** port (e.g., port **8083**) and open port 8083 on the firewall[16].
4. Enable **Docker Bearer Token Realm** under Realm Security settings in Nexus[16].
5. Add `insecure-registries` for the Nexus host IP and port in the Docker daemon configuration (`daemon.json`) if using HTTP[16][17].
6. Log in and push images via standard Docker CLI commands[16]:

```
docker login
```


### Proxy Repository Capabilities

Nexus can act as a proxy for external repositories like **npmjs** and **Maven Central**.

**Benefits of using Nexus as a proxy:**
- You download packages once, and Nexus caches them.
- Teams pull dependencies from your Nexus instance instead of the internet.
- Improves reliability and speeds up builds.
- Helps in restricted or air-gapped environments.

When a package is fetched from an external repository, it is stored inside Nexus and becomes available locally.

---

### REST API Support

Nexus provides a powerful REST API that allows automation of artifact uploads, downloads, repository management, and querying. This is very useful for CI/CD pipelines and automated build systems.

#### API Examples

**List all repositories**

```sh
curl -u user:pwd -X GET 'http://{host}:8081/service/rest/v1/repositories'
```

**List all components in a specific repository**

```sh
curl -u user:pwd -X GET 'http://{host}:8081/service/rest/v1/components?repository=<INSERT_REPO>'
``` 


**List all assets for a specific component**

```sh
curl -u user:pwd -X GET 'http://{host}:8081/service/rest/v1/components/<ID>'
```
 


**Multi-Tenancy Support**

Nexus supports multi-tenancy, allowing you to create multiple repositories for different teams or projects.

**Key advantages:**

Isolate artifacts per team or environment.

Assign fine-grained access control using roles and user accounts.

Improve security by limiting who can push or pull artifacts.

**Running Nexus in Docker**

Nexus can run inside a Docker container, which offers:

Faster setup and portability.

Easy integration with Kubernetes.

Consistent deployments across environments.

Running Nexus in a container is particularly useful for CI/CD or local development environments.

Nexus is a robust and flexible artifact repository manager that can streamline artifact storage, caching, and distribution within modern DevOps workflows.

