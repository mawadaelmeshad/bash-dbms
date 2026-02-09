#!/bin/bash
DB_DIR="./databases"
mkdir -p "$DB_DIR"
source ./lib/database.sh
source ./lib/table.sh
source ./lib/validation.sh
source ./lib/display.sh

main_menu() {
    while true; do
        clear
        echo "================================"
        echo "   DBMS - Main Menu"
        echo "================================"
        echo "1. Create Database"
        echo "2. List Databases"
        echo "3. Connect To Database"
        echo "4. Drop Database"
        echo "5. Exit"
        echo "================================"
        read -p "Enter your choice [1-5]: " choice
	case $choice in
            1) create_database ;;
            2) list_databases ;;
            3) connect_database ;;
            4) drop_database ;;
            5) echo "Goodbye!"; exit 0 ;;
            *) echo "Invalid choice! Press Enter to continue..."; read ;;
        esac
    done
}

table_menu() {
    local db_name=$1
    
    while true; do
        clear
        echo "================================"
        echo "   Database: $db_name"
        echo "================================"
        echo "1. Create Table"
        echo "2. List Tables"
        echo "3. Drop Table"
        echo "4. Insert into Table"
        echo "5. Select From Table"
        echo "6. Delete From Table"
        echo "7. Update Table"
        echo "8. Back to Main Menu"
        echo "================================"
        read -p "Enter your choice [1-8]: " choice
	case $choice in
            1) create_table "$db_name" ;;
            2) list_tables "$db_name" ;;
            3) drop_table "$db_name" ;;
            4) insert_into_table "$db_name" ;;
            5) select_from_table "$db_name" ;;
            6) delete_from_table "$db_name" ;;
            7) update_table "$db_name" ;;
            8) return ;;
            *) echo "Invalid choice! Press Enter to continue..."; read ;;
        esac
    done
}
main_menu
