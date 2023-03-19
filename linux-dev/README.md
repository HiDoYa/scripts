# Linux Dev Sandbox
Files related to running Ubuntu workspace with Vagrant.

Add Include in ssh pointing to this ssh.config file.

Run the following two lines to skip tracking state files:
```
git update-index --skip-worktree mounted.txt
git update-index --skip-worktree ssh.config
```