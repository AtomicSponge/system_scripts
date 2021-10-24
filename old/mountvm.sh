#!/bin/bash
##################################################
#  Filename:  mountvm.sh
#  By:  Matthew Evans
#  Ver:  032821
#  See LICENSE.md for copyright information.
##################################################
#
#  Script to mount and unmount VMs.
#  VM info is kept in a config file.
#
#  Uses guestmount:  https://libguestfs.org/guestmount.1.html
#
##################################################
#
# The MOUNTVM_CONFIG_FILE:
#
# VM_IMAGE_LOCATION - Folder location where VM images are stored
# VM_MOUNT_LOCATION - Location to create VM mounts
# VM_MOUNT_LIST
#   - An array with the following format:
#   - [ Filename w/o extension ] [ VM mount point ]
#
# See bottom for an example.
#
##################################################

##################################################
#  Script variables
##################################################
#  Config file location
MOUNTVM_CONFIG_LOCATION="$HOME/.config/system_scripts/mountvm"
#  Config filename
MOUNTVM_CONFIG_FILE="mountvm.config"
#  VM file extension
VM_EXT=".qcow2"

##################################################
#  Parse arguments
##################################################
MOUNTVM_DO_UNMOUNT="false"
MOUNTVM_DISPLAY_LIST="false"
MOUNTVM_READ_ONLY="false"
for ARGS in "$@"; do
    #  Check if list flag passed
    if [ "$ARGS" = "--list" ]; then
        MOUNTVM_DISPLAY_LIST="true"
    #  Check if read only flag passed
    elif [ "$ARGS" = "--ro" ]; then
        MOUNTVM_READ_ONLY="true"
    #  Parse any single flag - arguments
    elif [[ "$ARGS" =~ ^-.* ]]; then  #  Check for - flag
        for i in $(seq 1 ${#ARGS}); do
            #  -u flag passed, do unmount
            if [ "${ARGS:i-1:1}" = "u" ]; then
                MOUNTVM_DO_UNMOUNT="true"
            fi
        done
    else  #  Not a flag, so let's store it as the VM name
        VM_NAME="$ARGS"
    fi
done

##################################################
#  Start main script
##################################################
#  Make sure MOUNTVM_CONFIG_FILE exists
if [ ! -e "$MOUNTVM_CONFIG_LOCATION/$MOUNTVM_CONFIG_FILE" ]; then
    echo "Cannot find '$MOUNTVM_CONFIG_LOCATION/$MOUNTVM_CONFIG_FILE'!"
    echo "See script for details.  Exiting..."
    echo
    exit 1
fi

#  Load config file
source "$MOUNTVM_CONFIG_LOCATION/$MOUNTVM_CONFIG_FILE"

#  Verify proper variables loaded from config
if [ -z ${VM_IMAGE_LOCATION+x} ] && \
   [ -z ${VM_MOUNT_LOCATION+x} ] && \
   [ -z ${VM_MOUNT_LIST+x} ]
then
    echo "You must configure mountvm!  See script for details.  Exiting..."
    echo
    exit 1
fi
#  Test for VM images
if [ ! -e "$VM_IMAGE_LOCATION" ]; then
    echo "Can't find VM images at '$VM_IMAGE_LOCATION'!"
    echo "See script for details.  Exiting..."
    echo
    exit 1
fi
#  Test for VM mount location
if [ ! -e "$VM_MOUNT_LOCATION" ]; then
    echo "Can't find VM mount points at '$VM_MOUNT_LOCATION'!"
    echo "See script for details.  Exiting..."
    echo
    exit 1
fi
#  Make sure VM_MOUNT_LIST contains an even number of elements
if [ $(( "${#VM_MOUNT_LIST[@]}" % 2 )) != 0 ]; then
    echo "VM_MOUNT_LIST not configured correctly!"
    echo "See script for details.  Exiting..."
    echo
    exit 1
fi

###################################
#  Display the VM list
###################################
if [ "$MOUNTVM_DISPLAY_LIST" = true ]; then
    echo "Configured VM mounts:"
    echo
    echo "[ Name ] : [ Mount Point ]"
    for (( i=0; i < "${#VM_MOUNT_LIST[@]}"; i=i+2 )); do
        echo "${VM_MOUNT_LIST[$i]} : ${VM_MOUNT_LIST[$i+1]}"
    done
    echo
###################################
#  Otherwise process mount/unmount
###################################
else
    ##############################
    #  Some final checks...
    ##############################
    #  Make sure a VM name was passed
    if [ -z ${VM_NAME+x} ]; then
        echo "Must pass a VM name!  Exiting..."
        echo
        exit 1
    fi
    #  Make sure the VM file exists
    if [ ! -e "$VM_IMAGE_LOCATION/$VM_NAME$VM_EXT" ]; then
        echo "Cannot find VM '$VM_IMAGE_LOCATION/$VM_NAME$VM_EXT'!  Exiting..."
        echo
        exit 1
    fi
    #  Check for the VM name in the list and get its mount point
    for (( i=0; i < "${#VM_MOUNT_LIST[@]}"; i=i+2 )); do
        if [ "${VM_MOUNT_LIST[$i]}" = "$VM_NAME" ]; then
            VM_MOUNT_POINT="${VM_MOUNT_LIST[$i+1]}"
        fi
    done
    #  Make sure the mount point was found
    if [ -z ${VM_MOUNT_POINT+x} ]; then
        echo "Mount point for '$VM_NAME' not configured!  Exiting..."
        echo
        exit 1
    fi
    #  Make sure the mount location exists
    if [ ! -e "$VM_MOUNT_LOCATION/$VM_NAME" ]; then
        #  It doesn't, try creating it
        mkdir "$VM_MOUNT_LOCATION/$VM_NAME"
        #  Check again, error if it still does not.
        if [ ! -e "$VM_MOUNT_LOCATION/$VM_NAME" ]; then
            echo "Cannot access mount point '$VM_MOUNT_LOCATION/$VM_NAME'!  Exiting..."
            echo
            exit 1
        fi
    fi

    ##############################
    #  MOUNT / UNMOUNT
    ##############################
    #  Run unmount
    if [ "$MOUNTVM_DO_UNMOUNT" = true ]; then
        echo -n "Unmounting $VM_IMAGE_LOCATION/$VM_NAME$VM_EXT from $VM_MOUNT_LOCATION/$VM_NAME... "
        guestunmount "$VM_MOUNT_LOCATION/$VM_NAME"
    #  Run mount
    else
        #  Mount read only
        if [ "$MOUNTVM_READ_ONLY" = true ]; then
            echo -n "Mounting $VM_IMAGE_LOCATION/$VM_NAME$VM_EXT to $VM_MOUNT_LOCATION/$VM_NAME as read only... "
            guestmount -a "$VM_IMAGE_LOCATION/$VM_NAME$VM_EXT" -m "$VM_MOUNT_POINT" --ro "$VM_MOUNT_LOCATION/$VM_NAME"
        #  Mount read/write
        else
            echo -n "Mounting $VM_IMAGE_LOCATION/$VM_NAME$VM_EXT to $VM_MOUNT_LOCATION/$VM_NAME... "
            guestmount -a "$VM_IMAGE_LOCATION/$VM_NAME$VM_EXT" -m "$VM_MOUNT_POINT" "$VM_MOUNT_LOCATION/$VM_NAME"
        fi
    fi
fi
echo "Done!"
echo

##################################################
#  Example MOUNTVM_CONFIG_FILE:
##################################################
#
# VM_IMAGE_LOCATION="$HOME/.local/share/libvirt/images"
# VM_MOUNT_LOCATION="$HOME/vmmount"
#
# VM_MOUNT_LIST=(
#     "myvm_one" "/dev/sda2"
#     "myvm_two" "/dev/sda1"
# )
