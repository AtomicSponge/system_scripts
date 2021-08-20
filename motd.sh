#!/bin/bash
##################################################
#  Filename:  motd.sh
#  By:  Matthew Evans
#  Ver:  032721
#  See LICENSE.md for copyright information.
##################################################
#  MOTD Script
##################################################

##################################################
#  Script variables
##################################################
#  Location of the quotes file
#  Format:
#  QUOTES=("quote1" "quote2")
QUOTES_FILE="$HOME/.config/system_scripts/quotes"
#  Define some colors
FG_GREEN="\033[0;32m"
FG_RED="\033[0;31m"
FG_YELLOW="\033[0;33m"
BG_BLACK="\033[40m"
RESET="\033[0m"

##################################################
#  Start main script
##################################################
#  Run neofetch, https://github.com/dylanaraps/neofetch
neofetch

#  Display last time backup was ran
if [ -e "$HOME"/.config/system_scripts/sysbak/lastrun ]; then
    LASTRUN=$( cat "$HOME"/.config/system_scripts/sysbak/lastrun )
    CURRENT_TIME=$( date +"%s" )
    BACKUP_TIME=$( date --date="$LASTRUN" +"%s" )
    ELAPSED_TIME=$( expr "$CURRENT_TIME" - "$BACKUP_TIME" )
    NUM_DAYS=$( expr "$ELAPSED_TIME" \/ 86400 )

    #  Format output
    if [ "$NUM_DAYS" -le 3 ]; then
        DISPLAY_COLOR="${FG_GREEN}"  # 1 - 3 days shows green
    elif [ "$NUM_DAYS" -gt 3 ] && [ "$NUM_DAYS" -lt 7 ]; then
        DISPLAY_COLOR="${FG_YELLOW}" # 4 - 6 days show yellow
    else
        DISPLAY_COLOR="${FG_RED}"    # 7+ days show red
    fi

    echo -e "${DISPLAY_COLOR}${BG_BLACK}System backup last ran on:  $LASTRUN${RESET}"
else
    echo -e "${FG_RED}${BG_BLACK}Warning! Could not determine when the last backup was executed!${RESET}"
fi

echo

#  Print a random quote
if [ -e "$QUOTES_FILE" ]; then
    source "$QUOTES_FILE"
    if [ ! -z "${QUOTES+x}" ]; then
        echo "${QUOTES[$(($RANDOM % ${#QUOTES[@]}))]}"
        echo
    fi
fi

##################################################
#  Set environment variables
##################################################
source "$HOME/.config/system_scripts/envvars"
