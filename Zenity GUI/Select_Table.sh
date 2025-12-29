#!/bin/bash
# ================================================
# Select_Table.sh (Proper Table View)
# ================================================

SelectTb() {

    # Check connection
    if [[ -z "$CURRENT_DB" ]]; then
        zenity --error \
            --title="Not Connected ❌" \
            --text="Please connect to a database first." \
            --width=450
        return 1
    fi

    # Check tables
    if [[ ! -d "tables" ]] || [[ -z "$(ls -A tables/ 2>/dev/null)" ]]; then
        zenity --info \
            --title="No Tables | DB: $CURRENT_DB" \
            --text="No tables found." \
            --width=450
        return 0
    fi

    # Select table
    TableSelect=$(zenity --list \
        --title="Select From Table | DB: $CURRENT_DB" \
        --text="Select table:" \
        --column="Table Name" \
        --width=600 \
        --height=450 \
        $(ls tables/))

    [[ $? -ne 0 || -z "$TableSelect" ]] && return 0

    Table_file="tables/$TableSelect"
    Metadata_file="metadata/${TableSelect}_metadata"

    if [[ ! -s "$Table_file" ]]; then
        zenity --info \
            --title="Empty Table | DB: $CURRENT_DB" \
            --text="No data found in table:\n\n$TableSelect" \
            --width=450
        return 0
    fi

    # ===============================
    # Get column names
    # ===============================
    columns=()
    while read -r col; do
        columns+=("$col")
    done < <(awk -F': ' '/"Column Name"/ {print $2}' "$Metadata_file")

    # ===============================
    # Build zenity command dynamically
    # ===============================
    zenity_cmd=(zenity --list
        --title="Table: $TableSelect | DB: $CURRENT_DB"
        --width=800
        --height=500
    )

    # Add columns
    for col in "${columns[@]}"; do
        zenity_cmd+=(--column="$col")
    done

    # Add data rows (row by row)
    while IFS='|' read -r -a row; do
        for cell in "${row[@]}"; do
            zenity_cmd+=("$cell")
        done
    done < "$Table_file"

    # Show table
    "${zenity_cmd[@]}"
}
