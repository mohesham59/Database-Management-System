#!/bin/bash
# ================================================
# Insert_Table.sh (Zenity + awk / NO mapfile)
# ================================================

InsertTb() {

    # -------------------------------
    # 1️⃣ Check if connected to a database
    # -------------------------------
    if [[ -z "$CURRENT_DB" ]]; then
        zenity --error \
            --title="Not Connected ❌" \
            --text="Please connect to a database first." \
            --width=450
        return 1
    fi

    # -------------------------------
    # 2️⃣ Check if 'tables/' directory exists and has tables
    # -------------------------------
    if [[ ! -d "tables" ]] || [[ -z "$(ls -A tables/ 2>/dev/null)" ]]; then
        zenity --info \
            --title="No Tables | DB: $CURRENT_DB" \
            --text="No tables found.\nCreate a table first." \
            --width=450
        return 0
    fi

    # -------------------------------
    # 3️⃣ Let user select a table to insert data into
    # -------------------------------
    Table_insert=$(zenity --list \
        --title="Insert Into Table | DB: $CURRENT_DB" \
        --text="Select table:" \
        --column="Table Name" \
        --width=600 \
        --height=450 \
        $(ls tables/))

    # If user cancels or closes the Zenity dialog
    if [[ $? -ne 0 || -z "$Table_insert" ]]; then
        return 0
    fi

    # Define table file paths
    Table_file="tables/$Table_insert"
    Metadata_file="metadata/${Table_insert}_metadata"

    # -------------------------------
    # 4️⃣ Check if metadata file exists
    # -------------------------------
    if [[ ! -f "$Metadata_file" ]]; then
        zenity --error \
            --title="Metadata Missing ❌" \
            --text="Metadata for '$Table_insert' is missing." \
            --width=450
        return 1
    fi

    # ===============================
    # 5️⃣ Read metadata (columns, types, primary key)
    # ===============================
    columns=()       # Array to store column names
    types=()         # Array to store column types (int/str)
    primary_key=""   # Store primary key column name

    # Read all column names from metadata
    while read -r col; do
        columns+=("$col")
    done < <(awk -F': ' '/"Column Name"/ {print $2}' "$Metadata_file")

    # Read all column types from metadata
    while read -r type; do
        types+=("$type")
    done < <(awk -F': ' '/"Column Type"/ {print $2}' "$Metadata_file")

    # Extract primary key column
    primary_key=$(awk -F': ' '
        /"Column Name"/ {col=$2}
        /"Primary Key": y/ {print col}
    ' "$Metadata_file")

    # Array to hold the values for the new row
    values=()

    # ===============================
    # 6️⃣ Insert values for each column
    # ===============================
    for ((i=0; i<${#columns[@]}; i++)); do
        column_name="${columns[i]}"  # Current column name
        column_type="${types[i]}"    # Current column type

        while true; do
            # Prompt user to enter value for this column
            value=$(zenity --entry \
                --title="Insert Data | DB: $CURRENT_DB" \
                --text="Enter value for:\n\n$column_name ($column_type)" \
                --width=450)

            # If user cancels entry
            if [[ $? -ne 0 ]]; then
                return 0
            fi

            # Validate integer columns
            if [[ "$column_type" == "int" ]]; then
                if [[ ! "$value" =~ ^[0-9]+$ ]]; then
                    zenity --error \
                        --title="Invalid Type ❌" \
                        --text="Column '$column_name' must be an INTEGER." \
                        --width=450
                    continue
                fi
            fi

            # Validate primary key uniqueness
            if [[ "$column_name" == "$primary_key" ]]; then
                if grep -q "^$value|" "$Table_file"; then
                    zenity --error \
                        --title="Duplicate Primary Key ❌" \
                        --text="Value '$value' already exists for primary key '$column_name'." \
                        --width=450
                    continue
                fi
            fi

            # Add valid value to array
            values+=("$value")
            break  # move to next column
        done
    done

    # ===============================
    # 7️⃣ Insert the new row into the table file
    # ===============================
    # Join values with | and append to file
    echo "${values[*]}" | tr ' ' '|' >> "$Table_file"

    # Show success message
    zenity --info \
        --title="Insert Successful ✅ | DB: $CURRENT_DB" \
        --text="Data inserted successfully into table:\n\n<b>$Table_insert</b>" \
        --width=450
}
