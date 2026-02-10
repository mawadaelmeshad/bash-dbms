#!/bin/bash

create_table(){
    read -p "Enter table name: " table_name
    read -p "Number of columns: " num_cols

    >"$table_name.meta"
    >"$table_name.data"

    for ((i=1; i<=num_cols; i++)); 
    do
        read -p "Enter column $i name: " col_name
        read -p "Enter column $i type (int/string): " col_type
        read -p "Is column $i a primary key? (y/n): " is_pk

        if [[ "$is_pk" == "y" ]]; then
            echo "$col_name:$col_type:PK" >> "$table_name.meta"
        else    
        echo "$col_name:$col_type" >> "$table_name.meta"
    done
}

insert_into_table(){
    read -p "Table name: " table_name
    row=""

    while IFS= read col type pk;
    do
        read -p "Enter value for $col ($type): " value
        #validation application >>>>

        row+="$value|"
    done < "$table_name.meta"
    echo "${row%|}" >> "$table_name.data"
}


select_from_table(){
    read -p "Table name: " table_name
    column -t -s '|' "$table_name.data"
}