DropTb() {

    # Make sure user is connected to a DB
    if [[ -z "$CURRENT_DB" ]]; then
        zenity --error \
            --title="Not Connected ❌" \
            --text="You are not connected to any database.\n\nPlease connect to a database first." \
            --width=450
        return 1
    fi

    # Check if tables directory exists and not empty
    if [[ ! -d "tables" ]] || [[ -z "$(ls -A tables/ 2>/dev/null)" ]]; then
        zenity --info \
            --title="No Tables | DB: $CURRENT_DB" \
            --text="There are no tables available to drop.\n\nCreate a table first!" \
            --width=450 --height=250
        return 0
    fi

    Table_drop=$(zenity --list \
        --title="Drop Table 🗑️ | DB: $CURRENT_DB" \
        --text="Select the table you want to <b>permanently delete</b>:" \
        --column="Table Name" \
        --width=600 \
        --height=450 \
        $(ls -1 tables/ 2>/dev/null))

    if [[ $? -ne 0 || -z "$Table_drop" ]]; then
        return 0
    fi

    if zenity --question \
        --title="Confirm Deletion ⚠️ | DB: $CURRENT_DB" \
        --text="Are you <b>ABSOLUTELY SURE</b> you want to delete the table:\n\n<b>$Table_drop</b>\n\nFrom database:\n<b>$CURRENT_DB</b>\n\nThis action cannot be undone!" \
        --width=550 --height=250; then

        rm -f "tables/$Table_drop" "metadata/${Table_drop}_metadata"

        zenity --warning \
            --title="Table Dropped ✅ | DB: $CURRENT_DB" \
            --text="Table '<b>$Table_drop</b>' has been permanently deleted." \
            --width=500
    fi
}
