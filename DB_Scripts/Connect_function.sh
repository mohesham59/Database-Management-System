#!/usr/bin/env bash
show_colorful_banner() {
    local db_name="$1"
    echo -e "\033[1;35m"  # أرجواني فاتح
    echo "   ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦   "
    echo -e "\033[1;36m"  # سماوي
    echo "   ██████╗  █████╗ ████████╗ █████╗  ██████╗  █████╗ ███████╗███████╗"
    echo "   ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗ ██╔══██╗██╔══██╗██╔════╝██╔════╝"
    echo -e "\033[1;32m"  # أخضر
    echo "   ██║  ██║███████║   ██║   ███████║ ██████╔╝███████║███████╗█████╗  "
    echo "   ██║  ██║██╔══██║   ██║   ██╔══██║ ██╔══██╗██╔══██║╚════██║██╔══╝  "
    echo -e "\033[1;33m"  
    echo "   ██████╔╝██║  ██║   ██║   ██║  ██║ ██████╔╝██║  ██║███████║███████╗"
    echo "   ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝"
    echo -e "\033[1;34m"  # أزرق
 
    echo -e "\033[1;35m"
    echo "   ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦   "
    echo -e "\033[0m"
}
connect_func() {
    show_colorful_banner "$db_name"
    source ./TableMenu.sh
    local DB_name

    read -p "What is the Data Base you want to connect with? " DB_name
    local SEARCH_PATH="$HOME/DBMS/DataBase/$DB_name"

    if [[ ! -d "$SEARCH_PATH" ]]; then
        echo "There is no Data Base with this name."
    else
        
        TB_menu "$DB_name"
    fi
}
