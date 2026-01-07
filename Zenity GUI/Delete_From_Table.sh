#!/bin/bash
# ================================================
# Delete_From_Table.sh (FIXED - Debug version)
# ================================================

DeleteFromTb() {

    # ===============================
    # 1. Check if connected to a database
    # ===============================
    if [[ -z "$CURRENT_DB" ]]; then
        zenity --error \
            --title="Not Connected" \
            --text="Please connect to a database first." \
            --width=450
        return 1
    fi

    # ===============================
    # 2. Let user select table
    # ===============================
    TableSelectDel=$(zenity --list \
        --title="Delete Record | DB: $CURRENT_DB" \
        --text="Select table:" \
        --column="Table Name" \
        --width=600 \
        --height=450 \
        $(ls tables/ 2>/dev/null))

    # If user cancels - exit
    [[ -z "$TableSelectDel" ]] && return 0

    # Define file paths
    Table_file="tables/$TableSelectDel"
    Metadata_file="metadata/${TableSelectDel}_metadata"

    # Check if files exist
    if [[ ! -f "$Table_file" ]]; then
        zenity --error --title="Table Not Found" \
            --text="Table file does not exist." --width=450
        return 1
    fi

    if [[ ! -f "$Metadata_file" ]]; then
        zenity --error --title="Metadata Missing" \
            --text="Metadata file is missing." --width=450
        return 1
    fi

    # Check if table has data
    if [[ ! -s "$Table_file" ]]; then
        zenity --info --title="Empty Table" \
            --text="Table '$TableSelectDel' has no data." --width=450
        return 0
    fi

    # ===============================
    # 3. Extract columns and primary key info from metadata
    # ===============================
    columns=()
    pk_column=""
    pk_index=0
    current_col=""
    col_counter=0

    while read -r line; do
        if [[ $line =~ \"Column\ Name\":\ (.*) ]]; then
            current_col="${BASH_REMATCH[1]}"
            ((col_counter++))
            columns+=("$current_col")
            
        elif [[ $line =~ \"Primary\ Key\":\ y ]]; then
            pk_column="$current_col"
            pk_index=$col_counter
        fi
    done < "$Metadata_file"

    # If no primary key found
    if [[ -z "$pk_column" ]]; then
        zenity --error \
            --title="No Primary Key" \
            --text="This table has no primary key." \
            --width=450
        return 1
    fi

    # ===============================
    # 4. Build Zenity table to show all rows
    # ===============================
    zenity_cmd=(zenity --list
        --title="Delete Record | DB: $CURRENT_DB"
        --text="Select the record to delete:"
        --width=900
        --height=500
        --print-column="$pk_index"
    )

    # Add column headers
    for col in "${columns[@]}"; do
        zenity_cmd+=(--column="$col")
    done

    # Read each row from table and add its cells to Zenity
    while IFS='|' read -r -a row; do
        for cell in "${row[@]}"; do
            zenity_cmd+=("$cell")
        done
    done < "$Table_file"

    # Show Zenity list and get PRIMARY KEY VALUE directly
    pk_value=$("${zenity_cmd[@]}")
    
    # Debug: Show what we got
    # zenity --info --text="DEBUG:\nPK Column: $pk_column\nPK Index: $pk_index\nPK Value: '$pk_value'" --width=400
    
    [[ -z "$pk_value" ]] && return 0

    # ===============================
    # 5. Ask for confirmation before deletion
    # ===============================
    zenity --question \
        --title="Confirm Delete | DB: $CURRENT_DB" \
        --text="Are you sure you want to delete this record?\n\n$pk_column: $pk_value\n\nThis action cannot be undone!" \
        --width=500

    [[ $? -ne 0 ]] && return 0

    # ===============================
    # 6. Delete the record - Using AWK with exact field matching
    # ===============================
    
    # Count lines before deletion
    original_lines=$(wc -l < "$Table_file")
    
    # Use AWK to filter out the matching row
    awk -F'|' -v pk_val="$pk_value" -v pk_idx="$pk_index" '
        BEGIN { OFS = "|" }
        {
            # Check if the field at pk_idx matches pk_val
            if ($pk_idx != pk_val) {
                print $0
            }
        }
    ' "$Table_file" > "${Table_file}.tmp"
    
    # Count lines after deletion
    new_lines=$(wc -l < "${Table_file}.tmp")
    
    # Verify deletion worked
    if [[ $new_lines -lt $original_lines ]]; then
        mv "${Table_file}.tmp" "$Table_file"
        
        # ===============================
        # 7. Show success message
        # ===============================
        zenity --info \
            --title="Deleted | DB: $CURRENT_DB" \
            --text="Record deleted successfully!\n\n$pk_column: $pk_value" \
            --width=450
    else
        # Deletion failed
        rm -f "${Table_file}.tmp"
        
        # Show debug info
        zenity --error \
            --title="Delete Failed" \
            --text="No matching record found.\n\nDEBUG INFO:\nPK Column: $pk_column\nPK Index: $pk_index\nPK Value: '$pk_value'\n\nTable contents:\n$(cat "$Table_file")" \
            --width=600 --height=400
        return 1
    fi
}