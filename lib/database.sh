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
