#binibinbash

declare -r currentYear="$1"
declare -r currentDirectory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
declare -r teamsFilePath="$currentDirectory/../databases/teams.csv"

echo "$teamsFilePath"

# the main method of the script
start() {
  echo "Logging a game... " 
  echo ""

  homeTeam=$(readTeam "Enter home team: ")
  awayTeam=$(readTeam "Enter away team: ")

  echo "home Team : $homeTeam"
  echo "away Team : $awayTeam"

}


# reads a team
readTeam() {
  local teamName

  # Loop until a valid team name is received
  while true; do
        read -p "$1" teamName

        if isTeamExists "$teamName"; then
          break
	else 
	  echo "Error : Team does not exist. " >&2
        fi
  done

  printf '%s\n' "$teamName" # return the team name
}


# checks if the team is existing in the current season or not
isTeamExists() {
  local teamName="$1"
  local lowerTeamName
  local normalizedName

   # converts to lowercase and remove spaces
    lowerTeamName=$(echo "$teamName" | tr '[:upper:]' '[:lower:]' | sed 's/ //g')

    # Read the file and check each line
    while IFS=, read -r name wins loses winLossPercentage gamesBehind yearLine; do
    
    # converts the current line's team name to lowercase and removes spaces
    normalizedName=$(echo "$name" | tr '[:upper:]' '[:lower:]' | sed 's/ //g')

    # check if the input teamname matches the current line team's name
    if [[ "$normalizedName" == *"$lowerTeamName"* && "$yearLine" == "$currentYear" ]]; then
      return 0
    fi
  done < "$teamsFilePath"

  return 1  
}



start 

