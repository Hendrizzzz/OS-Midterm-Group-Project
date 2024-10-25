#!/bin/bash

# Define the input CSV file (make sure to provide the correct path)
input_file="../databases/players.csv"

# Check if a year is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <year>"
    exit 1
fi

year_to_filter="$1"

# Read the CSV file, filter by the specified year, skip the header,
# sort by MVP RATING (column 11, which is index 10), and take the top 10 players
mvp_ladder=$(tail -n +2 "$input_file" | awk -F',' -v year="$year_to_filter" '$12 == year' | sort -t ',' -k 10,10nr | head -n 10)

# Check if there are any results
if [ -z "$mvp_ladder" ]; then
    echo "No players found for the year $year_to_filter."
    exit 1
fi

# Print the header
echo "MVP Ladder for $year_to_filter"
echo "----------------------------------------------------------------------------------------------------------------"
printf "%-30s %-25s %-10s %-10s %-10s %-10s %-12s\n" "Name" "Team" "Position" "PPG" "RPG" "APG" "MVP Rating"
echo "----------------------------------------------------------------------------------------------------------------"

# Loop through the sorted players and print their details
while IFS=',' read -r name team position points rebounds assist ppg rpg apg mvp_rating games year status; do
    printf "%-30s %-25s %-10s %-10s %-10s %-10s %-12s\n" "$name" "$team" "$position" "$ppg" "$rpg" "$apg" "$mvp_rating"
done <<< "$mvp_ladder"
