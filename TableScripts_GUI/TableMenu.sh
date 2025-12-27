#!/bin/bash

source "$(dirname "$0")/lib/CreateTable.sh"

#-------------------------------------
#---- Display Table Menu ----
#-------------------------------------

while true
do
    var=$(zenity --list \
        --width=450 \
        --height=380 \
        --title="Table Menu" \
        --text="Choose an Option From the List" \
        --column="Options" \
        "Create Table" \
        "List Tables" \
        "Drop Table" \
        "Insert into Table" \
        "Select From Table" \
        "Delete From Table" \
        "Update Table" \
        "Exit")

# Check if the previous command (zenity) failed or was canceled
# $? : exit status of the last executed command
# $? = 0  → success or user selected option
# $? ≠ 0 → cancel or failed
# -ne 0 : means the command did NOT exit successfully
# -z "$var" : checks if the variable is empty (no option selected)	
    if [[ $? -ne 0 || -z "$var" ]]; then
        zenity --width=450 --height=100 --info --text="Operation  canceled by  user"
        exit
    fi

    case "$var" in
        "Create Table") CreateTb ;;
        "List Tables") ListTb ;;
        "Drop Table") DropTb ;;
        "Insert into Table") InsertTb ;;
        "Select From Table") SelectTb ;;
        "Delete From Table") DeleteFromTb ;;
        "Update Table") UpdateTb ;;
        "Exit") exit ;;
        *)
            zenity --width=450 --height=100 --error --text="Invalid Option. Please try again."
            ;;
    esac
done
