#!/bin/bash

function ConnectDb(){
	read -p "Please, Enter Database Name: " Database_connect

	if [[ ! "$Database_connect" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
		echo "Error: Invalid Database Name."
        	return 1
	fi
	
	local db_path="$PROJECT_ROOT/storage/databases/$Database_connect"
	
	if [[ ! -d "$db_path" ]]; then
		echo "Error: Database '$Database_connect' Does Not Exist."
		return 1
    	fi
    	
    	mkdir -p "$db_path/tables"
    	mkdir -p "$db_path/metadata"
    	
    	cd "$db_path" || exit
    	echo "Connected to database: $Database_connect"
    	echo "======================================================"
    	
    	source "$PROJECT_ROOT/TableScripts/TableMenu.sh"
    	
    	cd "$PROJECT_ROOT"

}
