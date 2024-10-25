#!/bin/bash

current_standing() {
    echo "============================================================="
    echo "                           CURRENT STANDINGS                           "
    echo "============================================================="

    # Print the header
    printf "%-30s %-5s %-5s %-12s %5s\n" "TEAM" "WINS" "LOSS" "WIN-LOSS %" "GAMES"
    echo "============================================================="

    # Use grep to filter for the year 2021, then sort by the wins column (2nd field) in descending order,
    # and format the output with awk.
    grep -h "$1" ../databases/teams.csv | sort -t, -k2,2nr | awk -F, '{
        printf "%-30s %-5s %-5s %-12s %-5s\n", $1, $2, $3, $4, $5
    }'

    echo "============================================================="
}

current_standing "$1"
