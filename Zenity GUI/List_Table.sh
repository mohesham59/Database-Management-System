#!/bin/bash
# ================================================
# List_Table.sh (ls only - No mapfile)
# ================================================

ListTb() {
    # List tables from tables/ directory
    local table_list
    table_list=$(ls tables/ 2>/dev/null | nl -w2 -s')  ')

    if [[ -z "$table_list" ]]; then
        zenity --info \
            --title="List Tables 📋 | DB: $CURRENT_DB" \
            --text="No tables found in <b>tables/</b>.\n\nCreate one first!" \
            --width=450 --height=250
        return 0
    fi

    local total
    total=$(ls tables/ 2>/dev/null | wc -l | tr -d ' ')

    zenity --info \
        --title="Available Tables 📋 | DB: $CURRENT_DB" \
        --text="<b>Available Tables in $CURRENT_DB:</b>\n\n$table_list\n\nTotal: <b>$total</b> table(s)" \
        --width=550 --height=450
}
