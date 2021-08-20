#!/bin/sh
##################################################
#  Filename:  makedoc.sh
#  By:  Matthew Evans
#  Ver:  032721
#  See LICENSE.md for copyright information.
##################################################
#  Script to build project documentation and
#  update the main doc location.
##################################################

##################################################
#  Script variables
##################################################
#  Project folder location
PROJECTS_LOCATION="$HOME/Projects"
#  Config folder location
CONFIG_LOCATION="$HOME/.config/system_scripts/makedoc"
#  File containing the list of projects
PROJECTS_LIST_FILE="projects.list"
#  Log filename
LOG_FILE="makedoc.log"
#  Documentation location
DOC_FOLDER="docs/html"
#  Doxyfile extension
DOC_EXTENSION=".doxyfile"
#  Folder to copy documentation to
DESTINATION_FOLDER="$HOME/Projects/wtfsystems.github.io/docs"
##################################################

##################################################
#  Start main script
##################################################
echo
echo "*** BUILDING PROJECT DOCUMENTATION ***"
echo

#  Check if an old log exists and remove
if [ -e "$CONFIG_LOCATION/$LOG_FILE" ]; then
    echo "Deleting old log..."
    rm "$CONFIG_LOCATION/$LOG_FILE"
fi

echo "Logging to $CONFIG_LOCATION/$LOG_FILE"

#  Switch logging to file, redirect stdout and stderr
exec 3>&1 4>&2 &> "$CONFIG_LOCATION/$LOG_FILE"

#  Read in the list of projects and process each
for PROJECT in $(cat "$CONFIG_LOCATION/$PROJECTS_LIST_FILE"); do
    #  Run documentation generation for each project
    pushd $PROJECTS_LOCATION/$PROJECT
    doxygen "$(find $PROJECTS_LOCATION/$PROJECT -maxdepth 1 -type f -name "*$DOC_EXTENSION")"
    popd
    #  Now copy over the files
    rsync -a "$PROJECTS_LOCATION/$PROJECT/$DOC_FOLDER/" "$DESTINATION_FOLDER/$PROJECT"
done

exec 1>&3 2>&4  #  Restore stdout and stderr
echo "Done!"
echo
