#!/bin/bash

data_file="players.csv"

# Check if the CSV file exists
if [ ! -f "$data_file" ]; then
  echo "File not found: $data_file"
  exit 1
fi

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
