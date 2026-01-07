#!/bin/bash
# ================================================
# Insert_Table.sh (FIXED - PK validation)
# ================================================

InsertTb() {

    # -------------------------------
    # 1. Check if connected to a database
    # -------------------------------
    if [[ -z "$CURRENT_DB" ]]; then
        zenity --error \
            --title="Not Connected" \
            --text="Please connect to a database first." \
            --width=450
        return 1
    fi

    # -------------------------------
    # 2. Check if 'tables/' directory exists and has tables
    # -------------------------------
    if [[ ! -d "tables" ]] || [[ -z "$(ls -A tables/ 2>/dev/null)" ]]; then
        zenity --info \
            --title="No Tables | DB: $CURRENT_DB" \
            --text="No tables found.\nCreate a table first." \
            --width=450
        return 0
    fi

    # -------------------------------
    # 3. Let user select a table to insert data into
    # -------------------------------
    Table_insert=$(zenity --list \
        --title="Insert Into Table | DB: $CURRENT_DB" \
        --text="Select table:" \
        --column="Table Name" \
        --width=600 \
        --height=450 \
        $(ls tables/ 2>/dev/null))

    if [[ $? -ne 0 || -z "$Table_insert" ]]; then
        return 0
    fi

    # Define table file paths
    Table_file="tables/$Table_insert"
    Metadata_file="metadata/${Table_insert}_metadata"

    # -------------------------------
    # 4. Check if metadata file exists
    # -------------------------------
    if [[ ! -f "$Table_file" ]]; then
        zenity --error --title="Table Not Found" \
            --text="Table file does not exist." --width=450
        return 1
    fi

    if [[ ! -f "$Metadata_file" ]]; then
        zenity --error \
            --title="Metadata Missing" \
            --text="Metadata for '$Table_insert' is missing." \
            --width=450
        return 1
    fi

    # ===============================
    # 5. Read metadata (columns, types, primary key)
    # ===============================
    columns=()
    types=()
    primary_key=""
    pk_index=0

    # Read all column names from metadata
    while read -r col; do
        columns+=("$col")
    done < <(awk -F': ' '/"Column Name"/ {print $2}' "$Metadata_file")

    # Read all column types from metadata
    while read -r type; do
        types+=("$type")
    done < <(awk -F': ' '/"Column Type"/ {print $2}' "$Metadata_file")

    # Extract primary key column and its index
    current_col=""
    col_counter=0
    while read -r line; do
        if [[ $line =~ \"Column\ Name\":\ (.*) ]]; then
            current_col="${BASH_REMATCH[1]}"
            ((col_counter++))
        elif [[ $line =~ \"Primary\ Key\":\ y ]]; then
            primary_key="$current_col"
            pk_index=$col_counter
        fi
    done < "$Metadata_file"

    # Array to hold the values for the new row
    values=()

    # ===============================
    # 6. Insert values for each column
    # ===============================
    for ((i=0; i<${#columns[@]}; i++)); do
        column_name="${columns[i]}"
        column_type="${types[i]}"

        while true; do
            # Prompt user to enter value for this column
            value=$(zenity --entry \
                --title="Insert Data | DB: $CURRENT_DB" \
                --text="Enter value for:\n\n$column_name ($column_type)" \
                --width=450)

            if [[ $? -ne 0 ]]; then
                zenity --question \
                    --title="Cancel Insert?" \
                    --text="Do you want to cancel the insert operation?" \
                    --width=400
                if [[ $? -eq 0 ]]; then
                    return 0
                else
                    continue
                fi
            fi

            # Validate integer columns
            if [[ "$column_type" == "int" ]]; then
                if [[ ! "$value" =~ ^[0-9]+$ ]]; then
                    zenity --error \
                        --title="Invalid Type" \
                        --text="Column '$column_name' must be an INTEGER." \
                        --width=450
                    continue
                fi
            fi

            # Validate string columns
            if [[ "$column_type" == "str" ]]; then
                # Check for pipe character (conflicts with delimiter)
                if [[ "$value" == *"|"* ]]; then
                    zenity --error \
                        --title="Invalid Character" \
                        --text="String cannot contain pipe character (|)" \
                        --width=450
                    continue
                fi
                
                # Optional: Check string length
                if [[ ${#value} -gt 255 ]]; then
                    zenity --error \
                        --title="String Too Long" \
                        --text="String exceeds maximum length of 255 characters.\nCurrent length: ${#value}" \
                        --width=450
                    continue
                fi
            fi

            # FIXED: Validate primary key uniqueness
            if [[ "$column_name" == "$primary_key" ]]; then
                # Check if table file is empty
                if [[ -s "$Table_file" ]]; then
                    # Use AWK to check if PK value exists in the correct column
                    pk_exists=$(awk -F'|' -v pk_val="$value" -v pk_idx="$pk_index" '
                        $pk_idx == pk_val { found=1; exit }
                        END { print found+0 }
                    ' "$Table_file")
                    
                    if [[ "$pk_exists" == "1" ]]; then
                        zenity --error \
                            --title="Duplicate Primary Key" \
                            --text="Value '$value' already exists for primary key '$column_name'.\n\nPlease enter a unique value." \
                            --width=450
                        continue
                    fi
                fi
            fi

            # Add valid value to array
            values+=("$value")
            break
        done
    done

    # ===============================
    # 7. Insert the new row into the table file
    # ===============================
    # Join values with | and append to file
    echo "${values[*]}" | tr ' ' '|' >> "$Table_file"

    # Show success message
    zenity --info \
        --title="Insert Successful | DB: $CURRENT_DB" \
        --text="Data inserted successfully into table:\n\n$Table_insert" \
        --width=450
}