#!/bin/bash

# Check if the file 'current_season_games.csv' exists and isn't empty
if [[ ! -f ../databases/current_season_games.csv ]] || [[ $(wc -l < ../databases/current_season_games.csv) -le 1 ]]; then
    echo "There are no games yet."
    exit 1
fi

# Use ─ for the lines to be aligned
printf "%-25s │ %-25s │ %-12s │ %-12s │ %-15s\n" "Home Team" "Away Team" "Home Score" "Away Score" "Winner"
printf '%.0s─' {1..90}; echo ""  # Separator line

# IFS=',' sets the delimiter to a comma
# tail -n +2 reads from the second line onward
tail -n +2 ../databases/current_season_games.csv | while IFS=',' read -r homeTeam awayTeam homeScore awayScore winner; do
    printf "%-25s │ %-25s │ %-12s │ %-12s │ %-15s\n" "$homeTeam" "$awayTeam" "$homeScore" "$awayScore" "$winner"
done
