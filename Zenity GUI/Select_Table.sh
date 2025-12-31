#!/bin/bash
# ================================================
# Select_Table_With_Where.sh
# SELECT * FROM table WHERE column = value
# ================================================

SelectTb() {

    # ===============================
    # 1️⃣ Check if connected to a database
    # ===============================
    # CURRENT_DB should contain the name of the connected database
    if [[ -z "$CURRENT_DB" ]]; then
        zenity --error \
            --title="Not Connected" \
            --text="Please connect to a database first." \
            --width=450
        return 1  # 1 = error
    fi

    # ===============================
    # 2️⃣ Check if 'tables/' directory exists and has tables
    # ===============================
    if [[ ! -d "tables" ]] || [[ -z "$(ls -A tables/ 2>/dev/null)" ]]; then
        # If no tables exist, show a message
        zenity --info \
            --title="No Tables | DB: $CURRENT_DB" \
            --text="No tables found." \
            --width=450
        return 0  # 0 = no error, but nothing to display
    fi

    # ===============================
    # 3️⃣ Prompt user to select a table
    # ===============================
    TableSelect=$(zenity --list \
        --title="Select Table | DB: $CURRENT_DB" \
        --text="Select table:" \
        --column="Table Name" \
        --width=600 \
        --height=450 \
        $(ls tables/))  # List all files in 'tables/' as options

    # If the user cancels or selects nothing
    [[ $? -ne 0 || -z "$TableSelect" ]] && return 0

    # Define file paths
    Table_file="tables/$TableSelect"                   # File containing table data
    Metadata_file="metadata/${TableSelect}_metadata"  # File containing columns and types

    # ===============================
    # 4️⃣ Check if the table file is empty
    # ===============================
    if [[ ! -s "$Table_file" ]]; then
        # Table is empty
        zenity --info \
            --title="Empty Table | DB: $CURRENT_DB" \
            --text="No data found in table:\n\n$TableSelect" \
            --width=450
        return 0
    fi

    # ===============================
    # 5️⃣ Read column names from metadata
    # ===============================
    columns=()  # Array to store column names
    while read -r col; do
        columns+=("$col")  # Add each column name to the array
    done < <(awk -F': ' '/"Column Name"/ {print $2}' "$Metadata_file")
    # awk searches for lines containing "Column Name" and prints the second field after ':'

    # ===============================
    # 6️⃣ Prompt user for WHERE condition
    # ===============================
    WhereColumn=$(zenity --list \
        --title="WHERE Condition | DB: $CURRENT_DB" \
        --text="Select column:" \
        --column="Columns" \
        "${columns[@]}")  # Show columns as selectable options

    [[ -z "$WhereColumn" ]] && return 0  # Exit if no column is selected

    # ===============================
    # 7️⃣ Find the index of the selected column
    # ===============================
    col_index=0
    for i in "${!columns[@]}"; do
        if [[ "${columns[$i]}" == "$WhereColumn" ]]; then
            col_index=$i  # Store column index
            break
        fi
    done

    # ===============================
    # 8️⃣ Prompt user to enter a value for WHERE condition
    # ===============================
    WhereValue=$(zenity --entry \
        --title="WHERE Condition" \
        --text="Enter value for:\n$WhereColumn")

    [[ -z "$WhereValue" ]] && return 0  # Exit if no value is entered

    # ===============================
    # 9️⃣ Build Zenity table command dynamically
    # ===============================
    zenity_cmd=(zenity --list
        --title="SELECT * FROM $TableSelect WHERE $WhereColumn = $WhereValue"
        --width=900
        --height=500
    )

    # Add column headers to Zenity table
    for col in "${columns[@]}"; do
        zenity_cmd+=(--column="$col")
    done

    # ===============================
    # 10️⃣ Filter data from table file
    # ===============================
    match_found=false  # Flag to track if a matching row is found

    # Read each row of the table, split by '|', store in array 'row'
    while IFS='|' read -r -a row; do
        # Check if the value in the selected column matches the input
        if [[ "${row[$col_index]}" == "$WhereValue" ]]; then
            match_found=true
            # Append all cells from this row to Zenity command
            for cell in "${row[@]}"; do
                zenity_cmd+=("$cell")
            done
        fi
    done < "$Table_file"

    # ===============================
    # 11️⃣ Show message if no matching rows
    # ===============================
    if [[ "$match_found" == false ]]; then
        zenity --info \
            --title="No Results" \
            --text="No matching records found." \
            --width=400
        return 0
    fi

    # ===============================
    # 12️⃣ Execute Zenity command to display results
    # ===============================
    "${zenity_cmd[@]}"
}
