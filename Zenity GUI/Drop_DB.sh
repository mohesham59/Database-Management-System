#!/bin/bash

# Function to drop (delete) an existing database
Drop_func() {
    # Check if there are any databases to delete
    if [[ ! "$(ls -A "./Databases" 2>/dev/null)" ]]; then
        zenity --info \
            --title="No Databases" \
            --text="There are no databases available to delete.\nCreate one first!" \
            --width=450
        return 1
    fi

    # Show list of existing databases and let user select one
    D_name=$(zenity --list \
        --title="Drop Database" \
        --text="Select the database you want to delete:" \
        --column="Database Name" \
        --width=600 \
        --height=400 \
        $(ls -1 "./Databases"))

    # If user cancels selection
    if [[ -z "$D_name" ]]; then
        return 1
    fi

    # Define full path to the selected database
    local Db_path="./Databases/$D_name"

    # Confirmation dialog before deletion
    if zenity --question \
        --title="Confirm Deletion" \
        --text="Are you <b>SURE</b> you want to delete the database:\n\n<b>$D_name</b>\n\nThis action <b>cannot be undone</b>!" \
        --width=500 \
        --height=200; then
        
        # Perform deletion
        rm -rf "$Db_path"
        
        # Success message (replaces the one in main menu)
        zenity --warning \
            --title="Database Dropped" \
            --text="Database '<b>$D_name</b>' has been permanently deleted." \
            --width=450
    else
        # User clicked No or Cancel
        zenity --info \
            --title="Cancelled" \
            --text="Deletion of '<b>$D_name</b>' was cancelled.\nNo changes made." \
            --width=450
    fi

    return 0
}
