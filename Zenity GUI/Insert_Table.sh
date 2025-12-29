#!/bin/bash
# ================================================
# Insert_Table.sh (Zenity + awk / NO mapfile)
# ================================================

InsertTb() {

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
            --text="No tables found.\nCreate a table first." \
            --width=450
        return 0
    fi

    # Select table
    Table_insert=$(zenity --list \
        --title="Insert Into Table | DB: $CURRENT_DB" \
        --text="Select table:" \
        --column="Table Name" \
        --width=600 \
        --height=450 \
        $(ls tables/))

    if [[ $? -ne 0 || -z "$Table_insert" ]]; then
        return 0
    fi

    Table_file="tables/$Table_insert"
    Metadata_file="metadata/${Table_insert}_metadata"

    if [[ ! -f "$Metadata_file" ]]; then
        zenity --error \
            --title="Metadata Missing ❌" \
            --text="Metadata for '$Table_insert' is missing." \
            --width=450
        return 1
    fi

    # ===============================
    # Read metadata using awk
    # ===============================

    columns=()
    types=()
    primary_key=""

    while read -r col; do
        columns+=("$col")
    done < <(awk -F': ' '/"Column Name"/ {print $2}' "$Metadata_file")

    while read -r type; do
        types+=("$type")
    done < <(awk -F': ' '/"Column Type"/ {print $2}' "$Metadata_file")

    primary_key=$(awk -F': ' '
        /"Column Name"/ {col=$2}
        /"Primary Key": y/ {print col}
    ' "$Metadata_file")

    values=()

    # ===============================
    # Insert values
    # ===============================
    for ((i=0; i<${#columns[@]}; i++)); do
        column_name="${columns[i]}"
        column_type="${types[i]}"

        while true; do
            value=$(zenity --entry \
                --title="Insert Data | DB: $CURRENT_DB" \
                --text="Enter value for:\n\n$column_name ($column_type)" \
                --width=450)

            if [[ $? -ne 0 ]]; then
                return 0
            fi

            if [[ "$column_type" == "int" ]]; then
                if [[ ! "$value" =~ ^[0-9]+$ ]]; then
                    zenity --error \
                        --title="Invalid Type ❌" \
                        --text="Column '$column_name' must be an INTEGER." \
                        --width=450
                    continue
                fi
            fi

            if [[ "$column_name" == "$primary_key" ]]; then
                if grep -q "^$value|" "$Table_file"; then
                    zenity --error \
                        --title="Duplicate Primary Key ❌" \
                        --text="Value '$value' already exists for primary key '$column_name'." \
                        --width=450
                    continue
                fi
            fi

            values+=("$value")
            break
        done
    done

    # Insert row
    echo "${values[*]}" | tr ' ' '|' >> "$Table_file"

    zenity --info \
        --title="Insert Successful ✅ | DB: $CURRENT_DB" \
        --text="Data inserted successfully into table:\n\n<b>$Table_insert</b>" \
        --width=450
}
