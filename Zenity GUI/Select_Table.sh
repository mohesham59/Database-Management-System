#!/bin/bash
# ================================================
# Select_Table_With_Where.sh
# SELECT * FROM table WHERE column = value
# ================================================

SelectTb() {

    # ===============================
    # Check connection
    # ===============================
    if [[ -z "$CURRENT_DB" ]]; then
        zenity --error \
            --title="Not Connected ❌" \
            --text="Please connect to a database first." \
            --width=450
        return 1
    fi

    # ===============================
    # Check tables
    # ===============================
    if [[ ! -d "tables" ]] || [[ -z "$(ls -A tables/ 2>/dev/null)" ]]; then
        zenity --info \
            --title="No Tables | DB: $CURRENT_DB" \
            --text="No tables found." \
            --width=450
        return 0
    fi

    # ===============================
    # Select table
    # ===============================
    TableSelect=$(zenity --list \
        --title="Select Table | DB: $CURRENT_DB" \
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
    # WHERE clause
    # ===============================

    WhereColumn=$(zenity --list \
        --title="WHERE Condition | DB: $CURRENT_DB" \
        --text="Select column:" \
        --column="Columns" \
        "${columns[@]}")

    [[ -z "$WhereColumn" ]] && return 0

    # Get column index
    col_index=0
    for i in "${!columns[@]}"; do
        if [[ "${columns[$i]}" == "$WhereColumn" ]]; then
            col_index=$i
            break
        fi
    done

    WhereValue=$(zenity --entry \
        --title="WHERE Condition" \
        --text="Enter value for:\n$WhereColumn")

    [[ -z "$WhereValue" ]] && return 0

    # ===============================
    # Build zenity table
    # ===============================
    zenity_cmd=(zenity --list
        --title="SELECT * FROM $TableSelect WHERE $WhereColumn = $WhereValue"
        --width=900
        --height=500
    )

    # Add columns
    for col in "${columns[@]}"; do
        zenity_cmd+=(--column="$col")
    done

    # ===============================
    # Filter data
    # ===============================
    match_found=false

    while IFS='|' read -r -a row; do
        if [[ "${row[$col_index]}" == "$WhereValue" ]]; then
            match_found=true
            for cell in "${row[@]}"; do
                zenity_cmd+=("$cell")
            done
        fi
    done < "$Table_file"

    if [[ "$match_found" == false ]]; then
        zenity --info \
            --title="No Results" \
            --text="No matching records found." \
            --width=400
        return 0
    fi

    # ===============================
    # Show result
    # ===============================
    "${zenity_cmd[@]}"
}
