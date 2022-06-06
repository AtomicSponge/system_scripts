#!/bin/bash
##################################################
#  Filename:  sysbak.sh
#  By:  Matthew Evans
#  Ver:  082521
#  See LICENSE.md for copyright information.
##################################################
#
#  System backup script
#
#  Requires:
#  https://www.passwordstore.org/
#  https://rclone.org/
#
##################################################

##################################################
#  Script variables
##################################################
#  Location to store backup config file (see below for format)
BACKUP_CONFIG_LOCATION="$HOME/.config/system_scripts/sysbak"
#  Name of backup config file
BACKUP_CONFIG_FILE="sysbak.config"
#  Root location to run backup from (should probably be home)
BACKUP_ROOT_LOCATION="$HOME"
#  Log filename for packages
PACKAGE_LOG_FILE="installed_packages.list"
#  Location to save installed package list
PACKAGE_LOG_LOCATION="$HOME/.config/sysbak"
#  Logging level (see rclone docs)
LOGGING_LEVEL="INFO"

##################################################
#  Import config
##################################################
#
#  Example:
#  BACKUP_NAME="backup" - rclone backup name to use
#  BACKUP_LIST=("test1" "test2") - list of folders to copy
#  RCLONE_PASSWORD_COMMAND="pass rclone/config" - passwordstore command
#
##################################################
#  Make sure config file exists
if [ -e "$BACKUP_CONFIG_LOCATION/$BACKUP_CONFIG_FILE" ]; then
    source "$BACKUP_CONFIG_LOCATION/$BACKUP_CONFIG_FILE"
else
    echo "Config file not found!  See script for details."
    echo "Please create a $BACKUP_CONFIG_FILE file in $BACKUP_CONFIG_LOCATION"
    echo "Nothing has been backed up.  Exiting..."
    echo
    exit 1
fi

#  If the proper variables were not configured, fail
if [ -z ${BACKUP_NAME+x} ] && [ -z ${BACKUP_LIST+x} ] && [ -z ${RCLONE_PASSWORD_COMMAND+x} ]; then
    echo "You must configure a backup to run!  See script for details."
    echo "Nothing has been backed up.  Exiting..."
    echo
    exit 1
fi

##################################################
#  Parse arguments
##################################################
DO_BACKUP_PACKAGE_LIST="false"
for ARGS in "$@"; do
    if [[ $ARGS =~ ^-.* ]]; then
        for i in $(seq 1 ${#ARGS}); do
            if [ "${ARGS:i-1:1}" = "p" ]; then
                DO_BACKUP_PACKAGE_LIST="true"
            fi
        done
    fi
done

##################################################
#  Start main script
##################################################
echo
echo "*** RUNNING SYSTEM BACKUP ***"

#  Optional:  back up installed package list
if [ "$DO_BACKUP_PACKAGE_LIST" = true ]; then
    echo
    echo "Creating installed package list..."
    if [ -e "$PACKAGE_LOG_LOCATION/$PACKAGE_LOG_FILE" ]; then
        echo "Deleting old list..."
        rm "$PACKAGE_LOG_LOCATION/$PACKAGE_LOG_FILE"
    fi
    pacman -Q | awk '{print $1}' > "$PACKAGE_LOG_LOCATION/$PACKAGE_LOG_FILE"
    echo "Installed package list created."
fi

echo
echo "Backing up user data..."
#  If log folder doesn't exist, create it.
if [ ! -e "$BACKUP_CONFIG_LOCATION/logs/" ]; then
    mkdir "$BACKUP_CONFIG_LOCATION"/logs
fi
#  If log folder still can't be found, throw error and exit.
if [ ! -e "$BACKUP_CONFIG_LOCATION/logs/" ]; then
    echo "Error!  Can't find log folder '$BACKUP_CONFIG_LOCATION/logs/'!"
    echo "Exiting..."
    echo
    exit 1
fi
#  Run the rclone backups
for ITEM in "${BACKUP_LIST[@]}"; do
    #  Check if old log exists and remove
    if [ -e "$BACKUP_CONFIG_LOCATION/logs/$ITEM.log" ]; then
        rm "$BACKUP_CONFIG_LOCATION/logs/$ITEM.log"
    fi
    #  Saftey check for folder
    if [ -d "$BACKUP_ROOT_LOCATION/$ITEM" ]; then
        #  Start rclone process &
        rclone --log-file="$BACKUP_CONFIG_LOCATION/logs/$ITEM.log" --log-level "$LOGGING_LEVEL" --skip-links --ask-password=false --password-command "$RCLONE_PASSWORD_COMMAND" sync "$BACKUP_ROOT_LOCATION/$ITEM" "$BACKUP_NAME:$ITEM" &
    else
        echo "$BACKUP_ROOT_LOCATION/$ITEM not found!" > "$BACKUP_CONFIG_LOCATION/logs/$ITEM.log"
    fi
done
echo "User data backup started.  Results will be written in the logs."

#  Record time script last executed
date > "$BACKUP_CONFIG_LOCATION"/lastrun

echo "System Backup Script Done!"
echo
