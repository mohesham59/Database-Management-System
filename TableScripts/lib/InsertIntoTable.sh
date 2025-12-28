function InsertTb {
	echo "======================================================"
	read -p "Enter Table Name to Insert Data: " TableInsert

	# Check if table name is empty
	if [[ -z "$TableInsert" ]]; then
		echo "Error: Table name cannot be empty."
		return 1
	fi

	if [[ ! "$TableInsert" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
		echo "Error: Invalid Table Name."
		return 1
	fi
	# Define paths for data file and metadata file using the new structure
	local table_file="tables/$TableInsert"
	local metadata_file="metadata/$TableInsert.metadata"

	# Check if the actual data file exists
	if [[ ! -f "$table_file" ]]; then
		echo "Error: Table '$TableInsert' does not exist."
		return 1
	fi

	# Check if the metadata file exists
	if [[ ! -f "$metadata_file" ]]; then
		echo "Error: Metadata file for '$TableInsert' is missing!"
		return 1
	fi

	# Initialize arrays to store column names and data types
	Columns=()
	DataTypes=()
	local PrimaryKey=""    # Will store the name of the primary key column (if any)


	while IFS= read -r line
	do
	# Explanation of the while loop:
	# - This starts a loop that reads the file line by line
	# - IFS= (empty IFS) prevents leading/trailing whitespace from being trimmed
	# - read -r prevents backslash escapes from being interpreted
	# - 'line' is the variable that will hold the content of each line
	# - The loop will continue until all lines in the file are read
	# - The input source is redirected at the end: done < "$metadata_file"

		# Remove all double quotes from the line
		line="${line//\"/}"
		
		# Match the line against known metadata keys  
		case "$line" in
		    "Column Name":*)
		    	# => (#) remove from the beginning
			# => (*: ) until remove the : and take one space after that 
			# Example: "Column Name: id" → "id"
			column_name="${line#*: }"
			Columns+=("$column_name")
			;;
		    "Column Type":*)
			column_type="${line#*: }"
			column_type="${column_type,,}"	# Convert to lowercase (Int → int, STR → str)
			DataTypes+=("$column_type")	# Add data type to array
			;;	
		    "Primary Key":*)
			pk_value="${line#*: }"
			pk_value="${pk_value,,}"	# Convert to lowercase
			# If value is 'y' or 'yes', mark the last added column as primary key
			if [[ "$pk_value" == "y" || "$pk_value" == "yes" ]]; then
			    PrimaryKey="$column_name"
			fi
			;;
		esac
	done < "$metadata_file"  # input is redirected from the metadata file

	# # → means "calculate the length" (length)
	# @ or * → means "all elements in the array"
	if [[ ${#Columns[@]} -eq 0 ]]; then
		echo "Error: No columns found in metadata. The table might be corrupted."
		return 1
	fi

	# Display information about the current insertion operation
	echo "Inserting into Table: '$TableInsert'"
	echo "Columns: ${Columns[*]}"                     # Print all column names separated by space
	
	if [[ -n "$PrimaryKey" ]]; then		# Show PK name only if it exists
    		echo "Primary Key: $PrimaryKey"
	fi
	
	echo "------------------------------------------------"

	# Initialize an empty array to store the values entered by the user for the new record
	local values=()

	# Loop through each column to collect its value from the user
	for ((i = 0; i < ${#Columns[@]}; i++))
	do
		col="${Columns[i]}"      # Current column name
		type="${DataTypes[i]}"   # Current column data type (int or str)

		# Inner loop to keep asking for a valid value until the user provides one
		while true
		do
  			# Prompt the user to enter a value for this column, showing the expected type
			read -p "Enter value for '$col' ($type): " value

	    		# Rule 1: Primary key column cannot be left empty
	    		if [[ "$col" == "$PrimaryKey" && -z "$value" ]]; then
				echo "Error: Primary Key cannot be empty."
				continue  # Ask again for the same column
	    		fi

	    		# Rule 2: If the column type is 'int', validate that the value is a valid integer
	    		if [[ "$type" == "int" ]]; then
				# Allow empty value (if not PK) or a valid integer (optional negative sign)
				if ! [[ "$value" =~ ^-?[0-9]+$ ]] && [[ -n "$value" ]]; then
		    			echo "Error: Must be an integer."
		    			continue
				fi
    			fi

	    		# Rule 3: Prevent duplicate primary key values
	    		if [[ "$col" == "$PrimaryKey" ]]; then
				# Search for the value at the beginning of a line:
				# - Either "value|" (if it's not the only field)
				# - Or "value" (if it's the only field in the line)
				if grep -q "^$value|" "$table_file" 2>/dev/null || grep -q "^$value$" "$table_file" 2>/dev/null; then
				    echo "Error: This Primary Key value already exists."
				    continue
				fi
		    	fi

   		 	# All validations passed → store the value and move to the next column
	    		values+=("$value")
	    		break  # Exit the inner while loop
		done
	done

	# Write the new record to the data file
	IFS="|"                                      # Set Internal Field Separator to pipe
	echo "${values[*]}" >> "$table_file"         # Join values with '|' and append as a new line
	unset IFS                                    # Restore default IFS

	# Success messages
	echo "------------------------------------------------"
	echo "Record inserted successfully into '$TableInsert'!"
	echo "======================================================"
}
