#!/bin/bash


print_table() {
    local db_name=$1
    local table_name=$2

    local meta_file="$DB_DIR/$db_name/$table_name.meta"
    local data_file="$DB_DIR/$db_name/$table_name.data"

    local col_names=()
    while IFS=':' read -r name type pk; do
        col_names+=("$name")
    done < "$meta_file"

    local rows=()
    while IFS= read -r line; do
        rows+=("$line")
    done < "$data_file"

    local widths=()
    for (( i=0; i<${#col_names[@]}; i++ )); do
        widths[$i]=${#col_names[$i]}
    done

    for row in "${rows[@]}"; do
        IFS='|' read -ra fields <<< "$row"
        for (( i=0; i<${#col_names[@]}; i++ )); do
            if [[ ${#fields[$i]} -gt ${widths[$i]} ]]; then
                widths[$i]=${#fields[$i]}
            fi
        done
    done

    local fmt="|"
    local sep="+"
    for (( i=0; i<${#col_names[@]}; i++ )); do
        fmt="$fmt %-${widths[$i]}s |"
        sep="$sep$(printf '%0.s-' $(seq 1 $((widths[$i]+2))))+"
    done
    fmt="$fmt\n"
    
    echo "$sep"
    printf "$fmt" "${col_names[@]}"
    echo "$sep"
    for row in "${rows[@]}"; do
        IFS='|' read -ra fields <<< "$row"
        printf "$fmt" "${fields[@]}"
    done
    echo "$sep"
}

create_table() {
    local db_name=$1

    read -p "Enter table name: " table_name

    if ! validate_name "$table_name"; then
        read -p "Press Enter to continue..."
        return
    fi

    if table_exists "$db_name" "$table_name"; then
        echo "Error: Table '$table_name' already exists!"
        read -p "Press Enter to continue..."
        return
    fi

    read -p "Number of columns: " num_cols

    if ! [[ "$num_cols" =~ ^[1-9][0-9]*$ ]]; then
        echo "Error: Please enter a positive number."
        read -p "Press Enter to continue..."
        return
    fi

    # Create empty meta and data files
    > "$DB_DIR/$db_name/$table_name.meta"
    > "$DB_DIR/$db_name/$table_name.data"

    local pk_already_set="no"

    for (( i=1; i<=num_cols; i++ )); do
        echo ""
        echo "--- Column $i ---"

        local col_name=""
        while true; do
            read -p "  Name: " col_name
            if validate_name "$col_name"; then
                break
            fi
        done

        local col_type=""
        while true; do
            read -p "  Type (int / double / string / boolean): " col_type
            if [[ "$col_type" == "int" || "$col_type" == "double" || "$col_type" == "string" || "$col_type" == "boolean" ]]; then
                break
            else
                echo "  Error: Type must be int, double, string, or boolean."
            fi
        done

        local is_pk="no"
        if [[ "$pk_already_set" == "no" ]]; then
            read -p "  Is this a primary key? (y/n): " pk_answer
            if [[ "$pk_answer" == "y" ]]; then
                is_pk="yes"
                pk_already_set="yes"
            fi
        fi

        if [[ "$is_pk" == "yes" ]]; then
            echo "$col_name:$col_type:PK" >> "$DB_DIR/$db_name/$table_name.meta"
        else
            echo "$col_name:$col_type" >> "$DB_DIR/$db_name/$table_name.meta"
        fi

    done

    echo ""
    echo "Table '$table_name' created successfully!"
    read -p "Press Enter to continue..."
}

insert_into_table() {
    local db_name=$1

    read -p "Table name: " table_name

    if ! table_exists "$db_name" "$table_name"; then
        echo "Error: Table '$table_name' does not exist!"
        read -p "Press Enter to continue..."
        return
    fi

    local meta_lines=()
    while IFS= read -r line; do
        meta_lines+=("$line")
    done < "$DB_DIR/$db_name/$table_name.meta"

    local row=""
    local col_number=0

    for line in "${meta_lines[@]}"; do

        local col_name
        local col_type
        local pk
        col_name=$(echo "$line" | cut -d':' -f1)
        col_type=$(echo "$line" | cut -d':' -f2)
        pk=$(echo "$line" | cut -d':' -f3)

        col_number=$((col_number + 1))

        while true; do
            read -p "Enter value for '$col_name' ($col_type): " value

            if ! validate_not_null "$value" "$col_name"; then
                continue
            fi

            if ! validate_datatype "$value" "$col_type"; then
                continue
            fi

            if [[ "$pk" == "PK" ]]; then
                if ! check_primary_key "$db_name" "$table_name" "$col_number" "$value"; then
                    continue
                fi
            fi

            break
        done

        if [[ -z "$row" ]]; then
            row="$value"
        else
            row="$row|$value"
        fi

    done

    echo "$row" >> "$DB_DIR/$db_name/$table_name.data"
    echo "Row inserted successfully!"
    read -p "Press Enter to continue..."
}

select_from_table() {
    local db_name=$1

    read -p "Table name: " table_name

    if ! table_exists "$db_name" "$table_name"; then
        echo "Error: Table '$table_name' does not exist!"
        read -p "Press Enter to continue..."
        return
    fi

    if [[ ! -s "$DB_DIR/$db_name/$table_name.data" ]]; then
        echo "Table '$table_name' is empty."
        read -p "Press Enter to continue..."
        return
    fi

    echo ""
    echo "1. Select all rows"
    echo "2. Select where (filter by a column value)"
    read -p "Your choice: " sel_choice

    if [[ "$sel_choice" == "1" ]]; then

        echo ""
        echo "=== $table_name ==="
        print_table "$db_name" "$table_name"
        echo ""

    elif [[ "$sel_choice" == "2" ]]; then

        read -p "Column name: " col_name
        read -p "Value to search for: " search_value

        local col_number=0
        local counter=0
        while IFS=':' read -r name type pk; do
            counter=$((counter + 1))
            if [[ "$name" == "$col_name" ]]; then
                col_number=$counter
                break
            fi
        done < "$DB_DIR/$db_name/$table_name.meta"

        if [[ "$col_number" -eq 0 ]]; then
            echo "Error: Column '$col_name' not found."
            read -p "Press Enter to continue..."
            return
        fi

        local tmp_file="$DB_DIR/$db_name/$table_name.tmp"
        > "$tmp_file"

        while IFS='|' read -ra fields; do
            if [[ "${fields[$((col_number - 1))]}" == "$search_value" ]]; then
                local row=""
                for field in "${fields[@]}"; do
                    if [[ -z "$row" ]]; then row="$field"
                    else row="$row|$field"; fi
                done
                echo "$row" >> "$tmp_file"
            fi
        done < "$DB_DIR/$db_name/$table_name.data"

        echo ""
        echo "=== Results: $col_name = $search_value ==="

        if [[ ! -s "$tmp_file" ]]; then
            echo "No rows found."
        else
            print_table_from_files "$DB_DIR/$db_name/$table_name.meta" "$tmp_file"
        fi

        rm -f "$tmp_file"
        echo ""

    else
        echo "Invalid choice."
    fi

    read -p "Press Enter to continue..."
}


update_table() {
    local db_name=$1

    read -p "Table name: " table_name

    if ! table_exists "$db_name" "$table_name"; then
        echo "Error: Table '$table_name' does not exist!"
        read -p "Press Enter to continue..."
        return
    fi

    read -p "Condition column (WHERE): " cond_col
    read -p "Condition value: " cond_val
    read -p "Column to update (SET): " target_col
    read -p "New value: " new_val

    local cond_number=0
    local target_number=0
    local target_type=""
    local counter=0

    while IFS=':' read -r name type pk; do
        counter=$((counter + 1))
        if [[ "$name" == "$cond_col" ]]; then
            cond_number=$counter
        fi
        if [[ "$name" == "$target_col" ]]; then
            target_number=$counter
            target_type="$type"
        fi
    done < "$DB_DIR/$db_name/$table_name.meta"

    if [[ "$cond_number" -eq 0 ]]; then
        echo "Error: Column '$cond_col' not found."
        read -p "Press Enter to continue..."
        return
    fi

    if [[ "$target_number" -eq 0 ]]; then
        echo "Error: Column '$target_col' not found."
        read -p "Press Enter to continue..."
        return
    fi

    if ! validate_datatype "$new_val" "$target_type"; then
        read -p "Press Enter to continue..."
        return
    fi

    local tmp_file="$DB_DIR/$db_name/$table_name.tmp"
    > "$tmp_file"

    while IFS='|' read -ra fields; do

        if [[ "${fields[$((cond_number - 1))]}" == "$cond_val" ]]; then
            fields[$((target_number - 1))]="$new_val"
        fi

        local new_row=""
        for field in "${fields[@]}"; do
            if [[ -z "$new_row" ]]; then new_row="$field"
            else new_row="$new_row|$field"; fi
        done

        echo "$new_row" >> "$tmp_file"

    done < "$DB_DIR/$db_name/$table_name.data"

    mv "$tmp_file" "$DB_DIR/$db_name/$table_name.data"

    echo "Rows updated successfully!"
    read -p "Press Enter to continue..."
}

delete_from_table() {
    local db_name=$1

    read -p "Table name: " table_name

    if ! table_exists "$db_name" "$table_name"; then
        echo "Error: Table '$table_name' does not exist!"
        read -p "Press Enter to continue..."
        return
    fi

    read -p "Column name (WHERE): " col_name
    read -p "Value to delete: " del_value

    local col_number=0
    local counter=0

    while IFS=':' read -r name type pk; do
        counter=$((counter + 1))
        if [[ "$name" == "$col_name" ]]; then
            col_number=$counter
            break
        fi
    done < "$DB_DIR/$db_name/$table_name.meta"

    if [[ "$col_number" -eq 0 ]]; then
        echo "Error: Column '$col_name' not found."
        read -p "Press Enter to continue..."
        return
    fi

    local tmp_file="$DB_DIR/$db_name/$table_name.tmp"
    > "$tmp_file"

    while IFS='|' read -ra fields; do
        if [[ "${fields[$((col_number - 1))]}" != "$del_value" ]]; then

            local row=""
            for field in "${fields[@]}"; do
                if [[ -z "$row" ]]; then row="$field"
                else row="$row|$field"; fi
            done

            echo "$row" >> "$tmp_file"
        fi
    done < "$DB_DIR/$db_name/$table_name.data"

    mv "$tmp_file" "$DB_DIR/$db_name/$table_name.data"

    echo "Rows deleted successfully!"
    read -p "Press Enter to continue..."
}

drop_table() {
    local db_name=$1

    read -p "Table name to drop: " table_name

    if ! table_exists "$db_name" "$table_name"; then
        echo "Error: Table '$table_name' does not exist!"
        read -p "Press Enter to continue..."
        return
    fi

    read -p "Are you sure? (y/n): " confirm

    if [[ "$confirm" == "y" ]]; then
        rm "$DB_DIR/$db_name/$table_name.meta"
        rm "$DB_DIR/$db_name/$table_name.data"
        echo "Table '$table_name' dropped."
    else
        echo "Cancelled."
    fi

    read -p "Press Enter to continue..."
}


list_tables() {
    local db_name=$1

    echo "================================"
    echo "   Tables in '$db_name'"
    echo "================================"
    echo ""

    local found="no"

    for meta_file in "$DB_DIR/$db_name"/*.meta; do
        if [[ -f "$meta_file" ]]; then
            local filename="${meta_file##*/}"
            local tname="${filename%.meta}"
            echo "  - $tname"
            found="yes"
        fi
    done

    if [[ "$found" == "no" ]]; then
        echo "  No tables found."
    fi

    echo ""
    read -p "Press Enter to continue..."
}