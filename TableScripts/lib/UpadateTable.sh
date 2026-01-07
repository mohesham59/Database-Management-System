#!/bin/bash

UpdateTb() {
    # Prompt the user to enter the name of the table they want to update
    read -p "Enter Table name to update: " TableUpdate

    # Check if the table name is empty; if so, display an error and exit the function
    if [[ -z "$TableUpdate" ]]; then
        echo "Error: Table name cannot be empty."
        return 1
    fi

    # Define the full paths for the table data file and its metadata file
    # using the standard folder structure (tables/ and metadata/)
    local table_file="tables/$TableUpdate"
    local metadata_file="metadata/$TableUpdate.metadata"

    # Verify that both the table data file and the metadata file exist
    # If either is missing, show an error and exit the function
    if [[ ! -f "$table_file" || ! -f "$metadata_file" ]]; then
        echo "Error: Table '$TableUpdate' or its metadata not found."
        return 1
    fi

    # FIXED: Check if table is empty
    if [[ ! -s "$table_file" ]]; then
        echo "Table '$TableUpdate' is empty. No records to update."
        return 0
    fi

    # Display a separator line for better visual organization
    echo "======================================================"
    # Show the current contents of the table before any changes are made
    # This helps the user see the existing data and verify the record they want to update
    echo "Current content of table '$TableUpdate':"
    echo "======================================================"
    # Call the SelectTb function to display the full table
    # Use a Here Document to automatically pass the table name without prompting the user again
    SelectTb <<EOF
$TableUpdate
EOF

    # Initialize variables to store column names, the primary key column, and the current column being processed
    local columns=()
    local pk_column=""
    local current_column=""

    # Read the metadata file line by line to extract column names and identify the primary key
    while IFS= read -r line; do
        # Skip empty lines or separator lines (e.g., "-----")
        [[ -z "$line" || "$line" == "-----" ]] && continue
        
        # Remove all double quotes from the line for easier parsing
        line="${line//\"/}"
        
        # Match lines that define a column name (e.g., "Column Name": id)
        # Extract the name after the colon and store it in current_column and the columns array
        if [[ "$line" == "Column Name":* ]]; then
            current_column="${line#*: }"
            columns+=("$current_column")
        # Match lines that mark a column as the primary key (case-insensitive 'y' or 'Y')
        # When found, set pk_column to the most recently processed column name
        elif [[ "$line" == "Primary Key":*([[:space:]])y* || "$line" == "Primary Key":*([[:space:]])Y* ]]; then
            pk_column="$current_column"
        fi
    done < "$metadata_file"

    # If no primary key was identified in the metadata, abort with an error
    if [[ -z "$pk_column" ]]; then
        echo "Error: No Primary Key found in metadata."
        return 1
    fi

    # Inform the user which column is the primary key
    echo "Primary Key Column: $pk_column"
    # List all available columns for reference
    echo "Available Columns:"
    for col in "${columns[@]}"; do
        echo " - $col"
    done
    echo "======================================================"

    # Prompt the user to enter the primary key value of the record they wish to update
    read -p "Enter $pk_column value to update: " pk_value

    # If the user provided an empty value, cancel the operation
    if [[ -z "$pk_value" ]]; then
        echo "Operation cancelled."
        return 1
    fi

    # Check if a record with the given primary key value exists in the table
    # If not, display a message and exit the function
    if ! grep -q "^$pk_value|" "$table_file"; then
        echo "No record found with $pk_column = '$pk_value'."
        return 1
    fi

    # Display the specific record that will be updated for user confirmation
    echo "Record to be updated:"
    grep "^$pk_value|" "$table_file"
    echo "======================================================"

    # Prompt the user to enter the name of the column they want to modify
    read -p "Enter column name to update: " column_name

    # Verify that the entered column name exists in the table's columns
    if [[ ! " ${columns[*]} " =~ " $column_name " ]]; then
        echo "Error: Column '$column_name' not found."
        return 1
    fi

    # Prevent modification of the primary key column to maintain data integrity
    if [[ "$column_name" == "$pk_column" ]]; then
        echo "Error: Cannot update the Primary Key column."
        return 1
    fi

    # Prompt the user for the new value to assign to the selected column
    read -p "Enter new value for '$column_name': " new_value

    # Determine the 1-based index of the target column in the pipe-separated record
    local col_index=0
    for i in "${!columns[@]}"; do
        if [[ "${columns[i]}" == "$column_name" ]]; then
            col_index=$((i + 1))  # awk uses 1-based field numbering
            break
        fi
    done

    # Use awk to perform the in-place update:
    # - Split fields by '|'
    # - When the first field matches the primary key value, replace the target column with the new value
    # - Print all lines (updated or unchanged)
    # - Redirect output to a temporary file, then replace the original table file
    awk -F'|' -v OFS='|' -v pk="$pk_value" -v col="$col_index" -v new="$new_value" '
    BEGIN { found = 0 }
    $1 == pk {
        $col = new
        found = 1
    }
    { print }
    END {
        if (!found) {
            print "Error: Record not found for update." > "/dev/stderr"
            exit 1
        }
    }' "$table_file" > temp_table
    
    # FIXED: Check if awk succeeded
    if [[ $? -ne 0 ]]; then
        rm -f temp_table
        echo "Update failed."
        return 1
    fi
    
    mv temp_table "$table_file"

    # Confirm successful update to the user
    echo "Record updated successfully!"
    echo -e "══════════════════════════════════════════════════════\n══════════════════════════════════════════════════════"

    # Display the updated table contents for immediate visual feedback
    echo "Updated content of table '$TableUpdate':"
    echo "======================================================"
    SelectTb <<EOF
$TableUpdate
EOF

    # Pause execution until the user presses Enter, allowing them to review the changes
    read -p "Press Enter to continue..."
}