#!/bin/bash
function ListTb {
	echo "Available Tables:"
	
	if ls tables/* 1> /dev/null 2>&1; then
		ls -1 tables/ 
	else
		echo "(No tables yet)"
	fi

}
