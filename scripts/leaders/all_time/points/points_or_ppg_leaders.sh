#!/bin/bash

# Variable to hold the name of the data file
data_file="players.csv"

# Check if the CSV file exists
if [ ! -f "$data_file" ]; then
  echo "File not found: $data_file"
  exit 1
fi

points_leaders_all_time() {
    # Declare an associative array to hold total points per player
    declare -A player_points

    # Read the CSV file and sum points for each player
    {
    # Skip the header
    read
    # Process the file
    while IFS=',' read -r name team position points rebounds assist ppg rpg apg mvp_rating games year status; do
        player_points["$name"]=$((player_points["$name"] + points))
    done
    } < "$data_file"

    echo "Players with the highest points (All Time)"
    # Output the header with alignment
    printf "%-30s %-25s %-10s %-5s\n" "Name" "Team" "Position" "Points"

    # Create a temporary file to hold player names and total points for sorting
    temp_file=$(mktemp)

    # Populate the temporary file with player names and total points
    for name in "${!player_points[@]}"; do
    echo "$name,${player_points[$name]}" >> "$temp_file"
    done

    # Sort the temporary file by total points and output the top 10
    {
    sort -t',' -k2,2nr "$temp_file" | head -n 10 | while IFS=',' read -r name total_points; do
        # Fetch the team and position of the player
        team=$(grep "^$name," "$data_file" | head -n 1 | cut -d',' -f2)
        position=$(grep "^$name," "$data_file" | head -n 1 | cut -d',' -f3)
        printf "%-30s %-25s %-10s %-5d\n" "$name" "$team" "$position" "$total_points"
    done
    } 

    # Remove the temporary file
    rm "$temp_file"
}

points_leaders_per_season() {
    # Prompt the user for a year
    read -p "Enter the year (2020-2023): " input_year

    while [[ "$input_year" != "2020" && "$input_year" != "2021" && "$input_year" != "2022" && "$input_year" != "2023" ]]; do
        echo "Invalid input. Please enter a valid year."
        read -p "Enter the year (2020-2023): " input_year
    done

    echo "Players with the highest points for" $input_year
    # Output the header with alignment
    printf "%-30s %-25s %-10s %-5s\n" "Name" "Team" "Position" "Points"

    # Create a temporary file to hold player names and points for sorting
    temp_file=$(mktemp)

    # Read the CSV file and filter for the specified year
    {
    # Skip the header
    read
    # Process the file
    while IFS=',' read -r name team position points rebounds assist ppg rpg apg mvp_rating games year status; do
        if [ "$year" == "$input_year" ]; then
        echo "$name,$team,$position,$points" >> "$temp_file"
        fi
    done
    } < "$data_file"

    # Sort the temporary file by points and output the top 10
    {
    sort -t',' -k4,4nr "$temp_file" | head -n 10 | while IFS=',' read -r name team position points; do
        printf "%-30s %-25s %-10s %-5d\n" "$name" "$team" "$position" "$points"
    done
    }

    # Remove the temporary file
    rm "$temp_file"
}

ppg_leaders_all_time() {
    echo "Players with the highest PPG (All Time)"
    printf "%-25s %-25s %-11s %-5s\n" "Name" "Team" "Position" "PPG"
    # Read the CSV file, extract names, teams, positions, and PPG, sort, and display the top 10
    {
    # Skip the header
    read
    # Process the file
    while IFS=',' read -r name team position points rebounds assist ppg rpg apg mvp_rating games year status; do
        echo "$name      ,$team    ,$position       ,$ppg"
    done
    } < "$data_file" | sort -t',' -k4,4nr | head -n 10 | column -t -s ','
}

ppg_leaders_per_season() {
    # Prompt the user for a year
    read -p "Enter the year (2020-2023): " input_year

    while [[ "$input_year" != "2020" && "$input_year" != "2021" && "$input_year" != "2022" && "$input_year" != "2023" ]]; do
        echo "Invalid input. Please enter a valid year."
        read -p "Enter the year (2020-2023): " input_year
    done

    echo "Players with the highest PPG for" $input_year

    # Output the header with alignment
    printf "%-30s %-25s %-10s %-5s\n" "Name" "Team" "Position" "PPG"

    # Create a temporary file to hold player names and PPG for sorting
    temp_file=$(mktemp)

    # Read the CSV file and filter for the specified year
    {
    # Skip the header
    read
    # Process the file
    while IFS=',' read -r name team position points rebounds assist ppg rpg apg mvp_rating games year status; do
        if [ "$year" == "$input_year" ]; then
        echo "$name,$team,$position,$ppg" >> "$temp_file"
        fi
    done
    } < "$data_file"

    # Sort the temporary file by PPG and output the top 10
    {
    sort -t',' -k4,4nr "$temp_file" | head -n 10 | while IFS=',' read -r name team position ppg; do
        printf "%-30s %-25s %-10s %-5.2f\n" "$name" "$team" "$position" "$ppg"
    done
    }

    # Remove the temporary file
    rm "$temp_file"
}

echo "Please choose from the choices below: "
echo "1. All time points leaders"
echo "2. Points leaders (for specific season)"
echo "3. All time PPG leaders"
echo "4. PPG leaders (for specific season)"
read -p "Choice: " choice

while [[ "$choice" != "1" && "$choice" != "2" && "$choice" != "3" && "$choice" != "4" ]]; do
    echo "Invalid input. Please enter a valid choice."
    read -p "Choice: " choice
done

case $choice in
    1) points_leaders_all_time ;;
    2) points_leaders_per_season ;;
    3) ppg_leaders_all_time ;; 
    4) ppg_leaders_per_season ;;
    *) echo "Invalid choice." ;;
esac
