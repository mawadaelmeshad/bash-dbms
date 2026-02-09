#!/bin/bash
validate_name() {
    local name=$1
    if [[ $name =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; then
        return 0
    else
        echo "Error: Invalid name '$name'!"
        return 1 
    fi
}

validate_datatype() {
    local value=$1
    local datatype=$2
    case $datatype in
    int)
       if [[ $value =~ ^-?[0-9]+$ ]]; then
                return 0
       else
             echo "Error: '$value' is not a valid integer!"
             return 1 
       fi
       ;;
       string)
	return 0
       ;;

     esac
}

check_primary_key(){
    local db_name=$1
    local table_name=$2
    local pk_columns=$3
    local pk_values=$4
    local data_file="$DB_DIR/$db_name/$table_name.data"

    if [[ ! -f "$data_file" ]]; then
        return 0 
    fi

    if [[ ! -s "$data_file" ]]; then
        return 0 
    fi

    local pk_index=$(get_column_index "$db_name" "$table_name" "$pk_columns")
    if [[ $pk_index -eq -1 ]]; then
        echo "Error: Column '$pk_columns' not found!"
        return 1
    fi

    while IFS = '|' read -ra row; do
        if [[ "${row[$pk_index]}" == "$pk_values" ]]; then
            echo "Error: Duplicate primary key value '$pk_values'!"
            return 1
        fi
    done < "$data_file" 
    return 0

}

get_column_index(){
    local db_name=$1
    local table_name=$2
    local column_name=$3
    local meta_file="$DB_DIR/$db_name/$table_name.meta"

    if [[ ! -f "$meta_file" ]]; then
        echo "Error: Table '$table_name' does not exist!"
        return 1
    fi

    local index=0
    while IFS='|' read -r col_name col_type col_pk; do
        if [[ "$col_name" == "$column_name" ]]; then
            echo $index
            return 0
        fi
        ((index++))
    done < "$meta_file"

    echo "Error: Column '$column_name' not found in table '$table_name'!"
    return 1
}

get_column_type(){
    local db_name=$1
    local table_name=$2
    local column_name=$3
    local meta_file="$DB_DIR/$db_name/$table_name.meta"

    if [[ ! -f "$meta_file" ]]; then
        echo ""
        return 1
    fi

    while IFS='|' read -r col_name col_type col_pk; do
        if [[ "$col_name" == "$column_name"]]; then
            echo $col_type
            return 0
        fi
    done < "$meta_file"

    echo ""
    return 1
}

is_primary_key(){
    local db_name=$1
    local table_name=$2
    local column_name=$3
    local meta_file="$DB_DIR/$db_name/$table_name.meta"

    if [[ ! -f "$meta_file" ]]; then
        return 1
    fi

    while IFS='|' read -r col_name col_type col_pk; do
        if [[ "$col_name" == "$column_name"]]; then
            if [[ "$col_pk" == "PK" ]]; then
                return 0
            else
                return 1
            fi
        fi
    done < "$meta_file"
    return 1
}

get_pk_columns(){
    local db_name=$1
    local table_name=$2
    local meta_file="$DB_DIR/$db_name/$table_name.meta"

    if [[ ! -f "$meta_file" ]]; then
        echo ""
        return 1
    fi

    while IFS='|' read -r col_name col_type col_pk; do
        if [[ "$col_pk" == "PK" ]]; then
            echo "$col_name"
            return 0
        fi
    done < "$meta_file"

    echo ""
    return 1
}

table_exists(){
    local db_name=$1
    local table_name=$2
    local meta_file="$DB_DIR/$db_name/$table_name.meta"

    if [[ -f "$meta_file" ]]; then
        return 0
    else
        return 1
    fi
}

database_exists(){
    local db_name=$1

    if [[ -d "$DB_DIR/$db_name" ]]; then
        return 0
    else
        return 1
    fi
}

column_exists(){
    local db_name=$1
    local table_name=$2
    local column_name=$3
    local meta_file="$DB_DIR/$db_name/$table_name.meta"

    if [[ ! -f "$meta_file" ]]; then
        return 1
    fi

    while IFS='|' read -r col_name col_type col_pk; do
        if [[ "$col_name" == "$column_name" ]]; then
            return 0
        fi
    done < "$meta_file"

    return 1
}

count_columns(){
    local db_name=$1
    local table_name=$2
    local meta_file="$DB_DIR/$db_name/$table_name.meta"

    if [[ ! -f "$meta_file" ]]; then
        echo 0
        return 1
    fi

    local count=$(wc -l < "$meta_file")
    echo $count
    return 0
}

validate_not_null(){
    local value=$1
    local column_name=$2

    if[[ -z "$value"]]; then
        echo "Error: Column '$column_name' cannot be null!"
        return 1
    fi
    return 0
}