#!/bin/bash
# ================================================
# Delete_From_Table.sh (Zenity GUI Version)
# ================================================

DeleteFromTb() {

    # Check connection
    if [[ -z "$CURRENT_DB" ]]; then
        zenity --error \
            --title="Not Connected ❌" \
            --text="Please connect to a database first." \
            --width=450
        return 1
    fi

    # Select table
    TableSelectDel=$(zenity --list \
        --title="Delete Record | DB: $CURRENT_DB" \
        --text="Select table:" \
        --column="Table Name" \
        --width=600 \
        --height=450 \
        $(ls tables/))

    [[ -z "$TableSelectDel" ]] && return 0

    Table_file="tables/$TableSelectDel"
    Metadata_file="metadata/${TableSelectDel}_metadata"

    # ===============================
    # Get columns + PK index
    # ===============================
    columns=()
    pk_column=""
    pk_index=0
    index=0

    while read -r line; do
        if [[ $line =~ \"Column\ Name\":\ (.*) ]]; then
            columns+=("${BASH_REMATCH[1]}")
            current_col="${BASH_REMATCH[1]}"
            index=$((index+1))
        elif [[ $line =~ \"Primary\ Key\":\ y ]]; then
            pk_column="$current_col"
            pk_index=$index
        fi
    done < "$Metadata_file"

    if [[ -z "$pk_column" ]]; then
        zenity --error \
            --title="No Primary Key ❌" \
            --text="This table has no primary key." \
            --width=450
        return 1
    fi

    # ===============================
    # Build zenity table
    # ===============================
    zenity_cmd=(zenity --list
        --title="Delete Record | DB: $CURRENT_DB"
        --text="Select the record to delete:"
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

    # Extract PK value from selected row
    pk_value=$(echo "$selected_row" | cut -d'|' -f"$pk_index")

    # ===============================
    # Confirmation
    # ===============================
    zenity --question \
        --title="Confirm Delete ⚠️ | DB: $CURRENT_DB" \
--text="Are you sure you want to delete this record?\n\n<b>$pk_column</b>: <b>$(echo "$selected_row" | cut -d'|' -f$pk_index)</b>\n\nThis action <b>cannot be undone</b>!" \
        --width=500

    [[ $? -ne 0 ]] && return 0

    # ===============================
    # Delete record
    # ===============================
    grep -v "^$pk_value|" "$Table_file" > temp && mv temp "$Table_file"

    zenity --info \
        --title="Deleted ✅ | DB: $CURRENT_DB" \
        --text="Record deleted successfully." \
        --width=400
}
