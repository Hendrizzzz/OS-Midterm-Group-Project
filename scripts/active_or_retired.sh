#!/bin/bash

# Define the data file
data_file="../databases/players.csv"
currentYear=$(bash get_current_year.sh)

# Function to count active players
count_active_players() {
    local active_count=0
    read -p "Enter the year (2020-$currentYear): " input_year

    while [[ "$input_year" -gt "$currentYear" && "$inputYear" -lt "2020" ]]; do
    echo "Invalid input. Please enter a valid year."
    read -p "Enter the year (2020-$currentYear): " input_year
    done

    # Read the CSV file, skipping the header
    {
        read  # Skip the header
        while IFS=',' read -r name team position points rebounds assist ppg rpg apg mvp_rating games year status || [[ -n "$status" ]]; do
            # Check if the status is "ACTIVE"
            if [[ "$year" == "$input_year" && "$status" == *"ACTIVE"* ]]; then
                ((active_count++))
            fi
        done
    } < "$data_file"

    # Display the count
    echo "Number of ACTIVE players for season $input_year: $active_count"
}

# Function to count retired players
count_retired_players() {
    local retired_count=0
    read -p "Enter the year (2020-2024): " input_year

    while [[ "$input_year" -gt "$currentYear" && "$inputYear" -lt "2020" ]]; do
        echo "Invalid input. Please enter a valid year."
        read -p "Enter the year (2020-2024): " input_year
    done

    # Read the CSV file, skipping the header
    {
        read  # Skip the header
        while IFS=',' read -r name team position points rebounds assist ppg rpg apg mvp_rating games year status || [[ -n "$status" ]]; do
            # Check if the status is "RETIRED"
            if [[ "$year" == "$input_year" && "$status" == *"RETIRED"* ]]; then
                ((retired_count++))
            fi
        done
    } < "$data_file"

    # Display the count
    echo "Number of RETIRED players for season $input_year: $retired_count"
}

echo "Please choose from the choices below: "
echo "1. Number of active players (for specific season)"
echo "2. Number of retired players (for specific season)"
read -p "Choice: " choice

while [[ "$choice" != "1" && "$choice" != "2" && "$choice" ]]; do
    echo "Invalid input. Please enter a valid choice."
    read -p "Choice: " choice
done

case $choice in
    1) count_active_players ;;
    2) count_retired_players  ;;
    *) echo "Invalid choice." ;;
esac
