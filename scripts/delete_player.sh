#!/bin/bash

delete_player () {
	 name_to_delete="$1"

	#path to the database
	file="../databases/players.csv"

	# Find the line number the player name to be deleted
	line_number=$(grep -n "$name_to_delete" "$file" | tail -n 1 | cut -d: -f1)
	# Check if the name was found
	if [ -n "$line_number" ]; then
  	#Delete the line with the last occurrence of the name or also deletes the only occurence of the name
  	sed -i "${line_number}d" "$file"
  	echo "Deleted '$name_to_delete' at line $line_number."
	else
  	echo "Name '$name_to_delete' not found in the database."
	fi
}

echo "Enter the player name that you want to delete"
read a

delete_player "$a"

