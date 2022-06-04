#!/bin/bash
##################################################
#  Filename:  install.sh
#  By:  Matthew Evans
#  Ver:  080821
#  See LICENSE.md for copyright information.
##################################################
#  Script to manage other workflow scripts
#
#  Creates symbolic links to workflow scripts
#  Run with --uninstall to remove links instead
#  Run with --ask to confirm each file
##################################################

##################################################
#  Script variables
##################################################
#  Default folder to install to
DEFAULT_INSTALL_LOCATION="/usr/local/bin"
#  Filenames to make symlinks to
SCRIPT_FILE_NAMES=("comment_updater.sh" "localbak.sh" "sysbak.sh")
#  Default folder to install MOTD
MOTD_INSTALL_LOCATION="/etc/profile.d"
#  MOTD script filename
MOTD_FILE_NAME="motd.sh"

##################################################
#  Function to create a confirmation prompt
#  First argument used as display text
#  Accepts ENTER, "Y" or "y" then returns true
#  All other input returns false
##################################################
confirm_prompt()
{
    read -p "$1 [Y/n]? " CONFIRM_RESULT
    CONFIRM_RESULT=${CONFIRM_RESULT:-true}
    if [ "$CONFIRM_RESULT" = true -o "$CONFIRM_RESULT" = "Y" -o "$CONFIRM_RESULT" = "y" ]; then
        true
        return
    fi
    false
    return
}

##################################################
#  Parse arguments
##################################################
RUN_UNINSTALL="false"
ASK_EACH_FILE="false"
for ARGS in "$@"; do
    #  Check if uninstall flag passed
    if [ "$ARGS" = "--uninstall" ]; then
        RUN_UNINSTALL="true"
    fi
    #  Check if ask flag passed
    if [ "$ARGS" = "--ask" ]; then
        ASK_EACH_FILE="true"
    fi
done

##################################################
#  Start main script
##################################################
echo
echo "*** Workflow script management ***"
echo

#  Get install location
read -p "Install location [$DEFAULT_INSTALL_LOCATION]: " INSTALL_LOCATION
#  If install location null, use default
INSTALL_LOCATION=${INSTALL_LOCATION:-$DEFAULT_INSTALL_LOCATION}
echo

#  Get the scripts' location
CURRENT_DIR="$( cd "$( dirname "$0" )" && pwd )"

##########################
#  Run uninstall
##########################
if [ "$RUN_UNINSTALL" = true ]; then
    echo "Removing scripts from '$INSTALL_LOCATION'..."
    #  Iterate over script filenames, deleting symlinks
    for FILENAME in "${SCRIPT_FILE_NAMES[@]}"; do
        if [ "$ASK_EACH_FILE" = false ] || (confirm_prompt "Do you want to remove '${FILENAME%.*}' from '$INSTALL_LOCATION'"); then
            rm $INSTALL_LOCATION/${FILENAME%.*}
        fi
    done

    echo "Removing MOTD script from '$MOTD_INSTALL_LOCATION'..."
    #  Now uninstall the MOTD script
    if [ "$ASK_EACH_FILE" = false ] || (confirm_prompt "Do you want to remove '${MOTD_FILE_NAME%.*}' from '$MOTD_INSTALL_LOCATION'"); then
        rm $MOTD_INSTALL_LOCATION/${MOTD_FILE_NAME}
    fi
##########################
#  Run install
##########################
else
    echo "Installing scripts to '$INSTALL_LOCATION'..."
    #  Iterate over script filenames, creating symlinks for each
    for FILENAME in "${SCRIPT_FILE_NAMES[@]}"; do
        if [ "$ASK_EACH_FILE" = false ] || (confirm_prompt "Do you want to install '${FILENAME%.*}' to '$INSTALL_LOCATION'"); then
            ln -s $CURRENT_DIR/$FILENAME $INSTALL_LOCATION/${FILENAME%.*}
            chmod u+x $INSTALL_LOCATION/${FILENAME%.*}
        fi
    done

    echo "Installing MOTD stript to '$MOTD_INSTALL_LOCATION'..."
    #  Now install the MOTD script
    if [ "$ASK_EACH_FILE" = false ] || (confirm_prompt "Do you want to install '${MOTD_FILE_NAME%.*}' to '$MOTD_INSTALL_LOCATION'"); then
        ln -s $CURRENT_DIR/$MOTD_FILE_NAME $MOTD_INSTALL_LOCATION/${MOTD_FILE_NAME}
        chmod u+x $MOTD_INSTALL_LOCATION/${MOTD_FILE_NAME}
    fi
fi

echo "Done!"
echo
