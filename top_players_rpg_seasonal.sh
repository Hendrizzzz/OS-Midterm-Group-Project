#!/bin/bash

# Variable to hold the name of the data file
data_file="players.csv"

# Check if the CSV file exists
if [ ! -f "$data_file" ]; then
  echo "File not found: $data_file"
  exit 1
fi

# Prompt the user for a year
read -p "Enter the year (2020-2023): " input_year
echo "Players with the highest RPG for $input_year"

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
