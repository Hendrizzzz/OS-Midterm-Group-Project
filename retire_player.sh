#!/bin/bash

FILE="players.csv"

# Function to retire a player
retire_player() {
    # Prompt for player's name
    while true; do
        read -p "Enter the name of the player to retire: " player_name

        # Search for the player in the CSV
        player_info=$(grep -i "^$player_name" "$FILE")

        if [[ -n "$player_info" ]]; then
            # Player found, display information
            echo "Player found:"
            echo "$player_info"

            # Ask for confirmation to retire the player
            read -p "Are you sure you want to retire this player? (y/n): " confirm
            if [[ "$confirm" == "y" ]]; then
                # Update the player's status to 'Retired'
                sed -i "/^$player_name/s/ACTIVE/RETIRED/" "$FILE"
                echo "The player's status has been changed to Retired."
            else
                echo "Operation cancelled."
            fi
            break
        else
            # Player not found, ask again
            echo "Player not found. Please try again."
        fi
    done
}

if [[ -f "$FILE" ]]; then
    retire_player
else
    echo "Error: $FILE not found!"
fi


