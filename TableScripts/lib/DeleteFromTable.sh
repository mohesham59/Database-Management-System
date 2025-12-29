#!/bin/bash

DeleteFromTb() {
	# Prompt the user to enter the name of the table from which data will be deleted
	read -p "Enter Table Name to Delete Data: " TableSelectDel

	# Check if the table data file exists in the 'tables/' directory
	# If not found, display an error and exit the function
	if [[ ! -f "tables/$TableSelectDel" ]]; then
		echo "Error: Table '$TableSelectDel' does not exist."
		return
	fi

	# Check if the corresponding metadata file exists in the 'metadata/' directory
	# Metadata is required to identify the primary key column
	if [[ ! -f "metadata/${TableSelectDel}.metadata" ]]; then
		echo "Error: Metadata file for '$TableSelectDel' is missing!"
		return
	fi

	# Variables to store the current column name and the primary key column name
	primary_key_column=""
	current_column=""

	# Read the metadata file line by line to find the column marked as Primary Key
	while IFS= read -r line; do
	# Match lines like: "Column Name": id
	# Extract the column name after the colon and space
	if [[ $line =~ ^\"Column\ Name\":\ (.*) ]]; then
		current_column="${BASH_REMATCH[1]}"
	# Match lines like: "Primary Key": y (case-insensitive) or Yes/YES
	# When found, set the primary key column to the last processed column name
	elif [[ $line =~ ^\"Primary\ Key\":\ ([yY]|Yes|YES) ]]; then
	   	primary_key_column="$current_column"
	    	break  # Exit the loop once the primary key is found
	fi
	done < "metadata/${TableSelectDel}.metadata"

	# If no primary key was found in the metadata, abort with an error
	if [[ -z "$primary_key_column" ]]; then
		echo "Error: No Primary Key found in table metadata."
		return
	fi

	# Display the current content of the table BEFORE any deletion
	# This helps the user see all records and verify what will be deleted
	echo "Current content of table '$TableSelectDel' (BEFORE deletion):"
	echo "======================================================"
	# Call the SelectTb function and automatically pass the table name via Here Document
	# This avoids prompting the user again for the table name
	SelectTb <<EOF
$TableSelectDel
EOF

	# Prompt the user to enter the value of the primary key for the record to delete
	read -p "Enter $primary_key_column value to delete: " pk_value

	# If the user left the value empty, cancel the operation
	if [[ -z "$pk_value" ]]; then
		echo "Operation cancelled: No value entered."
		return
	fi

	# Check if a record with the given primary key value actually exists
	# We assume the primary key is the first field and records are pipe-separated
	if ! grep -q "^$pk_value|" "tables/$TableSelectDel"; then
		echo "No record found with $primary_key_column = '$pk_value'."
		return
	fi

	# Ask for final confirmation before performing the irreversible delete
	read -p "Are you sure you want to delete this record? (y/N): " confirm
	# Only proceed if the user explicitly types 'y' or 'Y'
	if [[ ! "$confirm" =~ ^[yY]$ ]]; then
		echo "Operation cancelled."
		return
	fi

	# Perform the deletion:
	# - grep -v removes lines starting with the primary key value followed by '|'
	# - Write matching (non-deleted) lines to a temporary file
	# - Replace the original table file with the temporary one
	grep -v "^$pk_value|" "tables/$TableSelectDel" > temp_table && mv temp_table "tables/$TableSelectDel"

	# Inform the user that the deletion was successful
	echo "Record with $primary_key_column = '$pk_value' deleted successfully."
	echo "======================================================"

	# Display the updated content of the table AFTER deletion
	# This gives immediate visual feedback that the record is gone
	echo "Updated content of table '$TableSelectDel' (AFTER deletion):"
	echo "======================================================"
	SelectTb <<EOF
$TableSelectDel
EOF
}
