declare currentYear="$1"
declare -r currentDirectory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r teamsFilePath="$currentDirectory/../databases/teams.csv"
declare -r playersFilePath="$currentDirectory/../databases/players.csv"
declare -r gamesLogFilePath="$currentDirectory/../databases/current_season_games.csv"
declare -r mvpsFilePath="$currentDirectory/../databases/mvps.csv"
declare -r championsFilePath="$currentDirectory/../databases/champions.csv"

# the main method of the script
start() {
# Check if the season is complete
if isSeasonComplete; then 
    echo "The $currentYear season is already complete."
    echo 
    echo "Do you want to start a new season? (y/n)" 
    
    read -r user_input

    while true; do
        if [[ "$user_input" == "y" || "$user_input" == "Y" ]]; then
            echo "Starting a new season..." 
            resetFiles
	    updateCurrentYear
            break
        elif [[ "$user_input" == "n" || "$user_input" == "N" ]]; then
            echo "Exiting without starting a new season." 
            return
        else
            echo "Invalid input. Please enter 'y' or 'n'." 
        fi
    done
fi


  #Validate if the regular season is done
  if isRegularSeasonComplete; then 
    announceMVP "$currentYear" 
    echo "The regular season is already over. Do you want to proceed with playoffs(y) or check stats first(n)?" >&2
    read -r -p "Enter your choice: " choice
    
    case "$choice" in
        [yY])
            echo "Proceeding to playoffs..."
            proceedToPlayoffs
            ;;
        *)
            return
            ;;
    esac
  fi

  echo "Logging a game... " 
  echo "Only the top 4 teams will advance to the playoffs!"
  echo "Year: $currentYear"
  echo ""

  # Validate if both teams have completed 7 games before proceeding
  homeTeam=$(readTeam "Enter home team: ")
  echo "Home Team: $homeTeam"

  awayTeam=$(readTeam "Enter away team: ")
  echo "Away Team: $awayTeam"

  # Log stats and calculate scores for both teams
  homeTeamScore=$(logPlayerStats "$homeTeam")
  echo "home Team Score in start method: $homeTeamScore"
  awayTeamScore=$(logPlayerStats "$awayTeam")
  echo "away team score in start method: $awayTeamScore"

  # Determine the winner
  if [ "$homeTeamScore" -gt "$awayTeamScore" ]; then
    winner="$homeTeam"
    loser="$awayTeam"
  else
    winner="$awayTeam"
    loser="$homeTeam"
  fi

  # Display the final scores
    echo ""
    echo "Final Score:"
    echo "$homeTeam: $homeTeamScore"
    echo "$awayTeam: $awayTeamScore"
    echo "Winner: $winner"

  echo "$homeTeam,$awayTeam,$homeTeamScore,$awayTeamScore,$winner" >> "$gamesLogFilePath"
  updateStandings "$winner" "winner" "$currentYear"
  updateStandings "$loser" "loser" "$currentYear"

  echo "Game logged successfully!"
}


# reads a team
readTeam() {
local originalName
  # Loop until a valid team name is received
  while true; do
    read -r -p "$1" inputtedTeamName
    originalName=$(getOriginalTeamName "$inputtedTeamName")

    if [ -n "$originalName" ]; then
        if teamPlayed7Matches "$homeTeam"; then 
            echo "The $homeTeam has already played 7 matches. Please enter another team."
        else 
            echo "$originalName" # Return the original teamName 
            break
        fi
    else
        echo "Error : Team does not exist. " >&2
    fi
  done
}



# Check if the team exists and return the original name
getOriginalTeamName() {
  local normalizedInput
  local normalizedName
  
  local inputTeamName="$1"
  normalizedInput=$(echo "$inputTeamName" | tr '[:upper:]' '[:lower:]' | sed 's/ //g')

  # Read the file line by line
  while IFS=, read -r name _ _ _ _ yearLine; do
    normalizedName=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/ //g')

    # Check if the input team name matches the current line's name and the year matches
    if [[ "$normalizedName" == *"$normalizedInput"* && "$yearLine" == "$currentYear" ]]; then
      echo "$name"  # Return the original team name
      return
    fi
  done < "$teamsFilePath"

}

