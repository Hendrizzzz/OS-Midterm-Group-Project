#binibinbash

declare -r currentYear="$1"
declare -r currentDirectory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r teamsFilePath="$currentDirectory/../databases/teams.csv"
declare -r playesFilePath="$currentDirectory/../databases/players.csv"
declare -r gamesLogFilePath="$currentDirectory/../databases/current_season_games.csv"


echo "$teamsFilePath"

# the main method of the script
start() {
  echo "Logging a game... " 
  echo ""

  # Validate if both teams have completed 7 games before proceeding
  homeTeam=$(readTeam "Enter home team: ")
  echo "Home Team: $homeTeam"
  awayTeam=$(readTeam "Enter away team: ")
  echo "Away Team: $awayTeam"

  # Log stats and calculate scores for both teams
  homeTeamScore=$(logPlayerStats "$homeTeam")
  awayTeamScore=$(logPlayerStats "$awayTeam")

  # Display the final scores
  echo ""
  echo "Final Score:"
  echo "$homeTeam: $homeTeamScore"
  echo "$awayTeam: $awayTeamScore"
  echo ""

  # Determine the winner
  if [ "$homeTeamScore" -gt "$awayTeamScore" ]; then
    winner="$homeTeam"
  elif [ "$awayTeamScore" -gt "$homeTeamScore" ]; then
    winner="$awayTeam"
  else
    winner="Tie"
  fi

  echo "$homeTeam,$awayTeam,$homeTeamScore,$awayTeamScore,$winner" >> "$gamesLogFilePath"

  echo "Game logged successfully!"
}


# reads a team
readTeam() {
  local teamName

  # Loop until a valid team name is received
  while true; do
    read -p "$1" inputtedTeamName
    local originalName=$(getOriginalTeamName "$inputtedTeamName")
  
    if [ -n "$originalName" ]; then
      echo "$originalName" # Return the original teamName 
      break
    else
      echo "Error : Team does not exist. " >&2
    fi
  done
}


# Check if the team exists and return the original name
getOriginalTeamName() {
  local inputTeamName="$1"
  local normalizedInput=$(echo "$inputTeamName" | tr '[:upper:]' '[:lower:]' | sed 's/ //g')

  # Read the file line by line
  while IFS=, read -r name _ _ _ _ yearLine; do
    local normalizedName=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/ //g')
    
    # Check if the input team name matches the current line's name and the year matches
    if [[ "$normalizedName" == *"$normalizedInput"* && "$yearLine" == "$currentYear" ]]; then
      echo "$name"  # Return the original team name
      return
    fi
  done < "$teamsFilePath"

  echo ""  # Return empty if not found
}

logPlayerStats() {
  local team_name="$1"
  local csv_file="$playesFilePath"
  local current_year="$currentYear"
  local total_team_points=0  # Variable to accumulate the total points
  local updated_players=()  # Array to hold updated player data
  local player_found=false

  echo "Input Stats for team: $team_name (Year: $current_year)"

  # Loop through players and collect their stats
  while IFS=, read -r player_name _ total_points total_rebounds total_assists games_played ppg rpg apg year; do
    # Check if the player belongs to the team and year
    if [[ "$year" == "$current_year" && "$team_name" == *"$team_name"* ]]; then
      player_found=true  # Mark that we've found a player
      # Prompt user for input
      add_points=$(getPlayerInput "$player_name" "points")
      add_rebounds=$(getPlayerInput "$player_name" "rebounds")
      add_assists=$(getPlayerInput "$player_name" "assists")

      # Update totals
      total_points=$((total_points + add_points))
      total_rebounds=$((total_rebounds + add_rebounds))
      total_assists=$((total_assists + add_assists))
      games_played=$((games_played + 1))  # Increment games played

      # Recompute per-game stats
      ppg=$(echo "scale=2; $total_points / $games_played" | bc)
      rpg=$(echo "scale=2; $total_rebounds / $games_played" | bc)
      apg=$(echo "scale=2; $total_assists / $games_played" | bc)

      # Accumulate team points
      total_team_points=$((total_team_points + add_points))

      # Print updated stats for the player
      echo "Updated Stats for $player_name:"
      echo "  Total Points: $total_points, Total Rebounds: $total_rebounds, Total Assists: $total_assists"
      echo "  New Averages -> PPG: $ppg, RPG: $rpg, APG: $apg"

      # Append updated player stats to the array for writing back later
      updated_players+=("$player_name,$2,$total_points,$total_rebounds,$total_assists,$games_played,$ppg,$rpg,$apg,$year")
    else
      # If the player does not belong to the current team, keep their original data
      updated_players+=("$player_name,$2,$total_points,$total_rebounds,$total_assists,$games_played,$ppg,$rpg,$apg,$year")
    fi
  done < "$csv_file"

  # If no players were found for the given team, notify the user
  if [ "$player_found" = false ]; then
    echo "No players found for team: $team_name in year: $current_year."
  fi

  # Write updated player data back to the CSV file
  {
    # Print header
    echo "Player Name,OtherColumn1,Total Points,Total Rebounds,Total Assists,Games Played,PPG,RPG,APG,Year"

    # Loop through updated players and print their data
    for player_data in "${updated_players[@]}"; do
      echo "$player_data"
    done
  } > "$csv_file.tmp"  # Write to a temporary file

  mv "$csv_file.tmp" "$csv_file"  # Replace the original file with the updated file

  # Return total team score
  echo "$total_team_points"
}



start 

