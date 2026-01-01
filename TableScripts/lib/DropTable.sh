#!/bin/bash
function DropTb {
	local  DropName
	
	read -p "Enter The Table Name to Drop it: " DropName

	if [[ ! "$DropName" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
		echo "Error: Invalid Table Name."
		return
    	fi

	
	if [[ -f "tables/$DropName" ]]; then
		rm -f "tables/$DropName"
		rm -f "metadata/$DropName.metadata"
		echo "Table '$DropName' successfully deleted."
	else

		echo "Error: The Table "$DropName" Does not Exist."

	fi


}
