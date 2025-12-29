#!/bin/bash

#-------------------------------------
#---- Create Table ----
#-------------------------------------
function CreateTb {
	while true
	do
		read -p "Enter The Table Name: " TableName

		if [[ ! "$TableName" =~ ^[a-zA-Z_] ]]; then
			echo "Error: Invalid Table Name, The Name Must Start With a Letter or Underscore."
		
		# Use '+' to require at least one character in the name
		# Avoid '*' to prevent allowing an empty name
		elif [[ ! "$TableName" =~ ^[a-zA-Z_0-9]+$ ]]; then
			echo "Error: Invalid Table Name, Contain Only Letters, Numbers, and Underscores."
		
		elif [[ -f "tables/$TableName" ]]; then
			echo -e "Warning: The Table "$TableName" Already Exists."
			echo "Try to Enter Table Name Again."	
		
		else
			touch "tables/$TableName"
			touch "metadata/$TableName.metadata"
			echo "Table "$TableName" successfuly Created"
			break
		fi
	done
	echo "======================================================"
	#----------------------------------------------------------------------------
	#----------------------------------------------------------------------------

	read -p "Enter Columns Number: " ColumnNum

	for ((i=1; i<="$ColumnNum"; i++))
	do
		# Repeat until a valid and unique column name is entered
		while true
		do
			read -p "Enter The Name of Column("$i"): " ColumnName
			if [[ ! "$ColumnName" =~ ^[a-zA-Z_] ]]; then
				echo "Error: Invalid Column Name, The Name Must Start With a Letter or Underscore."		
			
			elif [[ ! "$ColumnName" =~ ^[a-zA-Z_0-9]+$ ]]; then
				echo "Error: Invalid Table Name, Contain Only Letters, Numbers, and Underscores."
			
			else
				# Initialize a flag to check for duplicates
				exists=false
				# {} Grouping commands, store array element
				for col in "${Columns[@]}";
				do
					if [[ "$col" == "$ColumnName" ]];then
						exists=true   #If the column name already exists, set the flag to true
						break
					fi
				done
				
				# If the column already exists, prompt the user to enter a different name
				if $exists; then	
					echo -e "Warning: The Column "$ColumnName" Already Exists."
					echo "Try to Enter Column Name Again."  
				
				else
					Columns+=("$ColumnName")
					echo "Column ("$ColumnName") Added Successfully."
					break
				fi
			fi
		done

		#----------------------------------------------------------------------------
		#----------------------------------------------------------------------------
		
		while true
		do
			read -p "Enter the Data Type (Str/Int) of Coulmn ($ColumnName): " ColumnType
			
			if [[ "$ColumnType" == "str" || "$ColumnType" == "Str" || "$ColumnType" == "STR" || \
	      			"$ColumnType" == "int" || "$ColumnType" == "Int" || "$ColumnType" == "INT" ]]; then
					break
			else
				echo "Error: Invalid Column Type, The Type Must be String or Integer"
			fi
		done

		#----------------------------------------------------------------------------
		#----------------------------------------------------------------------------
		
		while true 
		do
			read -p "Is ("$ColumnName") a Primary Key (Yes/No): " ColumnPk

			if [[ "$ColumnPk" == "Yes" || "$ColumnPk" == "yes" || "$ColumnPk" == "YES" || "$ColumnPk" == "y" || "$ColumnPk" == "Y" || \
			       "$ColumnPk" == "No" || "$ColumnPk" == "no" || "$ColumnPk" == "NO" || "$ColumnPk" == "n" || "$ColumnPk" == "N" ]]; then
					break
			else
				echo "Error: Invalid Input for Primary Key, Must be Yes or No"
			fi
		done
		echo -e "\"Table Name\": $TableName\n\"Number of Columns\": ${#Columns[@]}\n\"Column Name\": $ColumnName\n\"Column Type\": $ColumnType\n\"Primary Key\": $ColumnPk\n---------" >> "metadata/$TableName.metadata"
	echo "======================================================"
	done

	echo "Table "$TableName" is Created Successfully"
	echo "======================================================"
}
