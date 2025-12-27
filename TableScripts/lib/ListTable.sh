#!/bin/bash
function ListTb {
	echo "Avaliable Table:"
	ls -F | grep -v "metadata" | grep -v "/" | grep -v *.sh

	echo "======================================================"
}
