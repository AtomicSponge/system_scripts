# Workflow Scripts

Workflow shell scripts to simplify some tasks.  See each script for more details.

| Filename | Description |
| -------- | ----------- |
| install.sh | Install script - see below |
| comment_updater.sh | Update initial header in source code files |
| localbak.sh | Make a local backup of the current folder |
| makedoc.sh | Build project documentation |
| motd.sh | Message of the Day script |
| sysbak.sh | Run a system backup |

## Install Script

The file install.sh can be used to install or uninstall the workflow scripts.  It just keeps them in their current directory and creates symbolic links to the chosen install location.  Defaults to *usr/local/bin/*

It will also install the MOTD script to *etc/profile.d/*

### Installation

Save the scripts in any location then run:

```
sudo sh install.sh
```

### Uninstallation

Navigate to the script folder and run:

```
sudo sh install.sh --uninstall
```
