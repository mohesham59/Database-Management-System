#!/usr/bin/env bash

#============== source partion =============== 
source "$PROJECT_ROOT/DatabaseScripts/lib/validation.sh"
#=============================================

CreationFunction() {
  
  local Db_Name
  read -p "Enter Data Base Name please: " Db_Name
 
 # using validation function to validated the entered name #
 
  if ! validate_db_name "$Db_Name" ; then
    echo "Please try again with a valid database name."
     return 1
  fi

# validate if the data base alrady exect or no #

  if [[ -e "$PROJECT_DIR/$Db_Name" ]]; then
   echo "The database '$Db_Name' already exists in $PROJECT_DIR."
   return 1

  else
	local db_path="$PROJECT_ROOT/storage/databases/$Db_Name"
	mkdir -p "$db_path/tables"
	mkdir -p "$db_path/metadata"

    echo "The database '$Db_Name' was created :) in $db_path"
  fi
}
