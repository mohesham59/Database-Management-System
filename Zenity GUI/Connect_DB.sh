#!/bin/bash
# ================================================
# Connect_DB.sh
# ================================================

# Source the TableMenu file (to make TableMenu available)
source ./Table_Menu.sh

# Function to connect to an existing database
ConnectDb() {
    # Get database name from user using Zenity
    Database_connect=$(zenity --entry \
        --title="Connect To Database" \
        --text="Please enter the database name:" \
        --width=500)

    # If user cancels or closes the dialog
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    # Validate database name: must start with letter or _, and contain only letters, numbers, _
    if [[ ! "$Database_connect" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        zenity --error \
            --title="Invalid Name" \
            --text="Error: Invalid database name.\nMust start with a letter or underscore\nand contain only letters, numbers, or underscores." \
            --width=450
        return 1
    fi

    # Define database path (consistent with your main menu)
    local db_path="./Databases/$Database_connect"

    # Check if database exists
    if [[ ! -d "$db_path" ]]; then
        zenity --error \
            --title="Not Found" \
            --text="Error: Database '$Database_connect' does not exist." \
            --width=450
        return 1
    fi

    # Create subdirectories if they don't exist (tables and metadata)
    mkdir -p "$db_path/tables"
    mkdir -p "$db_path/metadata"

    # Change to database directory
    cd "$db_path" || {
        zenity --error --title="Error" --text="Failed to enter database directory."
        return 1
    }
    
    CURRENT_DB="$Database_connect"
    export CURRENT_DB
    
    # Show success message
    zenity --info \
        --title="Connection Successful" \
        --text="Connected to database: <b>$CURRENT_DB</b>\n\nYou can now manage tables." \
        --width=500

    # Call the Table Menu
    TableMenu
}
