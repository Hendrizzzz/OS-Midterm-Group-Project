#!/bin/bash

past_champions (){

file_content=$(cat /home/ubuntu/OS-Midterm-Group-Project/databases/champions.csv)
echo "===================================================================="
echo "  			  CHAMPIONS                               "
echo "===================================================================="

echo "$file_content" | awk -F, '{ printf "%-10s %-25s %-30s %-10s\n", $1, $2, $3, $4 }' 
echo "===================================================================="

}

past_champions
