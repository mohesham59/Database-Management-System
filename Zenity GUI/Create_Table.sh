#!/bin/bash
# ================================================
# Create_Table.sh (Fixed Paths + Bugs)
# ================================================

# Create Table Function (Zenity - Fixed paths: table/ & metadata/)
CreateTb() {
    # Ensure subdirs exist
    mkdir -p table metadata

    # Loop for valid table name
    while true; do
        table_name=$(zenity --entry \
            --title="Create Table 🆕" \
            --text="Enter Table Name:\n(Rules: letter/_ start, letters/numbers/_ only)" \
            --width=500)

        if [[ $? -ne 0 ]]; then
            return 1
        fi

        if [[ ! "$table_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ || -z "$table_name" ]]; then
            zenity --error --title="Invalid Name ❌" \
                --text="Invalid Table Name!\nMust start with letter/_, letters/numbers/_ only." \
                --width=450
            continue
        fi

        if [[ -f "table/$table_name" ]]; then
            zenity --warning --title="Already Exists ⚠️" \
                --text="Table '<b>$table_name</b>' already exists in <b>table/</b>!" \
                --width=450
            return 1
        fi

        break
    done

    # Create files in correct paths
    touch "tables/$table_name"
    touch "metadata/${table_name}_metadata"
    zenity --info --title="Table Files Created 📄" \
        --text="Created:\n• <b>table/$table_name</b>\n• <b>metadata/${table_name}_metadata</b>" \
        --width=450

    # Number of columns
    while true; do
        numColumns=$(zenity --entry \
            --title="Table Structure" \
            --text="Enter Number of Columns (>0):" \
            --width=450)

        if [[ $? -ne 0 ]]; then
            zenity --warning --title="Cancelled" --text="Table creation cancelled."
            rm -f "table/$table_name" "metadata/${table_name}_metadata"  # Fixed cleanup paths
            return 1
        fi

        if [[ "$numColumns" =~ ^[0-9]+$ && "$numColumns" -gt 0 ]]; then
            break
        else
            zenity --error --title="Invalid" --text="Must be positive integer!"
        fi
    done

    # For each column
    for ((i=1; i<=numColumns; i++)); do
        # Column Name
        while true; do
            columnName=$(zenity --entry \
                --title="Column $i / $numColumns" \
                --text="Enter Name for Column $i:\n(letter/_ start, letters/numbers/_ only)" \
                --width=500)
            if [[ $? -ne 0 ]]; then
                zenity --warning --title="Cancelled" --text="Table creation cancelled."
                rm -f "table/$table_name" "metadata/${table_name}_metadata"
                return 1
            fi
            if [[ "$columnName" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ && -n "$columnName" ]]; then
                break
            else
                zenity --error --title="Invalid Name" --text="Invalid Column Name!"
            fi
        done

        # Column Type
        columnType=$(zenity --list \
            --title="Column $i: $columnName" \
            --text="Select Data Type:" \
            --width=400 --height=200 \
            --column="Type" "str" "int" \
            --print-column=1)

        if [[ $? -ne 0 || -z "$columnType" ]]; then
            columnType="str"
        fi

        # Primary Key (map "Yes (Primary Key)" → "y", "No" → "n")
        pk_choice=$(zenity --list \
            --title="Column $i: $columnName ($columnType)" \
            --text="Is Primary Key?" \
            --width=450 --height=200 \
            --column="Choice" \
            "Yes (Primary Key)" \
            "No" \
            --print-column=1)

        if [[ $? -ne 0 || -z "$pk_choice" ]]; then
            columnPK="n"
        else
            if [[ "$pk_choice" == "Yes"* ]]; then
                columnPK="y"
            else
                columnPK="n"
            fi
        fi

        # Append to metadata (Fixed path)
        {
            echo "\"Column Name\": $columnName"
            echo "\"Column Type\": $columnType"
            echo "\"Primary Key\": $columnPK"
            echo "-----"
        } >> "metadata/${table_name}_metadata"
    done

    # Success
    zenity --info \
        --title="Success 🎉" \
        --text="Table '<b>$table_name</b>' created with <b>$numColumns</b> columns!\n\n• Data: <b>table/$table_name</b>\n• Schema: <b>metadata/${table_name}_metadata</b>" \
        --width=500
}
