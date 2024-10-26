#!/bin/bash

FILE="../databases/players.csv"
CURRENT_YEAR=$(date +"%Y")

# Function to search for a player
search_player() {
    # Prompt for player's name
    read -p "Enter the player's name to search for: " player_name
    echo "Searching for $player_name..."

    # Search for the player in the CSV for the current year
    player_info=$(grep -i "^$player_name" "$FILE" | grep ",$CURRENT_YEAR,")

    if [[ -n "$player_info" ]]; then
        # Display current year's stats
        team=$(echo "$player_info" | cut -d ',' -f2)
        position=$(echo "$player_info" | cut -d ',' -f3)
        ppg=$(echo "$player_info" | cut -d ',' -f7)
        rpg=$(echo "$player_info" | cut -d ',' -f8)
        apg=$(echo "$player_info" | cut -d ',' -f9)

        echo "Player Found:"
        echo "Name: $player_name"
        echo "Team: $team"
        echo "Position: $position"
        echo "Points per Game: $ppg"
        echo "Rebounds per Game: $rpg"
        echo "Assists per Game: $apg"

        # Ask if the user wants to see detailed stats
        read -p "Do you want to see full stats (y/n)? " confirm
        if [[ "$confirm" == "y" ]]; then
            echo "Full stats for $player_name:"
            printf "%-15s %-20s %-10s %-8s %-10s %-10s %-5s %-5s %-5s %-12s %-6s %-6s %s\n" \
                "Name" "Team" "Position" "Points" "Rebounds" "Assists" "PPG" "RPG" "APG" "MVP Rating" "Games" "Year" "Status"
            grep -i "^$player_name" "$FILE" | while IFS=',' read -r name team position points rebounds assists ppg rpg apg mvprating games year status
            do
                printf "%-15s %-20s %-10s %-8s %-10s %-10s %-5s %-5s %-5s %-12s %-6s %-6s %s\n" \
                    "$name" "$team" "$position" "$points" "$rebounds" "$assists" "$ppg" "$rpg" "$apg" "$mvprating" "$games" "$year" "$status"
            done
        fi
    else
        echo "Player not found or no stats available for the current year."
    fi
}

# Check if the file exists, then call the function
if [[ -f "$FILE" ]]; then
    search_player
else
    echo "Error: $FILE not found!"
fi

