declare -r currentDirectory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" # the current directory
declare -r logGame="$currentDirectory/log_a_game.sh"
declare -r addPlayer="$currentDirectory/add_player.sh"
declare -r deletePlayer="$currentDirectory/delete_player.sh"
declare -r retirePlayer="$currentDirectory/retire_player.sh"
declare -r teamStandings="$currentDirectory/team_standings.sh"
declare -r mvpLadder="$currentDirectory/mvp_ladder.sh"
declare -r pointsLeaders="$currentDirectory/points_or_ppg_leaders.sh"
declare -r assistsLeaders="$currentDirectory/assists_or_apg_leaders.sh"
declare -r reboundsLeader="$currentDirectory/rebounds_or_rpg_leaders.sh"
declare -r displayChampions="$currentDirectory/champions.sh"
declare -r displayMvps="$currentDirectory/mvps.sh"
declare -r searchAPlayer="$currentDirectory/search_a_player.sh"
declare -r viewGames="$currentDirectory/view_games.sh"
declare -r playerStatus="$currentDirectory/active_or_retired.sh"

# currentYear=getCurrentYear in the database
currentYear=2023 # needs to have storage for the currentYear (brute force solution, read the 2nd line in the players.csv)

# Menu
show_menu() {
    clear
    echo "============================="
    echo "          DBA Menu           "
    echo "============================="
    echo "Edit"
    echo "1. Log a Game"
    echo "2. Add Player"
    echo "3. Delete Player"
    echo "4. Retire Player"
    echo
    echo "Stats"
    echo "5. Team Standings"
    echo "6. MVP Ladder"
    echo "7. Points/PPG Leaders"
    echo "8. Assists/APG Leaders"
    echo "9. Rebounds/RPG Leaders"
    echo
    echo "Accolades"
    echo "10. Champions"
    echo "11. MVPs"
    echo
    echo "12. Search a Player"
    echo "13. View Games"
    echo "14. Active/Retired Players"
    echo
    echo "15. Exit"
    echo "============================="
}

# Main loop
while true; do
    clear
    show_menu
    read -p "Please choose an option: " option

    case $option in
        1) bash "$logGame" "$currentYear" ;;
        2) bash "$addPlayer" ;;
        3) bash "$deletePlayer" ;;
        4) bash "$retirePlayer" ;;
        5) bash "$teamStandings" ;;
        6) bash "$mvpLadder" ;;
        7) bash "$pointsLeaders" ;;
        8) bash "$assistsLeaders" ;;
        9) bash "$reboundsLeaders" ;;
        10) bash "$displayChampions" ;;
        11) bash "$displayMvps" ;;
        12) bash "$searchAPlayer" ;;
        13) bash "$viewGames" ;;
        14) bash "$playerStatus" ;;
        15) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac

    read -p "Press Enter to continue..."
done
