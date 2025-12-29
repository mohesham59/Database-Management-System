#!/usr/bin/env bash
# Check if PROJECT_ROOT variable is empty or not set
# If it is empty, calculate the project root directory dynamically
if [[ -z "$PROJECT_ROOT" ]]; then
	# ${BASH_SOURCE[0]} = full path to the current script (TableMenu.sh)
   	# dirname = extracts the directory part
    # cd .. / .. = goes up two levels from the script's location (TableScripts/ → project root)
    # pwd = prints the absolute path of the project root
    PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

# Define a helper function to safely source library scripts
# This function checks if the file exists before sourcing it
source_if_exists() {
    local file="$1"	# The full path to the script passed as argument
    if [[ -f "$file" ]]; then
        source "$file"
    else
        echo "Missing: $file"
    fi
    }


source_if_exists "$PROJECT_ROOT/TableScripts/lib/CreateTable.sh"
source_if_exists "$PROJECT_ROOT/TableScripts/lib/InsertIntoTable.sh"
source_if_exists "$PROJECT_ROOT/TableScripts/lib/ListTable.sh"
source_if_exists "$PROJECT_ROOT/TableScripts/lib/SelectFromTable.sh"  
source_if_exists "$PROJECT_ROOT/TableScripts/lib/DeleteFromTable.sh" 
source_if_exists "$PROJECT_ROOT/TableScripts/lib/UpadateTable.sh"      
 

if [[ ! -f "$PROJECT_ROOT/TableScripts/lib/CreateTable.sh" ]]; then
    echo "Critical: CreateTable.sh not found! Check folder structure."
    return 1
fi

# ========================================
#           Table Menu Banner
# ========================================
while true; do
clear
echo -e "\033[0;36m╔════════════════════════════════════════════════════════════════╗\033[0m"
echo -e "\033[0;36m║                                                                ║\033[0m"
echo -e "\033[0;36m║\033[1;33m  ████████╗ █████╗ ██████╗ ██╗     ███████╗███╗   ███╗███████╗  \033[0;36m║\033[0m"
echo -e "\033[0;36m║\033[1;33m  ╚══██╔══╝██╔══██╗██╔══██╗██║     ██╔════╝████╗ ████║██╔════╝  \033[0;36m║\033[0m"
echo -e "\033[0;36m║\033[1;33m     ██║   ███████║██████╔╝██║     █████╗  ██╔████╔██║█████╗    \033[0;36m║\033[0m"
echo -e "\033[0;36m║\033[1;33m     ██║   ██╔══██║██╔══██╗██║     ██╔══╝  ██║╚██╔╝██║██╔══╝    \033[0;36m║\033[0m"
echo -e "\033[0;36m║\033[1;33m     ██║   ██║  ██║██████╔╝███████╗███████╗██║ ╚═╝ ██║███████╗  \033[0;36m║\033[0m"
echo -e "\033[0;36m║\033[1;33m     ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝╚═╝     ╚═╝╚══════╝  \033[0;36m║\033[0m"
echo -e "\033[0;36m║                                                                ║\033[0m"
echo -e "\033[0;36m╚════════════════════════════════════════════════════════════════╝\033[0m"
echo

echo -e "\033[1;32m                Table Management Menu\033[0m"
echo -e "\033[1;35m                Current Database: $(basename "$(pwd)")\033[0m"
echo -e "\033[0;34m════════════════════════════════════════════════════════════════\033[0m"
echo "1) Create Table"
echo "2) List Tables"
echo "3) Drop Table"
echo "4) Insert into Table"
echo "5) Select From Table"
echo "6) Delete From Table"
echo "7) Update Table"
echo "8) Exit to Database Menu"
echo -e "\033[0;34m════════════════════════════════════════════════════════════════\033[0m"
echo

#-------------------------------------
#---- Display Table Menu ----
#-------------------------------------

    read -p $'\033[1;33mPlease enter your choice (1-8): \033[0m' choice

    echo -e "\033[0;34m════════════════════════════════════════════════════════════════\033[0m"

    case "$choice" in
        1)
            CreateTb
            read
            ;;
        2)
            ListTb
            read
            ;;
        3)
            DropTb
            read
            ;;
        4)
            InsertTb
            read
            ;;
        5)
            SelectTb
            read
            ;;
        6)
            DeleteFromTb
            read
            ;;
        7)
            UpdateTb
            read
            ;;
        8)
            clear
            echo -e "\033[1;32mGoodbye! Returning to Database Menu...\033[0m"
            sleep 1
            break
            ;;
        "")
            echo -e "\033[1;31mPlease enter a number from 1 to 8.\033[0m"
            ;;
        *)
            echo -e "\033[1;31mInvalid option. Please choose between 1-8.\033[0m"
            ;;
    esac

    echo
    echo -e "\033[0;34m════════════════════════════════════════════════════════════════\033[0m"
    echo
done
