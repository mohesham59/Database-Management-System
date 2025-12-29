#!/bin/bash
# ================================================
# TableMenu.sh (Updated - Fixed cd issue)
# ================================================


# Source table functions from ROOT (pwd=DB dir → ../../)
source ./Create_Table.sh
source ./List_Table.sh
source ./Drop_Table.sh
source ./Insert_Table.sh
source ./Select_Table.sh
source ./Delete_From_Table.sh
source ./Update_Table.sh

# Zenity-based Table Menu
TableMenu() {
    while true; do
        choice=$(zenity --list \
            --title="📋 Table Manager | DB: $CURRENT_DB" \
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

        # If user clicks Cancel or closes → exit table menu and go back to ROOT
        if [[ $? -ne 0 ]]; then
            cd ../../  # Back to project root: Databases/db1 → Databases → root
            zenity --info --width=450 --height=200 --title="Back" --text="Returned to Database Menu 👋"
            return 0
        fi

        case "$choice" in
            1)
                CreateTb  # Placeholder or your function
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
                cd ../../  # Back to project root
                zenity --info --width=450 --height=200 --title="Exit Table Menu" --text="Back to Database Menu 😎"
                return 0
                ;;
            *)
                zenity --error --width=400 --height=200 --title="Error" --text="Invalid selection!\nPlease choose from 1 to 8."
                ;;
        esac
    done
}
