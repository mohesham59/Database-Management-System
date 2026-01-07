#!/bin/bash
# ================================================
# Create_Table.sh (FIXED - Single PK enforcement)
# Fixed: paths, duplicate columns, single PK only
# ================================================

CreateTb() {
    # Ensure subdirs exist
    mkdir -p tables metadata

    # Array to track column names (prevent duplicates)
    declare -a existing_columns
    
    # FIXED: Declare PK flag OUTSIDE the loop
    primary_key_set=""

    # Loop for valid table name
    while true; do
        table_name=$(zenity --entry \
            --title="Create Table" \
            --text="Enter Table Name:\n(Rules: letter/_ start, letters/numbers/_ only)" \
            --width=500)

        if [[ $? -ne 0 ]]; then
            return 1
        fi

        if [[ ! "$table_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || -z "$table_name" ]]; then
            zenity --error --title="Invalid Name" \
                --text="Invalid Table Name!\nMust start with letter/_, letters/numbers/_ only." \
                --width=450
            continue
        fi

        if [[ -f "tables/$table_name" ]]; then
            zenity --warning --title="Already Exists" \
                --text="Table '$table_name' already exists in tables/!" \
                --width=450
            return 1
        fi

        break
    done

    # Create files in correct paths
    touch "tables/$table_name"
    touch "metadata/${table_name}_metadata"
    zenity --info --title="Table Files Created" \
        --text="Created:\n- tables/$table_name\n- metadata/${table_name}_metadata" \
        --width=450

    # Number of columns
    while true; do
        numColumns=$(zenity --entry \
            --title="Table Structure" \
            --text="Enter Number of Columns (>0):" \
            --width=450)

        if [[ $? -ne 0 ]]; then
            zenity --warning --title="Cancelled" --text="Table creation cancelled."
            rm -f "tables/$table_name" "metadata/${table_name}_metadata"
            return 1
        fi

        if [[ "$numColumns" =~ ^[0-9]+$ && "$numColumns" -gt 0 ]]; then
            break
        else
            zenity --error --title="Invalid" --text="Must be positive integer!"
        fi
    done

    # For each column
    for ((i=1; i<=numColumns; i++)); do
        # Column Name
        while true; do
            columnName=$(zenity --entry \
                --title="Column $i / $numColumns" \
                --text="Enter Name for Column $i:\n(letter/_ start, letters/numbers/_ only)" \
                --width=500)
            
            if [[ $? -ne 0 ]]; then
                zenity --warning --title="Cancelled" --text="Table creation cancelled."
                rm -f "tables/$table_name" "metadata/${table_name}_metadata"
                return 1
            fi
            
            if [[ ! "$columnName" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || -z "$columnName" ]]; then
                zenity --error --title="Invalid Name" --text="Invalid Column Name!"
                continue
            fi
            
            # Check for duplicate column names
            is_duplicate=false
            for existing_col in "${existing_columns[@]}"; do
                if [[ "$columnName" == "$existing_col" ]]; then
                    zenity --error --title="Duplicate Column" \
                        --text="Column '$columnName' already exists!\nPlease choose a different name." \
                        --width=450
                    is_duplicate=true
                    break
                fi
            done
            
            if [[ "$is_duplicate" == true ]]; then
                continue
            fi
            
            # Add to existing columns
            existing_columns+=("$columnName")
            break
        done

        # Column Type
        columnType=$(zenity --list \
            --title="Column $i: $columnName" \
            --text="Select Data Type:" \
            --width=400 --height=200 \
            --column="Type" "str" "int" \
            --print-column=1)

        if [[ $? -ne 0 || -z "$columnType" ]]; then
            columnType="str"
        fi

        # FIXED: Primary Key - Only ask if no PK has been set yet
        if [[ -z "$primary_key_set" ]]; then
            pk_choice=$(zenity --list \
                --title="Column $i: $columnName ($columnType)" \
                --text="Is this column the Primary Key?\n(Only one column can be PK)" \
                --width=450 --height=250 \
                --column="Choice" \
                "Yes (Set as Primary Key)" \
                "No" \
                --print-column=1)

            if [[ $? -ne 0 ]]; then
                columnPK="n"
            elif [[ "$pk_choice" == "Yes"* ]]; then
                columnPK="y"
                primary_key_set="$columnName"  # Store which column is PK
                zenity --info --title="Primary Key Set" \
                    --text="Column '$columnName' is now the Primary Key.\n\nRemaining columns will automatically be set as non-PK." \
                    --width=450
            else
                columnPK="n"
            fi
        else
            # PK already set - automatically set to "n"
            columnPK="n"
        fi

        # Append to metadata
        {
            echo "\"Column Name\": $columnName"
            echo "\"Column Type\": $columnType"
            echo "\"Primary Key\": $columnPK"
            echo "-----"
        } >> "metadata/${table_name}_metadata"
    done

    # FIXED: Verify that at least one PK was set
    if [[ -z "$primary_key_set" ]]; then
        zenity --warning \
            --title="No Primary Key" \
            --text="Warning: No primary key was set for this table.\n\nSome operations may not work correctly without a primary key." \
            --width=500
    fi

    # Success
    zenity --info \
        --title="Success" \
        --text="Table '$table_name' created with $numColumns columns!\n\nPrimary Key: ${primary_key_set:-None}\n\n- Data: tables/$table_name\n- Schema: metadata/${table_name}_metadata" \
        --width=500
}