#!/bin/bash
# ================================================
# List_Table.sh (FIXED - Character encoding)
# ================================================

ListTb() {
    # List tables from tables/ directory
    local table_list
    table_list=$(ls tables/ 2>/dev/null | nl -w2 -s')  ')

    if [[ -z "$table_list" ]]; then
        zenity --info \
            --title="List Tables | DB: $CURRENT_DB" \
            --text="No tables found in tables/.\n\nCreate one first!" \
            --width=450 --height=250
        return 0
    fi

    local total
    total=$(ls tables/ 2>/dev/null | wc -l | tr -d ' ')

    zenity --info \
        --title="Available Tables | DB: $CURRENT_DB" \
        --text="Available Tables in $CURRENT_DB:\n\n$table_list\n\nTotal: $total table(s)" \
        --width=550 --height=450
}