#!/bin/bash
# ================================================
# Table_Menu.sh (FIXED - Proper sourcing)
# Fixed: Sourcing files when pwd changes to DB directory
# ================================================

# FIXED: Get the absolute path to the script directory
# This allows sourcing files even when pwd changes to Databases/dbname/
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source table functions using absolute paths
source "$SCRIPT_DIR/Create_Table.sh"
source "$SCRIPT_DIR/List_Table.sh"
source "$SCRIPT_DIR/Drop_Table.sh"
source "$SCRIPT_DIR/Insert_Table.sh"
source "$SCRIPT_DIR/Select_Table.sh"
source "$SCRIPT_DIR/Delete_From_Table.sh"
source "$SCRIPT_DIR/Update_Table.sh"

# Zenity-based Table Menu
TableMenu() {
    while true; do
        choice=$(zenity --list \
            --title="Table Manager | DB: $CURRENT_DB" \
            --width=650 \
            --height=550 \
            --column="Option" --column="Description" \
            1 "Create Table" \
            2 "List Tables" \
            3 "Drop Table" \
            4 "Insert into Table" \
            5 "Select From Table" \
            6 "Delete From Table" \
            7 "Update Table" \
            8 "Exit to DB Menu")

        # If user clicks Cancel or closes - exit table menu
        if [[ $? -ne 0 ]]; then
            # FIXED: Return to script root directory
            cd "$SCRIPT_DIR" || {
                zenity --error --text="Failed to return to main directory"
                return 1
            }
            zenity --info --width=450 --height=200 --title="Back" --text="Returned to Database Menu"
            return 0
        fi

        case "$choice" in
            1)
                CreateTb
                ;;
            2)
                ListTb
                ;;
            3)
                DropTb
                ;;
            4)
                InsertTb
                ;;
            5)
                SelectTb
                ;;
            6)
                DeleteFromTb
                ;;
            7)
                UpdateTb
                ;;
            8)
                # FIXED: Return to script root directory
                cd "$SCRIPT_DIR" || {
                    zenity --error --text="Failed to return to main directory"
                    return 1
                }
                zenity --info --width=450 --height=200 --title="Exit Table Menu" --text="Back to Database Menu"
                return 0
                ;;
            *)
                zenity --error --width=400 --height=200 --title="Error" --text="Invalid selection!\nPlease choose from 1 to 8."
                ;;
        esac
    done
}