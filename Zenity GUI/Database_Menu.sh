#!/bin/bash

# Directory to store all databases
DB_ROOT="./Databases"
mkdir -p "$DB_ROOT"

# Load all function files
source ./Create_DB.sh
source ./List_DB.sh
source ./Drop_DB.sh
source ./Connect_DB.sh


# Main menu loop - keeps running until exit
while true
do
    choice=$(zenity --list \
        --title="🐘 Bash DBMS" \
        --width=600 \
        --height=500 \
        --column="Option" --column="Description" \
        1 "Create Database" \
        2 "List Databases" \
        3 "Connect To Database" \
        4 "Drop Database" \
        5 "Exit")

    # If user clicks Cancel or closes the window → show goodbye and exit
    if [[ $? -ne 0 ]]; then
        zenity --info --width=450 --height=250 --title="Goodbye" --text="Thank you for using Bash DBMS 👋\nSee you soon!"
        exit 0
    fi

    case "$choice" in
        1)
            CreationFunction
            ;;
        2)
            List_func
            ;;
        3)
            ConnectDb
            ;;
        4)
            Drop_func
            ;;
        5)
            zenity --width=400 --height=200 --info --title="Exit" --text="Thank you for using Bash DBMS 👋"
            exit 0
            ;;
        *)
            zenity --width=400 --height=200 --error --title="Error" --text="Invalid selection!\nPlease choose a number from 1 to 5."
            ;;
    esac
done