logPlayerStats() {
    local team_name="$1"
    local csv_file="$playersFilePath"
    local current_year="$currentYear"
    local total_team_points=0
    local updated_players=()

    echo "Input Stats for team: $team_name (Year: $current_year)" >&2

    # Open the CSV file with a different file descriptor (FD 3)
    exec 3<"$csv_file"

    # Read from the CSV file using FD 3, while keeping stdin free for user input
	# Skip the header line first
	read -r header <&3

# Now read from the second line onwards
while IFS=, read -r player_name team position total_points total_rebounds total_assists ppg rpg apg mvpRating games year status <&3; do
    if [[ "$year" == "$current_year" && "$team" == "$team_name" && "$status" == "ACTIVE" ]]; then
        # Get user input for points, rebounds, and assists
	echo "$player_name" >&2
        points=$(getPlayerInput "points")
        rebounds=$(getPlayerInput "rebounds")
        assists=$(getPlayerInput "assists")

        # Update stats
        new_total_points=$((total_points + points))
        new_total_rebounds=$((total_rebounds + rebounds))
        new_total_assists=$((total_assists + assists))
        new_games_played=$((games + 1))
        new_MVP_rating=$(bash mvp_rating_calculator.sh "$new_total_points" "$new_total_rebounds" "$new_total_assists" "$new_games_played")

        # Recalculate averages
        new_ppg=$(awk "BEGIN {printf \"%.2f\", $new_total_points / $new_games_played}")
        new_rpg=$(awk "BEGIN {printf \"%.2f\", $new_total_rebounds / $new_games_played}")
        new_apg=$(awk "BEGIN {printf \"%.2f\", $new_total_assists / $new_games_played}")

        total_team_points=$((total_team_points + points))

        updated_players+=("$player_name,$team,$position,$new_total_points,$new_total_rebounds,$new_total_assists,$new_ppg,$new_rpg,$new_apg,$new_MVP_rating,$new_games_played,$year,$status")
    else
        # Keep the original data for other players
        updated_players+=("$player_name,$team,$position,$total_points,$total_rebounds,$total_assists,$ppg,$rpg,$apg,$mvpRating,$games,$year,$status")
    fi
done


    # Write updated data to the CSV
    {
        echo "NAME,TEAM,POSITION,POINTS,REBOUNDS,ASSIST,PPG,RPG,APG,MVP RATING,GAMES,YEAR,STATUS"
        for player_data in "${updated_players[@]}"; do
            echo "$player_data"
        done
    } > "$csv_file.tmp"

    mv "$csv_file.tmp" "$csv_file"
    echo "$total_team_points"
}

# Function to get player input for each stat
getPlayerInput() {
    local player_name="$1"
    local stat_name="$2"
    local input_value

    while true; do
        read -r -p "$player_name $stat_name: " input_value

        if [[ -z "$input_value" ]]; then
            echo "Input cannot be empty. Please enter a valid integer for $stat_name." >&2
            continue
        fi

        if [[ "$input_value" =~ ^[0-9]+$ ]]; then
            echo "$input_value"
            return 0
        else
            echo "Invalid input. Please enter a valid integer for $stat_name." >&2
        fi
    done
}

teamPlayed7Matches() {
    local team_name=$1
    local match_count=0

    # Check if the CSV file exists
    if [ ! -f "$gamesLogFilePath" ]; then
        echo "Error: current_season_games.csv not found."
        return 1
    fi

    # Read the CSV file, skipping the header (first line)
    while IFS=, read -r homeTeam awayTeam homeTeamScore awayTeamScore winner; do
        # Check if the team is the home or away team and increase the count
        if [[ "$homeTeam" == "$team_name" || "$awayTeam" == "$team_name" ]]; then
            match_count=$((match_count + 1))
        fi

        # If the team has played 7 matches, exit early
        if [ "$match_count" -eq 7 ]; then
            return 0
        fi
    done < <(tail -n +2 "$gamesLogFilePath")  

    # If the team has not played 7 matches, return 1
    return 1
}


