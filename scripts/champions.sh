#!/bin/bash/

past_champions (){

echo "===================================================================="
echo "  			  CHAMPIONS                               "
echo "===================================================================="

awk -F, '{ print $1, $2, $3, $4 }' /OS-Midterm-Group-Project/databases/champions.csv | column -s, -t 
echo "===================================================================="

}

past_champions
