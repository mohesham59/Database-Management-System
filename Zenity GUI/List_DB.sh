#!/bin/bash

# Function to list all existing databases
List_func() {
    local DB_STORAGE="./Databases"

    # Check if the Databases directory exists and has any subdirectories
    if [[ ! -d "$DB_STORAGE" ]] || [[ ! "$(ls -A "$DB_STORAGE" 2>/dev/null)" ]]; then
        zenity --info \
            --title="No Databases Found" \
            --text="There are no databases created yet.\n\nStart by creating a new database!" \
            --width=500 \
            --height=300
        return 1
    fi

    # Create a numbered list of databases
    local db_list
    db_list=$(ls -1 "$DB_STORAGE" | nl -w2 -s') ')

    # Prepare the full text to display
    local display_text="Available Databases:\n\n$db_list\n\nTotal: $(ls -1 "$DB_STORAGE" | wc -l) database(s)"

    # Display the list in a scrollable Zenity text window
    echo -e "$display_text" | zenity --text-info \
        --title="Databases List" \
        --width=600 \
        --height=500 \
        --font="mono"
}
