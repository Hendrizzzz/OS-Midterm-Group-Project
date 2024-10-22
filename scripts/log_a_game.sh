#binibinbash

declare -r currentYear="$1"
declare -r teamsFilePath="teams.csv"
declare -r playesFilePath="players.csv"
declare -r gamesLogFilePath="current_season_games.csv"

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
    local total_team_points=0
    local updated_players=()

    
    echo "Input Stats for team: $team_name (Year: $current_year)" >&2
    read -r mem

    while IFS=, read -r player_name team position total_points total_rebounds total_assists ppg rpg apg mvpRating games year status; do
        if [[ "$year" == "$current_year" && "$team" == "$team_name" ]]; then
            add_points=$(getPlayerInput "$player_name" "points")
            add_rebounds=$(getPlayerInput "$player_name" "rebounds")
            add_assists=$(getPlayerInput "$player_name" "assists")

            total_points=$((total_points + add_points))
            total_rebounds=$((total_rebounds + add_rebounds))
            total_assists=$((total_assists + add_assists))
            games_played=$((games_played + 1))

            ppg=$(echo "scale=2; $total_points / $games_played" | bc)
            rpg=$(echo "scale=2; $total_rebounds / $games_played" | bc)
            apg=$(echo "scale=2; $total_assists / $games_played" | bc)

            total_team_points=$((total_team_points + add_points))

            # Print updated stats for the player in the desired format
            echo "$player_name points: $total_points" >&2
            echo "$player_name rebounds: $total_rebounds" >&2
            echo "$player_name assists: $total_assists" >&2

            updated_players+=("$player_name,$team,$total_points,$total_rebounds,$total_assists,$games_played,$ppg,$rpg,$apg,$year")
        else
            updated_players+=("$player_name,$team,$position,$total_points,$total_rebounds,$total_assists,$ppg,$rpg,$apg,$mvpRating,$games,$year,$status")
        fi
    done < "$csv_file"

    {
        echo "Player Name,OtherColumn1,Total Points,Total Rebounds,Total Assists,Games Played,PPG,RPG,APG,Year"
        for player_data in "${updated_players[@]}"; do
            echo "$player_data"
        done
    } > "$csv_file.tmp"

    mv "$csv_file.tmp" "$csv_file"

    echo "$total_team_points"
}


# Function to get player input
getPlayerInput() {
    local player_name="$1"
    local stat_name="$2"
    local input_value

    while true; do
        echo ""  # Optional: clear previous line for readability
        read -r -p "$player_name $stat_name: " >&2 input_value

        # Check if the input is non-empty
        if [[ -z "$input_value" ]]; then
            echo "Input cannot be empty. Please enter a valid integer for $stat_name." >&2
            continue  # Skip to the next iteration of the loop
        fi

        # Validate that the input is a non-negative integer
        if [[ "$input_value" =~ ^[0-9]+$ ]]; then
            echo "$input_value"  # Output the valid input
            return 0  # Successful exit
        else
            echo "Invalid input. Please enter a valid integer for $stat_name." >&2
        fi
    done
}



start 
