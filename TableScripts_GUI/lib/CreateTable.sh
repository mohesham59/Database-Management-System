#!/bin/bash

#-------------------------------------
#---- Create Table ----
#-------------------------------------
function CreateTb {
	while true;
	do
		read -p  "Enter Table Name: " TableName
		
		if [[ ! "$TableName" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
			echo -e "Error: Invalid Table Name, The Name Must Start With a Letter or Underscore and Contain Only Letters, Numbers, and Underscores."
			continue
		
		elif [[ -f "$TableName" ]]; then
			echo -e "Warning: The Table "$TableName" Already Exists."
			echo "Try to Enter Table Name Again."
		else
			touch "$TableName"
			touch "$TableName".metadata
			echo -e "Table "$TableName" successfuly Created"
			break
		fi
	done

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
	read -p "Enter Number of Columns: " NumColumns

	for ((i=1; i<=NumColumns; i++))
	do
		while true
		do
			read -p "Enter Name of Coiumn ("$i"): " NameColumn >> "$TableName".metadata  
			if [[ "$NameColumn" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
				break
			else
				echo "Error: Invalid Column Name, The Name Must Start With a Letter or Underscore and Contain Only Letters, Numbers, and Underscores."
			fi
		done
		
		#-------------------------------------------------------------------------------
		#-------------------------------------------------------------------------------
		
		while true
		do
			read -p "Is \"$ColumnName\" The Primary Key? (yes/no): " ColumnPK
			
	done		










}
