#!/bin/bash

display_table(){
    local db_name=$1
    local table_name=$2

    local meta_file="$DB_DIR/$db_name/$table_name.meta"
    local data_file="$DB_DIR/$db_name/$table_name.data"

    echo "================================================================="

    while IFS='|' read -r col_name col_type col_pk;
    do
        if [[ "$col_pk" == "PK" ]]; then
            printf "%-15s (PK) | " "$col_name"
        else
            printf "%-15s | " "$col_name"
        fi
    done < "$meta_file"

    echo ""
    echo "================================================================="

    if [[ -f "$data_file" ]] && [[ -s "$data_file" ]]; then
        while IFS='|' read -ra row; do
            for value in "${row[@]}"; do
                printf "%-15s | " "$value"
            done
            echo ""
        done < "$data_file"
        echo "================================================================="
    else
        echo "No data found in table '$table_name'."
        echo "================================================================="
    fi
}

