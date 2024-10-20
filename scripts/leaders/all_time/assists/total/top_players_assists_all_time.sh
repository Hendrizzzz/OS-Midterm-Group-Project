#!/bin/bash

# Variable to hold the name of the data file
data_file="players.csv"

# Check if the CSV file exists
if [ ! -f "$data_file" ]; then
  echo "File not found: $data_file"
  exit 1
fi

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