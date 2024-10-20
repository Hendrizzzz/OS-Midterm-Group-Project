#!/bin/bash

# Variable to hold the name of the data file
data_file="players.csv"

# Check if the CSV file exists
if [ ! -f "$data_file" ]; then
  echo "File not found: $data_file"
  exit 1
fi

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