# Function to check if all games have been played (56 games in total)
isRegularSeasonComplete() {
    game_count=0

    # Read the CSV file line by line, skipping the header
    while IFS=, read -r homeTeam awayTeam homeTeamScore awayTeamScore winner; do
        # Skip the header (first line) and check if the line is not blank
        if [[ -n "$homeTeam" && -n "$awayTeam" && -n "$homeTeamScore" && -n "$awayTeamScore" && -n "$winner" ]]; then
            game_count=$((game_count + 1))
        fi
    done < <(tail -n +2 "$gamesLogFilePath") 

    # Check if the game count equals 56
    if [ "$game_count" -eq 56 ]; then
        return 0  # Regular season complete
    else
        return 1  # Regular season not complete
    fi
}

proceedToPlayoffs() {
    local runnerUp
    local champion
    echo "Welcome to the Post Season (Playoffs) where teams battle it out to win the championship!"
    echo "Note that all matchups are best of 1, so the winner of each matchup will advance to the next round."

    bash current_standings.sh

    # Capture the output of the pipeline into an array
    mapfile -t topTeams < <(
        grep "2022" "$teamsFilePath" | sort -t, -k2,2nr | head -n 4 | awk -F, '{print $1}'
    )

    # Assign the top four seeds, using 'None' if not enough teams are found
    firstSeed=${topTeams[0]:-None}
    secondSeed=${topTeams[1]:-None}
    thirdSeed=${topTeams[2]:-None}
    fourthSeed=${topTeams[3]:-None}

    echo "Top 4 Teams:"
    echo "1st Seed: $firstSeed"
    echo "2nd Seed: $secondSeed"
    echo "3rd Seed: $thirdSeed"
    echo "4th Seed: $fourthSeed"

    echo -e "\n--- Semifinals ---"
    
    # Match 1: First Seed vs Fourth Seed
    while true; do
        echo "Match 1: $firstSeed vs $fourthSeed"
        read -p "Who is the winner of Match 1? " winner1
        
        if [[ "$winner1" == "$firstSeed" || "$winner1" == "$fourthSeed" ]]; then
            break
        else
            echo "Invalid input. Please enter either '$firstSeed' or '$fourthSeed'."
        fi
    done

    echo

    # Match 2: Second Seed vs Third Seed
    while true; do
        echo "Match 2: $secondSeed vs $thirdSeed"
        read -p "Who is the winner of Match 2? " winner2
        
        if [[ "$winner2" == "$secondSeed" || "$winner2" == "$thirdSeed" ]]; then
            break
        else
            echo "Invalid input. Please enter either '$secondSeed' or '$thirdSeed'."
        fi
    done

    echo -e "\n--- Finals ---"
    
    # Final Match: Winner of Match 1 vs Winner of Match 2
    while true; do
        echo "Final Match: $winner1 vs $winner2"
        read -r -p "Who is the champion? " champion
        
        if [[ "$champion" == "$winner1" || "$champion" == "$winner2" ]]; then
            if [[ "$champion" == "$winner1" ]]; then
                runnerUp="$winner2"
            else 
                runnerUp="$winner1"
            fi
            break
        else
            echo "Invalid input. Please enter either '$winner1' or '$winner2'."
        fi
    done

    echo "Congratulations to $champion for winning the championship!"

    # Ask for Finals MVP
    while true; do
        read -r -p "Who is the Finals MVP? " mvp

        # Check if the MVP is a player from the champion's team
        if grep -q -i "$mvp" "$playersFilePath" && grep -q -i "$champion" "$playersFilePath"; then
            break
        else
            echo "Invalid input. Player not found in the players list."
        fi
    done

    echo "The Finals MVP is $mvp!"
    echo "2024,$champion,$runnerUp,$mvp" >> "$championsFilePath"

    
}


