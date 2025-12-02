---
title: Artifact Repository Manager with Nexus
type: docs
prev: docs/NanaBootcamo/Module5
next: docs/NanaBootcamo/Module7
sidebar:
  open: true
---
 
 

Nexus supports a wide range of artifact types such as Docker images, npm packages, and Maven packages, making it a versatile choice for an artifact repository. It is easy to set up and use, although its extensive features can sometimes make the interface feel cluttered.

**Recommended use cases:**  
Use Nexus primarily for storing:
- Docker images  
- Composer (PHP) packages  
- Maven packages  

---

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