#!/bin/bash

past_champions (){
#Pa ayos nalang ung directory
file_content=$(cat ../databases/champions.csv)
echo "========================================================================================="
echo "  			  CHAMPIONS                               "
echo "========================================================================================="

echo "$file_content" | awk -F, '{ printf "%-10s %-25s %-30s %-10s\n", $1, $2, $3, $4 }' 
echo "========================================================================================="

}

past_champions
