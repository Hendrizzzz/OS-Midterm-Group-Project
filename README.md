# DBA (Database Basketball Association) Management System

This is a Bash scripting project that manages a fictional basketball league called the DBA (Database Basketball Association). It includes player statistics, team standings, MVP records, championship history, and more. The project uses various shell scripts to handle operations such as logging games, adding/removing players, and displaying statistics.

---

## Table of Contents
- [File Structure](#file-structure)
- [Menu Options](#menu-options)
- [Database Files](#database-files)
- [Script Files](#script-files)

---

## File Structure

### Database Files
- **`current_year.txt`**: Stores the current year for the app.
- **`players.csv`**: Contains data for 311 players across 8 teams, including their stats from 2020 to 2024 (current season).
- **`champions.csv`**: Stores championship records, including the winning team, runner-up, and Finals MVP.
- **`teams.csv`**: Keeps track of the win-loss records for all teams from 2020 to 2024.
- **`mvps.csv`**: Records past MVPs, used for storing MVP data after each season.

### Script Files
The following Bash scripts are located in the scripts package:
- **`active_or_retired.sh`**: Lists active and retired players.
- **`add_player.sh`**: Adds a new player to the database.
- **`assists_or_apg_leaders.sh`**: Displays leaders in assists or assists per game.
- **`champions.sh`**: Shows a list of past champions.
- **`current_standings.sh`**: Displays current team standings.
- **`delete_player.sh`**: Deletes a player from the database.
- **`get_current_year.sh`**: Retrieves the current year from `current_year.txt`.
- **`log_a_game.sh`**: Logs a game to update team and player stats.
- **`main.sh`**: Main script that runs the DBA menu.
- **`mvp_ladder.sh`**: Displays the current MVP ladder.
- **`mvp_rating_calculator.sh`**: Calculates MVP ratings for players.
- **`mvps.sh`**: Shows a list of past MVPs.
- **`points_or_ppg_leaders.sh`**: Displays leaders in points or points per game.
- **`rebounds_or_rpg_leaders.sh`**: Displays leaders in rebounds or rebounds per game.
- **`retire_player.sh`**: Retires a player.
- **`search_player.sh`**: Searches for a player in the database.
- **`view_games_this_season.sh`**: Views all games logged in the current season.

---

## Menu Options

The main menu provides various options to interact with the DBA system:

1. **Log a Game**: Log details of a game to update team and player statistics.
2. **Add Player**: Add a new player to the database.
3. **Delete Player**: Remove a player from the database.
4. **Retire Player**: Mark a player as retired.
5. **Team Standings**: View the current win-loss standings of all teams.
6. **MVP Ladder**: Display the current MVP standings.
7. **Points/PPG Leaders**: Show leaders in points or points per game.
8. **Assists/APG Leaders**: Show leaders in assists or assists per game.
9. **Rebounds/RPG Leaders**: Show leaders in rebounds or rebounds per game.
10. **Champions**: Display past championship records.
11. **MVPs**: Display a list of past MVPs.
12. **Search a Player**: Search for a player and view their stats.
13. **View Games**: View all games recorded in the current season.
14. **Active/Retired Players**: List players who are either active or retired.
15. **Exit**: Exit the DBA system.

---
