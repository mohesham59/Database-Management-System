#!/bin/bash
function DropTb {
	local  DropName
	
	read -p "Enter The Table Name to Drop it: " DropName
	
   if [[ ! -f "$HOME/DBMS/DataBase/$db_name/$DropName" ]]; then
     echo "Error: The Table "$DropName" Does not Exist."
	   
	eles
	    cd "$HOME/DBMS/DataBase/$db_name"
		rm -rf "$DropName" "$DropName".metadata
		echo "Table "$DropName" successfuly Deleted."
	fi
echo "======================================================"
}
