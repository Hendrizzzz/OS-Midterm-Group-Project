calculate_mvp_rating() {
  local points="$1"
  local rebounds="$2"
  local assists="$3"
  local games="$4"

  # Calculate recorded points, rebounds, and assists using awk
  recorded_points=$(awk "BEGIN {print $points * 0.5}")
  recorded_rebounds=$(awk "BEGIN {print $rebounds * 0.3}")
  recorded_assists=$(awk "BEGIN {print $assists * 0.2}")

  # Calculate total points
  total_points=$(awk "BEGIN {print $recorded_points + $recorded_rebounds + $recorded_assists}")

  # Calculate MVP rating
  mvp_rating=$(awk "BEGIN {print $total_points / $games}")

  echo "$mvp_rating"
}

result=$(calculate_mvp_rating "$1" "$2" "$3" "$4")
echo "$result"
