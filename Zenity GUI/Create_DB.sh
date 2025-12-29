#!/bin/bash

# Function to create a new database
CreationFunction() {
    # Prompt user for database name using Zenity
    Db_Name=$(zenity --entry \
        --title="Create Database" \
        --text="Enter database name:" \
        --width=500)

    # If user cancels the dialog
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    # Validate database name: must start with letter or _, contain only letters, numbers, _
    if [[ ! "$Db_Name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || [[ -z "$Db_Name" ]]; then
        zenity --error \
            --title="Invalid Name" \
            --text="Invalid database name.\n\nRules:\n• Must start with a letter or underscore\n• Can only contain letters, numbers, and underscores\n• Cannot be empty" \
            --width=500
        return 1
    fi

    # Define database path (consistent with your main menu)
    local db_path="./Databases/$Db_Name"

    # Check if database already exists
    if [[ -d "$db_path" ]]; then
        zenity --error \
            --title="Already Exists" \
            --text="The database '<b>$Db_Name</b>' already exists." \
            --width=450
        return 1
    fi

    # Create database directory and required subfolders
    mkdir -p "$db_path/tables"
    mkdir -p "$db_path/metadata"

    # Show success message
    zenity --info \
        --title="Success" \
        --text="Database '<b>$Db_Name</b>' was created successfully! 🎉\n\nLocation: $db_path" \
        --width=500

    return 0
}
