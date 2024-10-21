#binibinbash

declare -r currentYear="$1"
declare -r currentDirectory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r teamsFilePath="$currentDirectory/../databases/teams.csv"

echo "$teamsFilePath"

# the main method of the script
start() {
  echo "Logging a game... " 
  echo ""

  # Validate first if this team has completed 7 games
  homeTeam=$(readTeam "Enter home team: ")
  echo "Home Team : $homeTeam"
  awayTeam=$(readTeam "Enter away team: ")
  echo "Away Team : $awayTeam"

  logPlayerStats "$homeTeam"
  logPlayerStats "$awayTeam"
  

  
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


start 

