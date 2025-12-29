#!/usr/bin/env bash

 ConnectDb() {
	read -p "Please, Enter Database Name: " Database_connect

	local db_path="$PROJECT_ROOT/storage/databases/$Database_connect"
	read 
	if [[ ! -d "$db_path" ]]; then
		echo "Error: Database '$Database_connect' Does Not Exist."
		return 1
    fi
    	
    	mkdir -p "$db_path/tables"
    	mkdir -p "$db_path/metadata"
    	
    	cd "$db_path" 
    	echo "Connected to database: $Database_connect"
    	echo "======================================================"
    	
    	source "$PROJECT_ROOT/TableScripts/TableMenu.sh"
    	
    	cd "$PROJECT_ROOT"

}
