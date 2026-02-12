#!/bin/bash

validate_name() {
    local name=$1

    if [[ $name =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
        return 0
    else
        echo "Error: Name must start with a letter. Only letters, numbers, underscores allowed."
        return 1
    fi
}

validate_datatype() {
    local value=$1
    local type=$2

    if [[ "$type" == "int" ]]; then
        if [[ "$value" =~ ^-?[0-9]+$ ]]; then
            return 0
        else
            echo "Error: '$value' is not a valid int. Example: 5, -3, 100"
            return 1
        fi
    fi

    if [[ "$type" == "double" ]]; then
        # Accepts: 3  or  3.14  or  -2.5
        if [[ "$value" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
            return 0
        else
            echo "Error: '$value' is not a valid double. Example: 3.14, -2.5, 10"
            return 1
        fi
    fi

    if [[ "$type" == "boolean" ]]; then
        if [[ "$value" == "true" || "$value" == "false" ]]; then
            return 0
        else
            echo "Error: '$value' is not valid. Type: true or false"
            return 1
        fi
    fi

    if [[ "$type" == "string" ]]; then
        return 0
    fi

    echo "Error: Unknown type '$type'. Allowed: int, double, string, boolean"
    return 1
}

validate_not_null() {
    local value=$1
    local col_name=$2

    if [[ -z "$value" ]]; then
        echo "Error: '$col_name' cannot be empty."
        return 1
    fi
    return 0
}

table_exists() {
    local db_name=$1
    local table_name=$2

    if [[ -f "$DB_DIR/$db_name/$table_name.meta" ]]; then
        return 0
    else
        return 1
    fi
}


check_primary_key() {
    local db_name=$1
    local table_name=$2
    local pk_col_number=$3
    local new_value=$4

    while IFS='|' read -ra fields; do
        local existing="${fields[$((pk_col_number - 1))]}"
        if [[ "$existing" == "$new_value" ]]; then
            echo "Error: '$new_value' already exists. Primary key must be unique."
            return 1
        fi
    done < "$DB_DIR/$db_name/$table_name.data"

    return 0
}