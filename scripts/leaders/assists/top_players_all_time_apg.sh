#!/bin/bash

# Check if the players.csv file exists
if [ ! -f ../../../databases/players.csv ]; then
    echo "Error: players.csv file not found!"
    exit 1
fi

# Read and process the CSV file to calculate total PPG and number of seasons played for each player
awk -F, '
BEGIN {
    printf "%-25s %-30s %-10s %s\n", "Player Name", "Team", "Position", "Average APG"
    printf "%-25s %-30s %-10s %s\n", "-----------", "----", "--------", "-----------"
}
NR > 1 {  # Skip header line
    name = $1
    team = $2
    position = $3
    apg = $9
    year = $12

    # Aggregate total PPG for each player and count distinct seasons
    total_apg[name] += ppg

    # Store team and position for the player (assuming they remain constant)
    if (!(name in team_position)) {
        team_position[name] = team "|" position  # Store team and position
    }

    # Count distinct seasons by adding the year to a set
    seasons[name][year] = 1
}
END {
    # Store players and their average APG in an array for sorting
    for (player in total_apg) {
        num_seasons = length(seasons[player])  # Count distinct seasons
        average_ppg[player] = total_apg[player] / num_seasons;
        split(team_position[player], info, "|");
        players[player] = average_apg[player] "|" info[1] "|" info[2];
    }
    
    # Sort players based on average APG and print the top 10
    n = asorti(players, sorted_players, "@val_num_desc")
    for (i = 1; i <= (n < 10 ? n : 10); i++) {
        player = sorted_players[i]
        split(players[player], data, "|");
        printf "%-25s %-30s %-10s %.2f\n", player, data[2], data[3], data[1];
    }
}
' ../../../databases/players.csv  # Process the players.csv file
