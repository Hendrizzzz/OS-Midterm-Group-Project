#!/bin/bash

# File name
filename="../databases/players.csv"

# Prompt user for player name
read -p "Enter the name of the player to retire: " player_name

# Search and update the player's status in the CSV
if grep -q "^$player_name," "$filename"; then
    # Use awk and sed to update the status
    awk -F, -v player="$player_name" -v OFS="," '
    BEGIN {IGNORECASE=1}
    {
        # Check if the player name matches (case-insensitive)
        if (tolower($1) == tolower(player)) {
            $NF = "RETIRED"  # Update STATUS column to "RETIRED"
        }
        print $0
    }' "$filename" > temp.csv && mv temp.csv "$filename"

    echo "$player_name has been retired."
else
    echo "Player '$player_name' not found."
fi
