#!/bin/bash
create_database() {
    clear
    echo "================================"
    echo "   Create Database"
    echo "================================"
    echo ""
    
    read -p "Enter database name: " db_name
# Check if name is not empty
    if [[ -z "$db_name" ]]; then
        echo ""
        echo "Error, Database name cannot be empty!"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi

    if ! [[ $db_name =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
        echo ""
        echo "Error, Invalid name!"
        echo "   Use only letters, numbers, and underscores."
        echo "   Must start with a letter."
        echo ""
        read -p "Press Enter to continue..."
        return
    fi
    if [[ -d "$DB_DIR/$db_name" ]]; then
        echo ""
        echo "Error, Database '$db_name' already exists!"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi
 mkdir "$DB_DIR/$db_name"
 echo " Database '$db_name' created successfully!"
 read -p "Press Enter to continue..."
}

list_databases() {
    clear
    echo "================================"
    echo "   Available Databases"
    echo "================================"
    echo ""

    if [[ ! -d "$DB_DIR" ]] || [[ -z "$(ls -A $DB_DIR 2>/dev/null)" ]]; then
        echo "No databases found."
        echo ""
        read -p "Press Enter to continue..."
        return
    fi

    local count=1
    for db in "$DB_DIR"/*; do
        if [[ -d "$db" ]]; then
            echo "$count. $(basename "$db")"
            ((count++))
        fi
    done
    echo ""
    read -p "Press Enter to continue..."
}

drop_database() {
    clear
    echo "================================"
    echo "   Drop Database"
    echo "================================"
    echo ""
    read -p "Enter database name: " db_name
    if [[ ! -d "$DB_DIR/$db_name" ]]; then
        echo ""
        echo "Error, Database '$db_name' does not exist!"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi

    echo ""
    echo "WARNING! This will permanently delete the database and all its tables!"
    echo ""
    read -p "Are you sure you want to delete '$db_name'? (yes/no): " confirm
    
    if [[ "$confirm" == "yes" ]]; then
        rm -rf "$DB_DIR/$db_name"
        echo ""
        echo "Database '$db_name' deleted!"
        echo ""
    else
        echo ""
        echo "Operation failed!"
        echo ""
    fi
 read -p "Press Enter to continue..."
}

connect_database() {
 clear
    echo "================================"
    echo "   Connect to Database"
    echo "================================"
    echo ""
    read -p "Enter database name: " db_name
    if [[ ! -d "$DB_DIR/$db_name" ]]; then
        echo ""
        echo "Error, Database '$db_name' does not exist!"
        echo ""
        read -p "Press Enter to continue..."
        return
    fi
    
    echo ""
    echo "Connected to '$db_name' successfully!"
    sleep 1
    table_menu "$db_name"
}
