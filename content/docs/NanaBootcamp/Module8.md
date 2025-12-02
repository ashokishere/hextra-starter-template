---
title:  Build Automation & CI/CD with Jenkins
type: docs
prev: docs/NanaBootcamo/Module7
next: docs/NanaBootcamo/Module9
sidebar:
  open: true
---
 

## What is Jenkins?

Jenkins is an open-source automation server written in Java. It automates tasks related to building, testing, and deploying software. It is widely used by companies like Netflix, Spotify, Google, Facebook, and Twitter.

When running Jenkins in Docker, you can:

- **Mount the Docker socket** → allows Jenkins to build Docker images.
- **Mount source code directories** → allows Jenkins to build non-dockerized apps as well.

---

## What Can Jenkins Do?

- Run tests  
- Build artifacts  
- Publish artifacts  
- Deploy artifacts  
- Send notifications  
- Integrate with other tools via plugins  

---

## Roles in Jenkins

### **Admin Role**
- Manages Jenkins
- Sets up master/agent clusters
- Installs and maintains plugins
- Performs backups and restores
- Configures global settings

### **User Role**
- Creates jobs/pipelines
- Manages project-level configurations

---

## Jenkins Plugins

Plugins extend Jenkins functionality. Common examples:

- **Docker Plugin** → build & run Docker containers  
- **Maven Plugin** → build Java applications  
- **NPM/Node Plugin** → build JavaScript applications  
- **Git Plugin** → clone repositories  
- **Credentials Binding Plugin** → manage secrets in pipelines  

You may also install build tools inside the Jenkins container or on the host machine.

---

## Jenkins Directory Structure

- **`/jobs`** → where Jenkins stores job definitions
- **`/workspace`** → where Jenkins checks out Git repositories and builds code

---

## Jenkins Jobs

A **Pipeline Job** is a scripted or declarative workflow defined using a `Jenkinsfile`.

Pipelines can be triggered by:
- Webhooks (e.g., GitHub → on push)
- Cron schedules
- Manual builds
- Upstream/downstream jobs

---

## Jenkinsfile Syntax

### Basic elements

- `pipeline {}` → top-level block  
- `agent {}` → where the pipeline will run  
- `stages {}` → contains multiple `stage {}` sections  
- `steps {}` → commands inside each stage  

### Optional features

| Feature | Usage |
|--------|-------|
| `when` | Conditional execution |
| `post` | Steps to run after pipeline (always, success, failure) |
| `tools` | Use Maven, JDK, Gradle, etc. |
| `parameters` | Build with parameters |
| `input` | Pause for manual approval |

### Parameter Types
- `string(name, defaultValue, description)`
- `choice(name, choices, description)`
- `booleanParam(name, defaultValue, description)`

---

## Credentials in Jenkins

Two primary ways to use credentials:

### **1. Bind credentials to environment variables**
Uses:  
`credentials("credentialsId")`

Requires:  

**Credentials Binding Plugin**

---

### **2. Use `withCredentials([])` block**

Example:

```groovy
withCredentials([usernamePassword(credentialsId: 'my-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
    sh 'echo $USER'
}
```

## Credential Scopes

Jenkins credentials can be stored with different visibility levels:

- **System** → Only available to the Jenkins controller (master)
- **Global** → Accessible to all jobs on the Jenkins instance
- **Project** → Scoped only to a specific multibranch or folder-level pipeline

---

## Credential Types

Jenkins supports multiple credential types:

- **Username / Password**
- **SSH Private Key**
- **API Tokens / Secret Text**
- **Secret Files**
- **X.509 Certificates**

These can be used in pipelines through:
- `environment { credentials('id') }`
- `withCredentials([]) { ... }`

---

## Jenkins Shared Library

A **Shared Library** allows you to reuse common pipeline logic across different Jenkinsfiles.

### Benefits

- **Standardizes CI/CD workflows**
- **Encourages code reuse**
- **Reduces duplicated Jenkinsfile logic**
- **Centralizes common functions and steps**

Shared libraries typically contain:

- `vars/` → Global functions
- `src/` → Structured Groovy code
- `resources/` → Templates, configs, files

---

## Versioning the Application

Most build tools use **Semantic Versioning (SemVer)**:
```
<major>.<minor>.<patch>-<suffix>

**Example:** `v1.2.3-SNAPSHOT`
```


### Version Components

| Component | Meaning |
|----------|---------|
| **Major** | Breaking changes; not backward-compatible |
| **Minor** | New features; backward-compatible |
| **Patch** | Bug fixes; no API changes |
| **Suffix** | Metadata: `SNAPSHOT`, `ALPHA`, `BETA`, `RELEASE` |

### How Pipelines Set Versions Dynamically

A Jenkins pipeline can generate or update a version based on:

- **Git commit hash**
- **Build number**
- **Timestamp**
- **Git tags**
- **Branch name**
- **Environment variables**

This is commonly done inside a Jenkinsfile using:

```groovy
def version = "1.0.${env.BUILD_NUMBER}"
def version = sh(script: "git describe --tags --always", returnStdout: true).trim()
```

