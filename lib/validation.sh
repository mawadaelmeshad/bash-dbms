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
