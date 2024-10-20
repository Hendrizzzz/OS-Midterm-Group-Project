#!/bin/bash

current_standing() {

    echo "===================================================================="
    echo "  			  CURRENT STANDINGS     "
    echo "===================================================================="

grep -h "2023" teams.csv | awk -F, 'BEGIN { OFS=","; print "TEAM", "WINS", "LOSS", "WIN-LOSS PERCENTAGE", "GAMES BEHIND" }
     { print $1, $2, $3, $4, $5 }' | column -s, -t #change "2023" to "2024" for the 2024 standings

    echo "===================================================================="
}

current_standing
