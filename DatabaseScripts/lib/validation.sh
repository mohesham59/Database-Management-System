#!/usr/bin/env bash

validate_db_name() {
  local dbname="$1"
  local reserved_keywords=(
    select insert update delete create drop alter
    table from where join user database
  )
  
  if [[ -z "$dbname" ]]; then
    echo "Invalid: name cannot be empty."
    return 1
  fi

 
  if (( ${#dbname} > 64 )); then
    echo "Invalid: name is longer than 64 characters."
    return 1
  fi


  if [[ ! $dbname =~ ^[a-zA-Z] ]]; then
    echo "Invalid: name must start with a letter (a-z or A-Z)."
    return 1
  fi


  if [[ ! $dbname =~ ^[a-zA-Z0-9_]+$ ]]; then
    echo "Invalid: name can only contain letters, digits, and underscores."
    return 1
  fi

  # Check for reserved keywords array  (case-insensitive)
  local dbname_lower="${dbname,,}"
  for word in "${reserved_keywords[@]}"; do
    if [[ "$dbname_lower" == "$word" ]]; then
      echo "Invalid: '$dbname' is a reserved keyword."
      return 1
    fi
  done

  return 0
}
