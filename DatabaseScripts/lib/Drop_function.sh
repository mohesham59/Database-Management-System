#!/usr/bin/env bash
#============== source partion =============== 
source "$PROJECT_ROOT/DatabaseScripts/lib/validation.sh"

Drop_func(){
    
local D_name
List_func
echo ""
read -p "Please Enter the DataBase Name that you to Delete :" D_name
local Db_path="$PROJECT_ROOT/storage/databases/$D_name"
echo ""
if [[ ! -e "$Db_path" ]]; then
    echo "The Data Base $D_name not created yet to delete  "
 else
        local check 
        read -p "are you sure you want to delete this data base ? (yes no) " check
        check=$(echo "$check" | tr '[:upper:]' '[:lower:]')
        case "$check" in 
            yes)
                rm -rf "$Db_path"
                return 0;;
            no)
                return 0;;
            *)
                echo "not a valed choise use only yes or no :) "
        esac
    return 0


fi

}
