function SelectTb {
	echo "======================================================"
	read -p "Enter Table Name to Retrieve Data: " TableSelect
	
	# Check if the user left the table name empty
	if [[ -z "$TableSelect" ]]; then
		echo "Error: Table name cannot be empty."
		return 1
	fi
	
	# Validate the table name format
	if [[ ! "$TableSelect" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
		echo "Error: Invalid Table Name."
		return 1
	fi
	
	# Define the full paths for the data file and metadata file
	local table_file="tables/$TableSelect"
	local metadata_file="metadata/$TableSelect.metadata"
	
	# Check if the data file exists
	if [[ ! -f "$table_file" ]]; then
		echo "Error: Table '$TableSelect' does not exist."
		return 1
	fi
	
	# Check if the metadata file exists
	if [[ ! -f "$metadata_file" ]]; then
		echo "Error: Metadata file for '$TableSelect' is missing!"
		return 1
	fi
	
	# Initialize arrays to store column names and types
	columns=()
	column_types=()
	
	while IFS= read -r line
	do
		line="${line//\"/}"
		if [[ "$line" == "Column Name":* ]]; then
			column_name="${line#*: }"
			columns+=("$column_name")
		elif [[ "$line" == "Column Type":* ]]; then
			column_type="${line#*: }"
			column_types+=("$column_type")
		fi
	done < "$metadata_file"
	
	# Check there is metadata 
	if [[ ${#columns[@]} -eq 0 ]]; then
		echo "Error: No columns found in metadata. Table might be corrupted."
		return 1
	fi
	
	# Display available columns with their types
	echo "Available Columns:"
	for i in "${!columns[@]}"; do
		echo "  [$((i+1))] ${columns[i]} (${column_types[i]:-unknown})"
	done
	echo "------------------------------------------------------------"
	
	# Ask user which columns to display
	read -p "Enter column names to display (comma-separated, or press Enter for all): " selected_cols
	
	# Parse selected columns
	declare -a display_columns
	declare -a display_indices
	
	if [[ -z "$selected_cols" ]]; then
		# Display all columns
		display_columns=("${columns[@]}")
		for i in "${!columns[@]}"; do
			display_indices+=("$i")
		done
	else
		# Parse user input and validate column names
		IFS=',' read -ra user_cols <<< "$selected_cols"
		for user_col in "${user_cols[@]}"; do
			# Trim whitespace
			user_col=$(echo "$user_col" | xargs)
			
			# Find column index
			found=0
			for i in "${!columns[@]}"; do
				if [[ "${columns[i]}" == "$user_col" ]]; then
					display_columns+=("$user_col")
					display_indices+=("$i")
					found=1
					break
				fi
			done
			
			if [[ $found -eq 0 ]]; then
				echo "Warning: Column '$user_col' not found. Skipping..."
			fi
		done
		
		if [[ ${#display_columns[@]} -eq 0 ]]; then
			echo "Error: No valid columns selected."
			return 1
		fi
	fi
	
	# Ask for WHERE condition with operators
	echo "------------------------------------------------------------"
	echo "WHERE Operators: = (equal), != (not equal), > (greater), < (less), >= , <= , LIKE (pattern)"
	read -p "Apply WHERE condition? (y/n): " use_where
	
	where_column=""
	where_operator=""
	where_value=""
	where_index=-1
	
	if [[ "$use_where" == "y" || "$use_where" == "Y" ]]; then
		read -p "Enter column name for WHERE condition: " where_column
		
		# Find the column index
		for i in "${!columns[@]}"; do
			if [[ "${columns[i]}" == "$where_column" ]]; then
				where_index=$i
				break
			fi
		done
		
		if [[ $where_index -eq -1 ]]; then
			echo "Error: Column '$where_column' not found."
			return 1
		fi
		
		read -p "Enter operator (=, !=, >, <, >=, <=, LIKE): " where_operator
		read -p "Enter value to compare: " where_value
	fi
	
	# Display query information
	echo "======================================================"
	echo "Table: $TableSelect"
	echo "Displaying Columns: ${display_columns[*]}"
	if [[ $where_index -ne -1 ]]; then
		echo "WHERE: $where_column $where_operator '$where_value'"
	fi
	echo "------------------------------------------------------------"
	
	# Function to evaluate WHERE condition
	evaluate_where() {
		local actual_value="$1"
		local operator="$2"
		local expected_value="$3"
		
		case "$operator" in
			"=")
				[[ "$actual_value" == "$expected_value" ]]
				;;
			"!=")
				[[ "$actual_value" != "$expected_value" ]]
				;;
			">")
				# Try numeric comparison first, fall back to string comparison
				if [[ "$actual_value" =~ ^[0-9]+$ ]] && [[ "$expected_value" =~ ^[0-9]+$ ]]; then
					(( actual_value > expected_value ))
				else
					[[ "$actual_value" > "$expected_value" ]]
				fi
				;;
			"<")
				if [[ "$actual_value" =~ ^[0-9]+$ ]] && [[ "$expected_value" =~ ^[0-9]+$ ]]; then
					(( actual_value < expected_value ))
				else
					[[ "$actual_value" < "$expected_value" ]]
				fi
				;;
			">=")
				if [[ "$actual_value" =~ ^[0-9]+$ ]] && [[ "$expected_value" =~ ^[0-9]+$ ]]; then
					(( actual_value >= expected_value ))
				else
					[[ "$actual_value" > "$expected_value" ]] || [[ "$actual_value" == "$expected_value" ]]
				fi
				;;
			"<=")
				if [[ "$actual_value" =~ ^[0-9]+$ ]] && [[ "$expected_value" =~ ^[0-9]+$ ]]; then
					(( actual_value <= expected_value ))
				else
					[[ "$actual_value" < "$expected_value" ]] || [[ "$actual_value" == "$expected_value" ]]
				fi
				;;
			"LIKE"|"like")
				# Simple pattern matching (use * as wildcard)
				expected_value="${expected_value//\*/.*}"
				[[ "$actual_value" =~ $expected_value ]]
				;;
			*)
				echo "Error: Unknown operator '$operator'"
				return 1
				;;
		esac
	}
	
	# Print the header row
	printf "|"
	for col in "${display_columns[@]}"; do
		printf " %-20s |" "$col"
	done
	echo
	echo "------------------------------------------------------------"
	
	# Display filtered data
	record_count=0
	
	if [[ -s "$table_file" ]]; then
		while IFS='|' read -ra values
		do
			# Apply WHERE filter if specified
			if [[ $where_index -ne -1 ]]; then
				if ! evaluate_where "${values[where_index]}" "$where_operator" "$where_value"; then
					continue  # Skip this row
				fi
			fi
			
			# Display selected columns
			printf "|"
			for idx in "${display_indices[@]}"; do
				value="${values[idx]}"
				printf " %-20s |" "${value:0:20}"
			done
			echo
			((record_count++))
		done < "$table_file"
	fi
	
	if [[ $record_count -eq 0 ]]; then
		echo "No matching records found."
	fi
	
	echo "------------------------------------------------------------"
	echo "Total Matching Records: $record_count"
	echo "======================================================"
	read -p "Press Enter to continue..."
}
