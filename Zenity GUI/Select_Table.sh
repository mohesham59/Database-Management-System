#!/bin/bash
# ================================================
# Select_Table.sh (FIXED - WHERE condition display)
# ================================================

SelectTb() {

    if [[ -z "$CURRENT_DB" ]]; then
        zenity --error --title="Not Connected" --text="Please connect to a database first." --width=450
        return 1
    fi

    if [[ ! -d "tables" ]] || [[ -z "$(ls -A tables/ 2>/dev/null)" ]]; then
        zenity --info --title="No Tables | DB: $CURRENT_DB" --text="No tables found." --width=450
        return 0
    fi

    TableSelect=$(zenity --list \
        --title="Select Table | DB: $CURRENT_DB" \
        --text="Select table:" \
        --column="Table Name" \
        --width=600 --height=450 \
        $(ls tables/ 2>/dev/null))

    [[ $? -ne 0 || -z "$TableSelect" ]] && return 0

    Table_file="tables/$TableSelect"
    Metadata_file="metadata/${TableSelect}_metadata"

    if [[ ! -f "$Table_file" || ! -f "$Metadata_file" ]]; then
        zenity --error --title="Error" --text="Table or metadata missing." --width=450
        return 1
    fi

    if [[ ! -s "$Table_file" ]]; then
        zenity --info --title="Empty Table" --text="Table '$TableSelect' has no data." --width=450
        return 0
    fi

    # Read columns
    columns=()
    while read -r col; do
        columns+=("$col")
    done < <(awk -F': ' '/"Column Name"/ {print $2}' "$Metadata_file")

    # Ask user: Show all or with condition?
    view_mode=$(zenity --list \
        --title="View Options | $TableSelect" \
        --text="How do you want to view the data?" \
        --column="Option" \
        "Show All Records" \
        "Search with WHERE condition" \
        --width=500 --height=300)

    [[ -z "$view_mode" ]] && return 0

    if [[ "$view_mode" == "Show All Records" ]]; then
        # FIXED: Build command for showing all records
        zenity_cmd=(zenity --list \
            --title="Table: $TableSelect | DB: $CURRENT_DB" \
            --width=1000 --height=600)

        for col in "${columns[@]}"; do
            zenity_cmd+=(--column="$col")
        done

        # Show all rows
        while IFS='|' read -r -a row; do
            for cell in "${row[@]}"; do
                zenity_cmd+=("$cell")
            done
        done < "$Table_file"

        "${zenity_cmd[@]}"
        return 0
    else
        # WHERE condition
        WhereColumn=$(zenity --list \
            --title="WHERE Column | $TableSelect" \
            --text="Select column to filter by:" \
            --column="Column" \
            --width=400 --height=350 \
            "${columns[@]}")
        
        [[ -z "$WhereColumn" ]] && return 0

        # Find column index
        col_index=0
        for i in "${!columns[@]}"; do
            if [[ "${columns[$i]}" == "$WhereColumn" ]]; then
                col_index=$i
                break
            fi
        done

        WhereValue=$(zenity --entry \
            --title="WHERE Value | $TableSelect" \
            --text="Enter value for column '$WhereColumn':")
        
        [[ -z "$WhereValue" ]] && return 0

        # FIXED: Build NEW command with WHERE title
        zenity_cmd=(zenity --list \
            --title="Table: $TableSelect WHERE $WhereColumn = '$WhereValue' | DB: $CURRENT_DB" \
            --width=1000 --height=600)

        for col in "${columns[@]}"; do
            zenity_cmd+=(--column="$col")
        done

        # Filter and add matching rows
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
                --title="No Results | $TableSelect" \
                --text="No records match the condition:\n\n$WhereColumn = '$WhereValue'" \
                --width=450
            return 0
        fi

        "${zenity_cmd[@]}"
    fi
}