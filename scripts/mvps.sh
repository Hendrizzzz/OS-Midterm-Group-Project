#!/bin/bash

past_mvp (){

file_content=$(cat /home/ubuntu/OS-Midterm-Group-Project/databases/mvps.csv)
echo "===================================================================="
echo "                          MOST VALUABLE PLAYER                      "
echo "===================================================================="

echo "$file_content" | awk -F, '{ printf "%-10s %-25s %-30s %-30s\n", $1, $2, $3, $4 }'
echo "===================================================================="

}

past_mvp

