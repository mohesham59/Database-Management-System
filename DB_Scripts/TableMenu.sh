#!/bin/bash

TB_menu(){
source "$HOME/DBMS/TableScripts/lib/CreateTable.sh"
source "$HOME/DBMS/TableScripts/lib/ListTable.sh"
source "$HOME/DBMS/TableScripts/lib/DropTable.sh"
#-------------------------------------
#---- Display Table Menu ----
#-------------------------------------
PS3="Please enter your choice [1-8]: "

select var in "Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "Exit"; 
do

echo "======================================================"

    # Check if input is empty or invalid
    if [[ -z "$var" ]]; then
        echo "Invalid option. Please try again."
        continue
    fi
    
    case "$var" in
        "Create Table") CreateTb  "$1"
        ;;
        
        "List Tables") ListTb "$1"
        ;;
        
        "Drop Table") DropTb "$1"
        ;;
        
        "Insert into Table") InsertTb "$1"
        ;;
        
        "Select From Table") SelectTb "$1"
        ;;
        
        "Delete From Table") DeleteFromTb "$1"
        ;;
        
        "Update Table") UpdateTb "$1"
        ;;
        
        "Exit") 
        echo "Exiting..."
        break 
        ;;
        
        *)
	echo "Invalid Option. Please try again."
	;;
    esac
done


}
