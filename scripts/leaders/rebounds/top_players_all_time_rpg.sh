#!/bin/bash

# Check if the players.csv file exists
if [ ! -f ../../../databases/players.csv ]; then
    echo "Error: players.csv file not found!"
    exit 1
fi

# Read and process the CSV file to find the top 10 players based on average RPG
awk -F, '
BEGIN {
    printf "%-25s %-30s %-10s %s\n", "Player Name", "Team", "Position", "Average RPG"
    printf "%-25s %-30s %-10s %s\n", "-----------", "----", "--------", "-----------"
}
NR > 1 {  # Skip header line
    name = $1
    team = $2
    position = $3
    rpg = $8  # Extract RPG value from the 8th column
    year = $12  # Extract year from the 12th column

    # Aggregate total RPG for each player
    total_rpg[name] += rpg

    # Count distinct seasons for each player
    if (!(year in seasons[name])) {
        seasons[name][year] = 1  # Mark the year as a distinct season
    }

    # Store team and position for the player
    if (!(name in player_info)) {
        player_info[name] = team "|" position  # Store team and position
    }
}
END {
    # Print average RPG for each player
    for (player in total_rpg) {
        num_seasons = length(seasons[player]);  # Count distinct seasons
        average_rpg = (num_seasons > 0) ? total_rpg[player] / num_seasons : 0;  # Divide by the number of seasons
        split(player_info[player], info, "|");
        # Print out the player info along with the average RPG
        printf "%-25s %-30s %-10s %.2f\n", player, info[1], info[2], average_rpg;  
    }
}
' ../../../databases/players.csv | sort -k8,8nr | head -n 10  # Sort by the last column (average RPG) and get top 10
