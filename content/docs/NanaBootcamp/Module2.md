---
title: Version Control with Git
type: docs
prev: docs/NanaBootcamo/Module2
next: docs/NanaBootcamo/Module3
sidebar:
  open: true
---


# Git Version Control System

---

### 1\. Overview &amp; Core Concepts of Version Control

* **Definition**: Version control (also known as "source control") is the practice of tracking and managing changes to software source code and configuration files over time.
* **Core Purpose**: Enables multiple developers and DevOps engineers to work simultaneously on a shared codebase without overwriting each other's work.
* **Historical Tracking**: Keeps a detailed audit log of every modification, labeling changes with descriptive commit messages and allowing teams to revert back to previous working versions if issues occur.
* **Repository Architecture**:
  * **Remote Git Repository**: Central location hosted on the cloud or a private server (e.g., GitHub, GitLab) where the authoritative source code resides.
  * **Local Git Repository**: An exact, complete copy of the repository stored locally on each developer's machine.
  * **Git Client**: The interface (Command Line Tool or Graphical User Interface) used to interact with Git and execute version control commands.

---

### 2\. The Three States &amp; Workflow Architecture

Git manages files across three primary local areas before synchronizing with a remote server:

```
  +-------------------+        git add        +-------------------+
  | Working Directory |  ------------------&gt;  |   Staging Area    |
  +-------------------+                       +-------------------+
                                                        |
                                                        | git commit
                                                        v
  +-------------------+       git push        +-------------------+
  | Remote Repository |  &lt;------------------  | Local Repository  |
  +-------------------+                       +-------------------+

```

1. **Working Directory**: The active local directory on your filesystem where you create and edit files.
2. **Staging Area**: An intermediate area where changes are prepared (`git add`) to be included in the next commit snapshot.
3. **Local Repository**: The local `.git` storage database where finalized snapshots (`git commit`) are permanently recorded.
4. **Remote Repository**: The central server where local commits are published (`git push`) or downloaded (`git pull`).

---

### 3\. Repository Setup &amp; Essential Commands

#### **Authentication &amp; Local Configuration**

* **SSH Key Pair Authentication**: Securely connects local Git clients to remote platforms (GitHub/GitLab) by keeping the secret Private Key on the local machine and uploading the Public SSH Key to the remote platform profile.
* **User Identity Configuration**:

```
git config --global user.name "Your Name"
git config --global user.email "user@example.com"

```

Ensures all committed changes are accurately attributed to the author.

#### **Initialization &amp; Cloning**

* `git init`: Initializes a brand new Git repository inside an existing local folder.
* `git remote add origin


### Git Commands

- `git clone <repo>` — Create a local copy of a remote repository  
- `git add <file>` — Stage file(s) for commit  
- `git commit -m "message"` — Commit staged changes  
- `git log` — View commit history  
- `git push` — Upload local commits to a remote repo  
- `git pull` — Fetch + merge changes from remote to local  
- `git init` — Initialize a new Git repository  
- `git remote add origin <remote_repo>` — Link local repo to remote  
- `git push --set-upstream origin master` — Set upstream and push first time  
- `git checkout <branch>` — Switch branches  
- `git checkout -b <branch>` — Create + switch to new branch  
- `git branch` — List local branches  
- `git branch -d <branch>` — Delete a branch  
- `git status` — Show working directory and staging area status  
- `git rebase` — Move commits to a new base (cleaner history)  
- `git rm -r --cached <folder>` — Remove folder from Git tracking  
- `git rm --cached <file>` — Remove file from Git tracking  
- `git stash` — Save uncommitted changes temporarily  
- `git stash pop` — Restore stashed changes  
- `git reset --hard HEAD~1` — Revert last commit & discard changes  
- `git reset HEAD~1` — Undo commit but keep working directory changes  
- `git commit --amend` — Modify the previous commit  
- `git push --force` — Force-push changes  
- `git revert <commit_hash>` — Create a new commit to undo an earlier commit  
- `git merge <branch>` — Merge another branch into the current one  
- `git fetch` — Download changes from remote without merging them  
- `git diff` — Show differences between commits, files, or branches  
- `git tag` — Create version tags (e.g., `v1.0`)  
- `git cherry-pick <commit>` — Apply a specific commit from one branch onto another  

---

### Remove Git From a Project

Delete the `.git` folder to remove Git tracking:

```bash
rm -fr .git
```

### Git Best Practices

- **One branch per feature** (feature isolation)
- **Use a `dev` branch** as an intermediary before merging into `main`/`master`
- **Create pull/merge requests** for code review
- **Delete feature branches after merging** to keep the repository clean
- **Use a `.gitignore` file** to avoid tracking unwanted files  
  *(e.g., logs, build artifacts, secrets)*

---

### Extra Useful Concepts (Optional Enhancements)

#### Branching Model Examples

**Git Flow**
- Uses multiple branches:  
  - `main`  
  - `develop`  
  - `feature/*`  
  - `release/*`  
  - `hotfix/*`

**GitHub Flow**
- Simpler model:  
  - Work directly from `main`  
  - Create short-lived feature branches  
  - Use pull requests  
  - Deploy from `main`

---

 

