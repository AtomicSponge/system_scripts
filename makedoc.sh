#!/bin/sh
##################################################
#  Filename:  makedoc.sh
#  By:  Matthew Evans
#  Ver:  103021
#  See LICENSE.md for copyright information.
##################################################
#  Script to build project documentation and
#  update the main doc location.
##################################################

##################################################
#  Script variables
##################################################
#  Config folder location
CONFIG_LOCATION="$HOME/.config/system_scripts/makedoc"
#  Makedoc config file
CONFIG_FILE="makedoc.config"

#  Doxygen
#  File containing the list of Doxygen projects
DOXYGEN_LIST_FILE="doxygen.list"
#  Log filename
DOXYGEN_LOG_FILE="doxygen.log"
#  Documentation location
DOXYGEN_DOC_FOLDER="docs/html"
#  Doxyfile extension
DOXYGEN_DOC_EXTENSION=".doxyfile"

#  JSDoc
#  File containing the list of JSDoc projects
JSDOC_LIST_FILE="jsdoc.list"
#  Log filename
JSDOC_LOG_FILE="jsdoc.log"
#  Documentation location
JSDOC_DOC_FOLDER="out"

##################################################

##################################################
#  Start main script
##################################################
echo
echo "*** BUILDING PROJECT DOCUMENTATION ***"
echo

#  Load config
source "$CONFIG_LOCATION/$CONFIG_FILE"

##################################################
#  Doxygen documentation
echo "Running Doxygen documentation generation..."

#  Check if an old log exists and remove
if [ -e "$CONFIG_LOCATION/$DOXYGEN_LOG_FILE" ]; then
    echo "Deleting old log..."
    rm "$CONFIG_LOCATION/$DOXYGEN_LOG_FILE"
fi

echo "Logging to $CONFIG_LOCATION/$DOXYGEN_LOG_FILE"

#  Switch logging to file, redirect stdout and stderr
exec 3>&1 4>&2 &> "$CONFIG_LOCATION/$DOXYGEN_LOG_FILE"

#  Read in the list of projects and process each
for PROJECT in $(cat "$CONFIG_LOCATION/$DOXYGEN_LIST_FILE"); do
    pushd "$PROJECTS_LOCATION/$PROJECT"
    doxygen "$(find $PROJECTS_LOCATION/$PROJECT -maxdepth 1 -type f -name "*$DOXYGEN_DOC_EXTENSION")"
    popd
    rsync -a "$PROJECTS_LOCATION/$PROJECT/$DOXYGEN_DOC_FOLDER/" "$DESTINATION_FOLDER/$PROJECT"
done

exec 1>&3 2>&4  #  Restore stdout and stderr

##################################################
#  JSDoc documentation
echo "Running JSDoc documentation generation..."

for PROJECT in $(cat "$CONFIG_LOCATION/$JSDOC_LIST_FILE"); do
    npx jsdoc "$PROJECTS_LOCATION/$PROJECT/$PROJECT.js"
    rsync -a "$PROJECTS_LOCATION/$PROJECT/$JSDOC_DOC_FOLDER/" "$DESTINATION_FOLDER/$PROJECT"
done

echo "Done!"
echo
