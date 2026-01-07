#!/bin/bash
# ================================================
# Update_Table.sh (FIXED - PK index)
# ================================================

UpdateTb() {

    # ===============================
    # 1. Check database connection
    # ===============================
    if [[ -z "$CURRENT_DB" ]]; then
        zenity --error \
            --title="Not Connected" \
            --text="Please connect to a database first." \
            --width=450
        return 1
    fi

    # ===============================
    # 2. Prompt user to select a table
    # ===============================
    TableUpdate=$(zenity --list \
        --title="Update Table | DB: $CURRENT_DB" \
        --text="Select table to update:" \
        --column="Table Name" \
        --width=600 \
        --height=450 \
        $(ls tables/ 2>/dev/null))

    [[ -z "$TableUpdate" ]] && return 0

    Table_file="tables/$TableUpdate"
    Metadata_file="metadata/${TableUpdate}_metadata"

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

    # ===============================
    # 3. Check if table has data
    # ===============================
    if [[ ! -s "$Table_file" ]]; then
        zenity --info \
            --title="Empty Table | DB: $CURRENT_DB" \
            --text="Table '$TableUpdate' has no data." \
            --width=450
        return 0
    fi

    # ===============================
    # 4. Read table metadata to get columns and primary key
    # ===============================
    columns=()
    primary_key=""
    pk_index=0
    current_col=""

    # FIXED: Better primary key index tracking
    while read -r line; do
        if [[ $line =~ \"Column\ Name\":\ (.*) ]]; then
            current_col="${BASH_REMATCH[1]}"
            columns+=("$current_col")
        elif [[ $line =~ \"Primary\ Key\":\ y ]]; then
            primary_key="$current_col"
            # Use array length for correct index (1-based for cut)
            pk_index=${#columns[@]}
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
    # 5. Display table and let user select a record
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

    selected_row=$("${zenity_cmd[@]}")
    [[ -z "$selected_row" ]] && return 0

    # Extract primary key value of the selected row
    pk_value=$(echo "$selected_row" | cut -d'|' -f"$pk_index")

    # ===============================
    # 6. Prompt user to select column to update
    # ===============================
    update_column=$(zenity --list \
        --title="Select Column | DB: $CURRENT_DB" \
        --text="Select column to update:\n(Primary key cannot be updated)" \
        --column="Column Name" \
        --width=400 \
        --height=300 \
        $(printf "%s\n" "${columns[@]}"))

    [[ -z "$update_column" ]] && return 0

    if [[ "$update_column" == "$primary_key" ]]; then
        zenity --error \
            --title="Invalid Operation" \
            --text="Cannot update the primary key column." \
            --width=450
        return 1
    fi

    # ===============================
    # 7. Get index of the column to update
    # ===============================
    col_index=0
    for i in "${!columns[@]}"; do
        if [[ "${columns[$i]}" == "$update_column" ]]; then
            col_index=$((i+1))  # awk columns are 1-based
            break
        fi
    done

    # ===============================
    # 8. Prompt user to enter new value
    # ===============================
    new_value=$(zenity --entry \
        --title="Update Value | DB: $CURRENT_DB" \
        --text="Enter new value for:\n\n$update_column" \
        --width=450)

    [[ $? -ne 0 ]] && return 0

    # ===============================
    # 9. Update the record in the table file
    # ===============================
    awk -F'|' -v pk="$pk_value" -v pk_i="$pk_index" \
        -v col="$col_index" -v val="$new_value" '
    BEGIN { OFS="|"; }
    {
        if ($pk_i == pk) {
            $col = val
        }
        print
    }' "$Table_file" > temp && mv temp "$Table_file"

    # ===============================
    # 10. Show success message
    # ===============================
    zenity --info \
        --title="Updated | DB: $CURRENT_DB" \
        --text="Record updated successfully." \
        --width=450
}