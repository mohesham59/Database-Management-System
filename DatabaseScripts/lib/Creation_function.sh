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

  # FIXED: validate if the database already exists or not
  local db_path="$PROJECT_ROOT/storage/databases/$Db_Name"
  
  if [[ -e "$db_path" ]]; then
    echo "The database '$Db_Name' already exists in $db_path."
    return 1
  else
    mkdir -p "$db_path/tables"
    mkdir -p "$db_path/metadata"
    echo "The database '$Db_Name' was created successfully in $db_path"
  fi
}