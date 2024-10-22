#!/bin/bash

# Check if the file 'current_season_games.csv' exists and isn't empty
if [[ ! -f current_season_games.csv ]] || [[ $(wc -l < current_season_games.csv) -le 1 ]]; then
    # If there's no file or the file only has a header, display this message
    echo "There are no games yet."
    exit 1
fi

printf "%-25s %-25s %-15s %-15s %-10s\n" "Home Team" "Away Team" "Home Score" "Away Score" "Winner"

# IFS=',' sets the delimiter to a comma
# tail -n +2 reads from the second line onward
tail -n +2 current_season_games.csv | while IFS=',' read -r homeTeam awayTeam homeScore awayScore winner; do
    printf "%-25s %-25s %-15s %-15s %-10s\n" "$homeTeam" "$awayTeam" "$homeScore" "$awayScore" "$winner"
done

