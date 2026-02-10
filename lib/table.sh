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

select_all(){
    read -p "Table name: " table_name
    column -t -s '|' "$table_name.data"
}

select_where(){
    read -p "Table name: " table_name
    read -p "Column name: " col_name
    read -p "Value: " value

    col_num=$(awk -F: -v col="$col_name" '
    { if($1==col) print NR}' "$table_name.meta")

    awk -F'|' -v c="$col_num" -v v="$value" '
    $c==v {print} ' "$table_name.data" | column -t -s '|' 
}


update_table(){
    read -p "Table name: " table_name
    read -p "Condition column: " cond_col
    read -p "Condition value: " cond_val
    read -p "Column to update: " target_col
    read -p "New value: " new_val

    cond_num=$(awk -F: -v col="$cond_col" '
    { if($1==col) print NR }' "$table_name.meta")

    target_num=$(awk -F: -v col="$target_col" '
    { if($1==col) print NR }' "$table_name.meta")

    awk -F'|' -v OFS='|' \
        -v c="$cond_num" -v v="$cond_val" \
        -v t="$target_num" -v n="$new_val" '
    {
        if($c==v)
            $t=n
        print
    }' "$table_name.data" > temp && mv temp "$table_name.data"
}

delete_from_table(){
    read -p "Table name: " table_name
    read -p "Column name: " col_name
    read -p "Value: " value

    col_num=$(awk -F: -v col="$col_name" '
    { if($1==col) print NR }' "$table_name.meta")

    awk -F'|' -v c="$col_num" -v v="$value" '
    $c!=v { print }' "$table_name.data" > temp && mv temp "$table_name.data"
}

drop_table(){
    read -p "Table name: " table_name
    rm "$table_name.meta" "$table_name.data"
}

list_tables(){
    ls *.meta 2>/dev/null | sed 's/.meta//'
}


