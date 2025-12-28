function InsertTb {

	read -p "Enter Table Name to Insert Data: " TableInsert

	# Validate table name
	if [[ ! "$TableInsert" =~ ^[a-zA-Z_] ]]; then
		echo "Error: Invalid Table Name, The Name Must Start With a Letter or Underscore."
		return

	# Use '+' to require at least one character in the name
	# Avoid '*' to prevent allowing an empty name
	elif [[ ! "$TableInsert" =~ ^[a-zA-Z_0-9]+$ ]]; then
		echo "Error: Invalid Table Name, Contain Only Letters, Numbers, and Underscores."
		return

	elif [[ ! -e "$TableInsert" ]]; then
		echo "Error: Table "$TableInsert" Does not Exist."
		return
	fi

	# Check metadata file
	MetadataFile=""$TableInsert".metadata"
	if [[ ! -e "$MetadataFile" ]]; then
		echo "Error: Metadata File for "$TableInsert" is Missing!"
		return
	fi

	Columns=()
	DataTypes=()
	PrimaryKey=""


	while IFS=': ' read -r key value; do
	    case "$key" in
		'"Column Name"') Columns+=("${value// /}"); prev_col="${value// /}" ;;
		'"Column Type"') DataTypes+=("${value// /}") ;;
		'"Primary Key"') 
		    if [[ "${value,,}" == "y" || "${value,,}" == "yes" ]]; then
		        PrimaryKey="$prev_col"
		    fi
		    ;;
	    esac
	done < "$MetadataFile"


	echo "Columns: ${Columns[@]}"
	echo "Data Types: ${DataTypes[@]}"
	echo "Primary Key: $PrimaryKey"
	echo "-----------------------------------"



	user_input_array=()

	echo "Inserting into Table: '$TableInsert'"
	echo "-----------------------------------"

	
	values=()

	# Input values for each column
	for ((i=0; i<${#Columns[@]}; i++)); do
	column_name="${Columns[i]}"
	column_type="${DataTypes[i]}"

	while true; do
	    read -p "Enter Value for '$column_name' ($column_type): " value

	    # Check data type
	    if [[ "$column_type" =~ ^(int|Int)$ ]] && ! [[ "$value" =~ ^[0-9]+$ ]]; then
		echo "Error: '$column_name' Must be an Integer."
		continue
	    elif [[ "$column_type" =~ ^(str|Str)$ ]] && [[ "$value" =~ ^[0-9]+$ ]]; then
		echo "Error: '$column_name' Must be a String."
		continue
	    fi

	    # Check Primary Key
	    if [[ "$column_name" == "$PrimaryKey" ]]; then
		if grep -q "^$value|" "$TableInsert"; then
		    echo "Error: Duplicate Value for Primary Key '$column_name'."
		    continue
		fi
	    fi

	    values+=("$value")
	    break
	done
	done

	# Insert new row
	echo "${values[*]}" | tr ' ' '|' >> "$TableInsert"
	echo "Data Inserted Successfully Into '$TableInsert'."
	echo "-----------------------------------"

}

