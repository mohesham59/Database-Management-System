#!/bin/bash
# ================================================
# Delete_From_Table.sh (Zenity GUI Version)
# ================================================
# Function to delete a record from a table in the current database using Zenity GUI

DeleteFromTb() {

    # ===============================
    # 1️⃣ Check if connected to a database
    # ===============================
    if [[ -z "$CURRENT_DB" ]]; then
        # If CURRENT_DB is empty → no connection
        zenity --error \
            --title="Not Connected ❌" \
            --text="Please connect to a database first." \
            --width=450
        return 1  # Exit function with error code
    fi

    # ===============================
    # 2️⃣ Let user select table
    # ===============================
    TableSelectDel=$(zenity --list \
        --title="Delete Record | DB: $CURRENT_DB" \
        --text="Select table:" \
        --column="Table Name" \
        --width=600 \
        --height=450 \
        $(ls tables/))  # List all tables in the tables/ folder

    # If user cancels → exit
    [[ -z "$TableSelectDel" ]] && return 0

    # Define file paths
    Table_file="tables/$TableSelectDel"
    Metadata_file="metadata/${TableSelectDel}_metadata"

    # ===============================
    # 3️⃣ Extract columns and primary key info from metadata
    # ===============================
    columns=()      # Array to store column names
    pk_column=""    # Store the name of the primary key column
    pk_index=0      # Store index of primary key column (used for deletion)
    index=0         # Counter for column index

    # Read metadata file line by line
    while read -r line; do
        # Check for column name line
        if [[ $line =~ \"Column\ Name\":\ (.*) ]]; then
            columns+=("${BASH_REMATCH[1]}")  # Add column name to array
            current_col="${BASH_REMATCH[1]}" # Temporarily store current column
            index=$((index+1))               # Increase column index
        # Check if this column is primary key
        elif [[ $line =~ \"Primary\ Key\":\ y ]]; then
            pk_column="$current_col"         # Store current column as PK
            pk_index=$index                  # Store its index
        fi
    done < "$Metadata_file"

    # If no primary key found → cannot delete safely
    if [[ -z "$pk_column" ]]; then
        zenity --error \
            --title="No Primary Key ❌" \
            --text="This table has no primary key." \
            --width=450
        return 1
    fi

    # ===============================
    # 4️⃣ Build Zenity table to show all rows
    # ===============================
    zenity_cmd=(zenity --list
        --title="Delete Record | DB: $CURRENT_DB"
        --text="Select the record to delete:"
        --width=900
        --height=500
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

    # Show Zenity list and get selected row
    selected_row=$("${zenity_cmd[@]}")
    [[ -z "$selected_row" ]] && return 0  # Exit if user cancels

    # ===============================
    # 5️⃣ Extract primary key value of selected row
    # ===============================
    pk_value=$(echo "$selected_row" | cut -d'|' -f"$pk_index")  # Get PK column value

    # ===============================
    # 6️⃣ Ask for confirmation before deletion
    # ===============================
    zenity --question \
        --title="Confirm Delete ⚠️ | DB: $CURRENT_DB" \
        --text="Are you sure you want to delete this record?\n\n<b>$pk_column</b>: <b>$(echo "$selected_row" | cut -d'|' -f$pk_index)</b>\n\nThis action <b>cannot be undone</b>!" \
        --width=500

    [[ $? -ne 0 ]] && return 0  # Exit if user cancels

    # ===============================
    # 7️⃣ Delete the record from table
    # ===============================
    # Keep all rows that do NOT match the primary key value
    grep -v "^$pk_value|" "$Table_file" > temp && mv temp "$Table_file"

    # ===============================
    # 8️⃣ Show success message
    # ===============================
    zenity --info \
        --title="Deleted ✅ | DB: $CURRENT_DB" \
        --text="Record deleted successfully." \
        --width=400
}
