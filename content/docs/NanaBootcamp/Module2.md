---
title: Version Control with Git
type: docs
prev: docs/NanaBootcamo/Module2
next: docs/NanaBootcamo/Module3
sidebar:
  open: true
---

## 3 - Version Control with Git

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

### Useful Additional Commands

- `git fetch` — Download changes from remote without merging them  
- `git diff` — Show differences between commits, files, or branches  
- `git tag` — Create version tags (e.g., `v1.0`)  
- `git cherry-pick <commit>` — Apply a specific commit from one branch onto another  