announceMVP() {
    # Read the CSV file and take the top 1 player
    top_players=$(tail -n +2 "$playersFilePath" | awk -F',' -v year="$1" '$12 == year' | sort -t ',' -k 10 -nr | head -n 1)
    
    # Initialize variables for player details
    player1=""
    player1_team=""
    player1_position=""
    
    # Initialize a counter
    counter=1
    
    # Loop through the top player and assign details to variables
    while IFS=',' read -r name team position points rebounds assist ppg rpg apg mvp_rating games year status; do
        case $counter in
            1)
                player1="$name"
                player1_team="$team"         # Assign team
                player1_position="$position"  # Assign position
                ;;
        esac
        ((counter++))
    done <<< "$top_players" 
    
    # Output the MVP details
    echo "Congratulations to $player1 on winning the Regular Season MVP!"
    echo "Team: $player1_team"
    echo "Position: $player1_position"
    echo "$1,$player1,$player1_team,$player1_position" >> "$mvpsFilePath"
}


isSeasonComplete() {
    local year_to_check="$currentYear"
    
    # Use awk to search for the specified year in the CSV file
    if awk -F',' -v year="$year_to_check" '$1 == year {found=1} END {exit !found}' "$championsFilePath"; then
        return 0  # Year found
    else
        return 1  # Year not found
    fi
}


resetFiles() {
    # Reset the games
    echo "homeTeam,awayTeam,homeTeamScore,awayTeamScore,winner" > "$gamesLogFilePath"
    
    # Reset the players
    next_year=$(("$currentYear" + 1))

    # Read the file, filter by the specified year and ACTIVE status, and append new records without printing the header
    awk -F',' -v year="$currentYear" -v next_year="$next_year" '
    NR > 1 && $12 == year && $13 == "ACTIVE" && NF >= 12 { 
        printf "%s,%s,%s,0,0,0,0,0,0,0,0,%d,ACTIVE\n", $1, $2, $3, next_year 
    }
    ' "$playersFilePath" > temp.csv  # Output to temp.csv without the header

    # Append the filtered records to the original file
    cat temp.csv >> "$playersFilePath"

    # Read the file, filter by the specified year, and append new records
    awk -F',' -v year="$currentYear" -v next_year="$next_year" '
    NR > 1 && $6 == year { 
        printf "%s,0,0,0.000,0,%d\n", $1, next_year 
    }
    ' "$teamsFilePath" >> "$teamsFilePath"  # Append to the same file
}


updateCurrentYear() {
	old_current_year=$(cat ../databases/current_year.txt)
	currentYear=$((old_current_year + 1))
	echo "$currentYear" > ../databases/current_year.txt
}

updateStandings() {
  local team="$1"
  local status="$2"
  local currentYear="$3"
  
  # Define the CSV file path
  local file="$teamsFilePath"
  local tempFile="../databases/temp.csv"  # Use the existing temp file name

  # Check if the team exists in the CSV for the current year
  if grep -q "^$team,[^,]*,[^,]*,[^,]*,[^,]*,$currentYear$" "$file"; then
    # Update wins or losses based on status and use temp.csv for read and write
    awk -F, -v team="$team" -v year="$currentYear" -v status="$status" '
    BEGIN { OFS = "," }
    {
      if ($1 == team && $6 == year) {
        if (status == "loser") {
          $3++;  # Increment losses
        } else {
          $2++;  # Increment wins
        }
        $5++;  # Increment games
        # Calculate the win-loss percentage
        if ($5 > 0) {
          $4 = ($2 / $5);  # Recalculate win-loss percentage
        } else {
          $4 = 0.000;  # Handle case where games is 0
        }
      }
      print  # Print the updated line
    } ' "$file" > "$tempFile"  # Write output to temp.csv
    
    # Replace the original file with updated data from temp.csv
    mv "$tempFile" "$file"
    
    echo "Updated standings for $team in $currentYear."
  else
    echo "Team $team not found for year $currentYear."
  fi
}



start #csv
