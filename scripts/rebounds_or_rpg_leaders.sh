#!/bin/bash

# Variable to hold the name of the data file
data_file="../databases/players.csv"

# Check if the CSV file exists
if [ ! -f "$data_file" ]; then
  echo "File not found: $data_file"
  exit 1
fi

rebounds_leaders_all_time() {
    echo ""
    # Declare an associative array to hold total rebounds per player
    declare -A player_rebounds

    # Read the CSV file and sum rebounds for each player
    {
    # Skip the header
    read
    # Process the file
    while IFS=',' read -r name team position points rebounds assist ppg rpg apg mvp_rating games year status; do
        player_rebounds["$name"]=$((player_rebounds["$name"] + rebounds))
    done
    } < "$data_file"

    echo "Players with the highest rebounds (All Time)"
    # Output the header with alignment
    printf "%-30s %-25s %-10s %-5s\n" "Name" "Team" "Position" "Rebounds"

    # Create a temporary file to hold player names and total rebounds for sorting
    temp_file=$(mktemp)

    # Populate the temporary file with player names and total rebounds
    for name in "${!player_rebounds[@]}"; do
    echo "$name,${player_rebounds[$name]}" >> "$temp_file"
    done

    # Sort the temporary file by total rebounds and output the top 10
    {
    sort -t',' -k2,2nr "$temp_file" | head -n 10 | while IFS=',' read -r name total_rebounds; do
        # Fetch the team and position of the player
        team=$(grep "^$name," "$data_file" | head -n 1 | cut -d',' -f2)
        position=$(grep "^$name," "$data_file" | head -n 1 | cut -d',' -f3)
        printf "%-30s %-25s %-10s %-5d\n" "$name" "$team" "$position" "$total_rebounds"
    done
    } 

    # Remove the temporary file
    rm "$temp_file"
}

rebounds_leaders_per_season() {
    # Prompt the user for a year
    read -p "Enter the year (2020-2023): " input_year
    echo ""

    while [[ "$input_year" != "2020" && "$input_year" != "2021" && "$input_year" != "2022" && "$input_year" != "2023" ]]; do
        echo "Invalid input. Please enter a valid year."
        read -p "Enter the year (2020-2023): " input_year
    done

    echo "Players with the highest rebounds for $input_year"

    # Output the header with alignment
    printf "%-30s %-25s %-10s %-10s\n" "Name" "Team" "Position" "Rebounds"

    # Create a temporary file to hold player names and rebounds for sorting
    temp_file=$(mktemp)

    # Read the CSV file and filter for the specified year
    {
    # Skip the header
    read
    # Process the file
    while IFS=',' read -r name team position points rebounds assist ppg rpg apg mvp_rating games year status; do
        if [ "$year" == "$input_year" ]; then
        echo "$name,$team,$position,$rebounds" >> "$temp_file"
        fi
    done
    } < "$data_file"

    # Sort the temporary file by rebounds and output the top 10
    {
    sort -t',' -k4,4nr "$temp_file" | head -n 10 | while IFS=',' read -r name team position rebounds; do
        printf "%-30s %-25s %-10s %-10d\n" "$name" "$team" "$position" "$rebounds"
    done
    }

    # Remove the temporary file
    rm "$temp_file"
}

rpg_leaders_all_time() {
    echo ""
    echo "Players with the highest RPG (All Time)"
    printf "%-25s %-25s %-12s %-5s\n" "Name" "Team" "Position" "RPG"

    # Read the CSV file, extract names, teams, positions, and RPG, sort, and display the top 10
    {
    # Skip the header
    read
    # Process the file
    while IFS=',' read -r name team position points rebounds assist ppg rpg apg mvp_rating games year status; do
        echo "$name      ,$team    ,$position       ,$rpg"
    done
    } < "$data_file" | sort -t',' -k4,4nr | head -n 10 | column -t -s ','
}

rpg_leaders_per_season() {
    # Prompt the user for a year
    read -p "Enter the year (2020-2023): " input_year
    echo ""

    while [[ "$input_year" != "2020" && "$input_year" != "2021" && "$input_year" != "2022" && "$input_year" != "2023" ]]; do
        echo "Invalid input. Please enter a valid year."
        read -p "Enter the year (2020-2023): " input_year
    done

    echo "Players with the highest rebounds for $input_year"

    # Output the header with alignment
    printf "%-30s %-25s %-10s %-5s\n" "Name" "Team" "Position" "RPG"

    # Create a temporary file to hold player names and RPG for sorting
    temp_file=$(mktemp)

    # Read the CSV file and filter for the specified year
    {
    # Skip the header
    read
    # Process the file
    while IFS=',' read -r name team position points rebounds assist ppg rpg apg mvp_rating games year status; do
        if [ "$year" == "$input_year" ]; then
        echo "$name,$team,$position,$rpg" >> "$temp_file"
        fi
    done
    } < "$data_file"

    # Sort the temporary file by RPG and output the top 10
    {
    sort -t',' -k4,4nr "$temp_file" | head -n 10 | while IFS=',' read -r name team position rpg; do
        printf "%-30s %-25s %-10s %-5.2f\n" "$name" "$team" "$position" "$rpg"
    done
    }

    # Remove the temporary file
    rm "$temp_file"
}

while true; do
    clear

    echo "Please choose from the choices below: "
    echo "1. Rebounds leaders in a single season"
    echo "2. RPG leaders in a single season"
    echo "3. Rebounds all-time leaders"
    echo "4. RPG all time leaders"
    echo "5. Exit"
    read -p "Choice: " choice

    while [[ "$choice" != "1" && "$choice" != "2" && "$choice" != "3" && "$choice" != "4" && "$choice" != "5" ]]; do
        echo "Invalid input. Please enter a valid choice."
        read -p "Choice: " choice
    done

    case $choice in
        1) rebounds_leaders_per_season ;;
        2) rpg_leaders_per_season ;;
        3) reboundss_leaders_all_time ;;
        4) rpg_leaders_all_time ;;
        5) exit 0 ;;
        *) echo "Invalid choice." ;;
    esac
    
    echo ""
    read -p "Press ENTER to continue."
done
