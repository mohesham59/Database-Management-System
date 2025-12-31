#!/bin/bash
# ================================================
# Update_Table.sh (Zenity GUI Version)
# Allows updating a specific column value in a table
# ================================================

UpdateTb() {

    # ===============================
    # 1️⃣ Check database connection
    # ===============================
    if [[ -z "$CURRENT_DB" ]]; then
        zenity --error \
            --title="Not Connected" \
            --text="Please connect to a database first." \
            --width=450
        return 1
    fi

    # ===============================
    # 2️⃣ Prompt user to select a table
    # ===============================
    TableUpdate=$(zenity --list \
        --title="Update Table | DB: $CURRENT_DB" \
        --text="Select table to update:" \
        --column="Table Name" \
        --width=600 \
        --height=450 \
        $(ls tables/))

    [[ -z "$TableUpdate" ]] && return 0  # Exit if no table selected

    Table_file="tables/$TableUpdate"                   # Data file
    Metadata_file="metadata/${TableUpdate}_metadata"  # Schema file

    # ===============================
    # 3️⃣ Check if table has data
    # ===============================
    if [[ ! -s "$Table_file" ]]; then
        zenity --info \
            --title="Empty Table | DB: $CURRENT_DB" \
            --text="Table '$TableUpdate' has no data." \
            --width=450
        return 0
    fi

    # ===============================
    # 4️⃣ Read table metadata to get columns and primary key
    # ===============================
    columns=()       # Array to store column names
    primary_key=""   # Name of primary key column
    index=0          # Index for iterating
    pk_index=0       # Index of primary key column

    while read -r line; do
        # Match lines containing column names
        if [[ $line =~ \"Column\ Name\":\ (.*) ]]; then
            columns+=("${BASH_REMATCH[1]}")
            index=$((index+1))
            current_col="${BASH_REMATCH[1]}"
        # Check if this column is primary key
        elif [[ $line =~ \"Primary\ Key\":\ y ]]; then
            primary_key="$current_col"
            pk_index=$index
        fi
    done < "$Metadata_file"

    if [[ -z "$primary_key" ]]; then
        zenity --error \
            --title="No Primary Key" \
            --text="This table has no primary key." \
            --width=450
        return 1
    fi

    # ===============================
    # 5️⃣ Display table and let user select a record
    # ===============================
    zenity_cmd=(zenity --list
        --title="Select Record | DB: $CURRENT_DB"
        --text="Select the record to update:"
        --width=900
        --height=500
    )

    # Add column headers
    for col in "${columns[@]}"; do
        zenity_cmd+=(--column="$col")
    done

    # Add all rows from table file
    while IFS='|' read -r -a row; do
        for cell in "${row[@]}"; do
            zenity_cmd+=("$cell")
        done
    done < "$Table_file"

    selected_row=$("${zenity_cmd[@]}")  # Show Zenity list and get selected row
    [[ -z "$selected_row" ]] && return 0   # Exit if no row selected

    # Extract primary key value of the selected row
    pk_value=$(echo "$selected_row" | cut -d'|' -f"$pk_index")

    # ===============================
    # 6️⃣ Prompt user to select column to update
    # ===============================
    update_column=$(zenity --list \
        --title="Select Column | DB: $CURRENT_DB" \
        --text="Select column to update:\n(Primary key cannot be updated)" \
        --column="Column Name" \
        --width=400 \
        --height=300 \
        $(printf "%s\n" "${columns[@]}"))

    [[ -z "$update_column" ]] && return 0  # Exit if no column selected

    if [[ "$update_column" == "$primary_key" ]]; then
        zenity --error \
            --title="Invalid Operation" \
            --text="Cannot update the primary key column." \
            --width=450
        return 1
    fi

    # ===============================
    # 7️⃣ Get index of the column to update
    # ===============================
    col_index=0
    for i in "${!columns[@]}"; do
        if [[ "${columns[$i]}" == "$update_column" ]]; then
            col_index=$((i+1))  # awk columns are 1-based
            break
        fi
    done

    # ===============================
    # 8️⃣ Prompt user to enter new value
    # ===============================
    new_value=$(zenity --entry \
        --title="Update Value | DB: $CURRENT_DB" \
        --text="Enter new value for:\n\n$update_column" \
        --width=450)

    [[ $? -ne 0 ]] && return 0  # Exit if user cancels

    # ===============================
    # 9️⃣ Update the record in the table file
    # ===============================
    awk -F'|' -v pk="$pk_value" -v pk_i="$pk_index" \
        -v col="$col_index" -v val="$new_value" '
    BEGIN { OFS="|"; }  # Output field separator
    {
        if ($pk_i == pk) {  # Match row using primary key
            $col = val       # Update target column with new value
        }
        print                # Print the row (updated or unchanged)
    }' "$Table_file" > temp && mv temp "$Table_file"  # Save changes

    # ===============================
    # 10️⃣ Show success message
    # ===============================
    zenity --info \
        --title="Updated | DB: $CURRENT_DB" \
        --text="Record updated successfully." \
        --width=450
}
