#!/bin/bash
##################################################
#  Filename:  comment_updater.sh
#  By:  Matthew Evans
#  Ver:  032721
#  See LICENSE.md for copyright information.
##################################################
#
#  Script to update top comment in source code files.
#  Checks current working directory for a CONFIG_FILE.
#
#  WARNING:  Back up your code before running this!
#
##################################################
#
#  Configuration file format.
#  See bottom of script for an example.
#
#  PROJECT_LOCATION - Location of soruce files.
#  SOURCE_EXTENSION - Source file extension.
#  COMMENT_START - Start of comment block.
#  COMMENT_END - End of comment block.
#  LINE_DELIMITER - Comment block line delimiter.
#  COMMENT_TEXT - Comment text to use as an array.  Each element is a line.
#
#  Special variables for COMMENT_TEXT:
#  $CURRENT_FILENAME - Filename of current source file.
#  SYEAR - Current year.
#
##################################################

##################################################
#  Script variables
##################################################
#  Configuration filename
CONFIG_FILE=".comment_updater.config"
#  Store current year YYYY format
YEAR="$(date +%Y)"

##################################################
#  Function to update all source files recursively
##################################################
process_update()
{
    echo ""
    echo "Entering $1"
    for i in "$1"/*; do
        #  If it's a file and ends in SOURCE_EXTENSION, process
        if [ -f "$i" ] && [[ "$i" =~ "$SOURCE_EXTENSION" ]]; then
            echo -n "Updating $i... "
            CURRENT_FILENAME="$(basename $i)" # Store short filename for comments
            source "$PWD/$CONFIG_FILE" # Lazy hack to get CURRENT_FILENAME to evaluate properly

            #  First find the top comment block and remove it
            FIRST_LINE=$(grep -Fn -m 1 -h "$COMMENT_START" "$i")
            FIRST_LINE=${FIRST_LINE%:*}
            LAST_LINE=$(grep -Fn -m 1 -h "$COMMENT_END" "$i")
            LAST_LINE=${LAST_LINE%:*}
            sed -i "${FIRST_LINE},${LAST_LINE}d" "$i"

            #  Now create the new comment block at the top, writing backwards
            printf "%s\n" "$COMMENT_END" | cat - "$i" > temp && mv temp "$i"
            for ((curline=${#COMMENT_TEXT[@]}-1; curline>=0; curline--)); do
                printf "%s\n" "$LINE_DELIMITER${COMMENT_TEXT[curline]}" | cat - "$i" > temp && mv temp "$i"
            done
            printf "%s\n" "$COMMENT_START" | cat - "$i" > temp && mv temp "$i"

            echo "Done"
        fi
        #  If a directory, enter and process
        if [ -d "$i" ]; then
            process_update "$i"
        fi
    done
}

##################################################
#  Start main script
##################################################
echo
echo "*** RUNNING COMMENT UPDATER ***"
echo

#  Make sure the CONFIG_FILE is in the working directory
if [ ! -e "$PWD/$CONFIG_FILE" ]; then
    echo "Cannot find $CONFIG_FILE, exiting..."
    echo
    exit 1
fi

#  Load config file from current folder
source "$PWD/$CONFIG_FILE"

#  Verify proper variables loaded from config
if [ -z ${PROJECT_LOCATION+x} ] && \
   [ -z ${SOURCE_EXTENSION+x} ] && \
   [ -z ${COMMENT_START+x} ] && \
   [ -z ${COMMENT_END+x} ] && \
   [ -z ${LINE_DELIMITER+x} ] && \
   [ -z ${COMMENT_TEXT+x} ]
then
    echo "You must configure the Comment Updater!  See script for details."
    echo "Nothing has been updated.  Exiting..."
    echo
    exit 1
fi

#  Run the update
process_update "$PROJECT_LOCATION"

echo
echo "Comment Updater script done!"
echo

##################################################
#  Example comment_updater.config
##################################################
#PROJECT_LOCATION="$HOME/Projects/coolproject/include/coolproject"
#SOURCE_EXTENSION=".hpp"

#COMMENT_START="/*!"
#COMMENT_END=" */"
#LINE_DELIMITER=" * "

#COMMENT_TEXT=(
#    "Some Cool Project | File:  $CURRENT_FILENAME"
#    ""
#    "\author YOUR NAME"
#    "\version 0.2a"
#    "\copyright See LICENSE.md for copyright information."
#    "\date 2019-$YEAR"
#)
