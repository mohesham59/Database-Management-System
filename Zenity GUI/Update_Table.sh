#!/bin/bash
# ================================================
# Update_Table.sh (Zenity GUI Version)
# ================================================

UpdateTb() {

    # Check connection
    if [[ -z "$CURRENT_DB" ]]; then
        zenity --error \
            --title="Not Connected ❌" \
            --text="Please connect to a database first." \
            --width=450
        return 1
    fi

    # Select table
    TableUpdate=$(zenity --list \
        --title="Update Table | DB: $CURRENT_DB" \
        --text="Select table to update:" \
        --column="Table Name" \
        --width=600 \
        --height=450 \
        $(ls tables/))

    [[ -z "$TableUpdate" ]] && return 0

    Table_file="tables/$TableUpdate"
    Metadata_file="metadata/${TableUpdate}_metadata"

    if [[ ! -s "$Table_file" ]]; then
        zenity --info \
            --title="Empty Table | DB: $CURRENT_DB" \
            --text="Table '$TableUpdate' has no data." \
            --width=450
        return 0
    fi

    # ===============================
    # Read metadata
    # ===============================
    columns=()
    primary_key=""
    index=0
    pk_index=0

    while read -r line; do
        if [[ $line =~ \"Column\ Name\":\ (.*) ]]; then
            columns+=("${BASH_REMATCH[1]}")
            index=$((index+1))
            current_col="${BASH_REMATCH[1]}"
        elif [[ $line =~ \"Primary\ Key\":\ y ]]; then
            primary_key="$current_col"
            pk_index=$index
        fi
    done < "$Metadata_file"

    if [[ -z "$primary_key" ]]; then
        zenity --error \
            --title="No Primary Key ❌" \
            --text="This table has no primary key." \
            --width=450
        return 1
    fi

    # ===============================
    # Select record (show full table)
    # ===============================
    zenity_cmd=(zenity --list
        --title="Select Record | DB: $CURRENT_DB"
        --text="Select the record to update:"
        --width=900
        --height=500
    )

    for col in "${columns[@]}"; do
        zenity_cmd+=(--column="$col")
    done

    while IFS='|' read -r -a row; do
        for cell in "${row[@]}"; do
            zenity_cmd+=("$cell")
        done
    done < "$Table_file"

    selected_row=$("${zenity_cmd[@]}")
    [[ -z "$selected_row" ]] && return 0

    pk_value=$(echo "$selected_row" | cut -d'|' -f"$pk_index")

    # ===============================
    # Select column to update
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
            --title="Invalid Operation ❌" \
            --text="Cannot update the primary key column." \
            --width=450
        return 1
    fi

    # ===============================
    # Get column index
    # ===============================
    col_index=0
    for i in "${!columns[@]}"; do
        if [[ "${columns[$i]}" == "$update_column" ]]; then
            col_index=$((i+1))
            break
        fi
    done

    # ===============================
    # Enter new value
    # ===============================
    new_value=$(zenity --entry \
        --title="Update Value | DB: $CURRENT_DB" \
        --text="Enter new value for:\n\n$update_column" \
        --width=450)

    [[ $? -ne 0 ]] && return 0

    # ===============================
    # Update record
    # ===============================
    awk -F'|' -v pk="$pk_value" -v pk_i="$pk_index" \
        -v col="$col_index" -v val="$new_value" '
    BEGIN { OFS="|"; }
    {
        if ($pk_i == pk) {
            $col = val;
        }
        print
    }' "$Table_file" > temp && mv temp "$Table_file"

    zenity --info \
        --title="Updated ✅ | DB: $CURRENT_DB" \
        --text="Record updated successfully." \
        --width=450
}
