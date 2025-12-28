function SelectTb {
	echo "======================================================"
	read -p "Enter Table Name to Retrieve Data: " TableSelect

	# Check if the user left the table name empty
	if [[ -z "$TableSelect" ]]; then
		echo "Error: Table name cannot be empty."
		return 1
	fi
	
	# Validate the table name format (must start with letter or underscore, contain only alphanumerics and underscores)
	if [[ ! "$TableSelect" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
	echo "Error: Invalid Table Name."
	return 1
	fi
	
	# Define the full paths for the data file and metadata file using the new folder structure
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

	# Initialize an array to store column names
	columns=()
	
	while IFS= read -r line
	do
	# Explanation of the while loop:
	# - This starts a loop that reads the file line by line
	# - IFS= (empty IFS) prevents leading/trailing whitespace from being trimmed
	# - read -r prevents backslash escapes from being interpreted
	# - 'line' is the variable that will hold the content of each line
	# - The loop will continue until all lines in the file are read
	# - The input source is redirected at the end: done < "$metadata_file"
	
		# Remove all double quotes from the line for easier processing
		line="${line//\"/}"  
	
		# Check if the line starts with "Column Name":
		if [[ "$line" == "Column Name":* ]]; then
		    	# Extract the column name by removing everything up to ": " (including the space)
            		# Example: "Column Name: id" → "id"
		    	column_name="${line#*: }"
	    		columns+=("$column_name")	# Add the column name to the array
		fi
	done < "$metadata_file"

	# Safety check: ensure at least one column was found in metadata
	if [[ ${#columns[@]} -eq 0 ]]; then
		echo "Error: No columns found in metadata. Table might be corrupted."
		return 1
	fi

	# Display table information
	echo "Table: $TableSelect"
	echo "Columns: ${columns[*]}"
	echo "------------------------------------------------------------"

	# Print the header row with column names (fixed width for alignment)
	printf "|"
	
	for col in "${columns[@]}"; do
		printf " %-20s |" "$col"		# Left-align column name with 20-character width
	done
	
	echo
	echo "------------------------------------------------------------"

	# Display table data if the file is not empty
	if [[ -s "$table_file" ]]; then
		# Read each record (line) from the data file, splitting by pipe '|'
		while IFS='|' read -ra values
		do
			printf "|"
			# Print each value in the record
			for i in "${!values[@]}"; do
				value="${values[i]}"
				printf " %-20s |" "${value:0:20}"  	#Truncate long values to 20 characters
			done

			# If the record has fewer values than columns (rare case), fill with empty cells
			for ((j=${#values[@]}; j<${#columns[@]}; j++)); do
				printf " %-20s |" ""
			done

			echo
		done < "$table_file"
	else
		echo "No data found in table '$TableSelect'."
	fi

	echo "------------------------------------------------------------"
	record_count=$(wc -l < "$table_file" 2>/dev/null || echo 0)
	echo "Total Records: $record_count"
	echo "======================================================"

	read -p "Press Enter to continue..."
}
