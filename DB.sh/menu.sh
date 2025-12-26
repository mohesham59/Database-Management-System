#!/usr/bin/env bash 


while true
do
PS3="please choise what you wnat ?"

	select choice in "Create Database" "List Databases" "Drop Database" "Connect to Database" "Exit"

    do
        case $REPLY in   # REPdLY holds the number input, better for case on numbers
            1)
                echo "Creating database..."
                break
	        ;;
            2)
                echo "Listing databases..."
	        exit 0 ;;
            3)
                echo "Dropping database..."
                exit 0
              ;;
            4)
                echo "Connecting to database..."
                exit 0;;
            5)
                echo "Exiting."
                exit 0
                ;;
            *) 
	       echo "That is not a valid choice.\n";;
            esac
	  done
     done 
