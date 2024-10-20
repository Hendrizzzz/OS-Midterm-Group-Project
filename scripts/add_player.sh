#!/bin/bash

FILE="players.csv"

# Function to add a player
add_player() {
    # Ask for player details
    echo "Input Player Details:"
    read -p "Name: " name
    read -p "Team: " team
    read -p "Position: " position

    # Stats (0)
    points=0
    rebounds=0
    assists=0
    ppg=0.00
    rpg=0.00
    apg=0.00
    mvprating=0.00
    games=0
    year=$(date +%Y)  # Current year
    status="ACTIVE"

    # Append new player to the CSV file
    echo "$name,$team,$position,$points,$rebounds,$assists,$ppg,$rpg,$apg,$mvprating,$games,$year,$status" >> $FILE
    echo "A new player is inserted at the last line of the database for players."
}

if [[ -f "$FILE" ]]; then
    add_player
else
    echo "Error: $FILE not found!"
fi
