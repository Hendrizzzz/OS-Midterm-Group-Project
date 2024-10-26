#!/bin/bash

data_file="players.csv"

# Check if the CSV file exists
if [ ! -f "$data_file" ]; then
  echo "File not found: $data_file"
  exit 1
fi

assists_leaders_all_time() {
    # Declare an associative array to hold total assists per player
    declare -A player_assists

    # Read the CSV file and sum assists for each player
    {
    # Skip the header
    read
    # Process the file
    while IFS=',' read -r name team position points rebounds assist ppg rpg apg mvp_rating games year status; do
        player_assists["$name"]=$((player_assists["$name"] + assist))
    done
    } < "$data_file"

    echo "Players with the highest assists (All Time)"
    # Output the header with alignment
    printf "%-30s %-25s %-10s %-10s\n" "Name" "Team" "Position" "Assists"

    # Create a temporary file to hold player names and total assists for sorting
    temp_file=$(mktemp)

    # Populate the temporary file with player names and total assists
    for name in "${!player_assists[@]}"; do
    echo "$name,${player_assists[$name]}" >> "$temp_file"
    done

    # Sort the temporary file by total assists and output the top 10
    {
    sort -t',' -k2,2nr "$temp_file" | head -n 10 | while IFS=',' read -r name total_assists; do
        # Fetch the team and position of the player
        team=$(grep "^$name," "$data_file" | head -n 1 | cut -d',' -f2)
        position=$(grep "^$name," "$data_file" | head -n 1 | cut -d',' -f3)
        printf "%-30s %-25s %-10s %-10d\n" "$name" "$team" "$position" "$total_assists"
    done
    }

    # Remove the temporary file
    rm "$temp_file"
}

assists_leaders_per_season() {
    # Prompt the user for a year
    read -p "Enter the year (2020-2023): " input_year

    while [[ "$input_year" != "2020" && "$input_year" != "2021" && "$input_year" != "2022" && "$input_year" != "2023" ]]; do
        echo "Invalid input. Please enter a valid year."
        read -p "Enter the year (2020-2023): " input_year
    done
    
    echo "Players with the highest assists for $input_year"

    # Output the header with alignment
    printf "%-30s %-25s %-10s %-10s\n" "Name" "Team" "Position" "Assists"

    # Create a temporary file to hold player names and assists for sorting
    temp_file=$(mktemp)

    # Read the CSV file and filter for the specified year
    {
    # Skip the header
    read
    # Process the file
    while IFS=',' read -r name team position points rebounds assist ppg rpg apg mvp_rating games year status; do
        if [ "$year" == "$input_year" ]; then
        echo "$name,$team,$position,$assist" >> "$temp_file"
        fi
    done
    } < "$data_file"

    # Sort the temporary file by assists and output the top 10
    {
    sort -t',' -k4,4nr "$temp_file" | head -n 10 | while IFS=',' read -r name team position assists; do
        printf "%-30s %-25s %-10s %-10d\n" "$name" "$team" "$position" "$assists"
    done
    }

    # Remove the temporary file
    rm "$temp_file"
}

apg_leaders_all_time() {
    echo "Players with the highest APG (All Time)"
    printf "%-25s %-25s %-12s %-5s\n" "Name" "Team" "Position" "APG"

    # Read the CSV file, extract names, teams, positions, and APG, sort, and display the top 10
    {
    # Skip the header
    read
    # Process the file
    while IFS=',' read -r name team position points rebounds assist ppg rpg apg mvp_rating games year status; do
        echo "$name   ,$team    ,$position       ,$apg"
    done
    } < "$data_file" | sort -t',' -k4,4nr | head -n 10 | column -t -s ','
}

apg_leaders_per_season() {
    # Prompt the user for a year
    read -p "Enter the year (2020-2023): " input_year

    while [[ "$input_year" != "2020" && "$input_year" != "2021" && "$input_year" != "2022" && "$input_year" != "2023" && "$input_year" != "2024" ]]; do
        echo "Invalid input. Please enter a valid year."
        read -p "Enter the year (2020-2023): " input_year
    done

    echo "Players with the highest APG for $input_year"

    # Output the header with alignment
    printf "%-30s %-25s %-10s %-5s\n" "Name" "Team" "Position" "APG"

    # Create a temporary file to hold player names and APG for sorting
    temp_file=$(mktemp)

    # Read the CSV file and filter for the specified year
    {
    # Skip the header
    read
    # Process the file
    while IFS=',' read -r name team position points rebounds assist ppg rpg apg mvp_rating games year status; do
        if [ "$year" == "$input_year" ]; then
        echo "$name,$team,$position,$apg" >> "$temp_file"
        fi
    done
    } < "$data_file"

    # Sort the temporary file by APG and output the top 10
    {
    sort -t',' -k4,4nr "$temp_file" | head -n 10 | while IFS=',' read -r name team position apg; do
        printf "%-30s %-25s %-10s %-5.2f\n" "$name" "$team" "$position" "$apg"
    done
    }

    # Remove the temporary file
    rm "$temp_file"
}

while true; do
    clear

    echo "Please choose from the choices below: "
    echo "1. Assists leaders this season"
    echo "2. APG leaders this season"
    echo "3. Assists all-time leaders"
    echo "4. APG all time leaders"
    echo "5. Exit"
    read -p "Choice: " choice

    while [[ "$choice" != "1" && "$choice" != "2" && "$choice" != "3" && "$choice" != "4" && "$choice" != "5" ]]; do
        echo "Invalid input. Please enter a valid choice."
        read -p "Choice: " choice
    done

    case $choice in
        1) assists_leaders_per_season ;;
        2) apg_leaders_per_season ;;
        3) assists_leaders_all_time ;;
        4) apg_leaders_all_time ;;
        5) exit 0 ;;
        *) echo "Invalid choice." ;;
    esac
    
    read -p "Press ENTER to continue."
done
