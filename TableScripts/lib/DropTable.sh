#!/bin/bash
function DropTb {

	read -p "Enter The Table Name to Drop it: " DropName
	
	if [[ ! "$DropName" =~ ^[a-zA-Z_] ]]; then
		echo "Erro: Invalid Table Name, The Name Must Start With a Letter or Underscore."
	
	elif [[ ! "$DropName" =~ ^[a-zA-Z_0-9]+$ ]]; then
		echo "Error: Invalid Table Name, Contain Only Letters, Numbers, and Underscores."

	elif [[ -f "$DropName" ]]; then
		rm -rf "$DropName" "$DropName".metadata
		echo "Table "$DropName" successfuly Deleted."

	else
		echo "Error: The Table "$DropName" Does not Exist."

	fi
echo "======================================================"
}
