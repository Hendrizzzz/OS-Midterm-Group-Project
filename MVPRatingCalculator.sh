#!/bin/bash/
#mvp rating calculator

mvp_rating_calculator(){
recordedPoint=$(echo "$1 * 0.5" | bc)
recordedRebounds=$(echo "$2 * 0.3" | bc)
recordedAssist=$(echo "$3 * 0.2" | bc)
games=$4 

rating=$(echo "(recorderPoint + recordedRebound + recourdedAssist) / games" | bc )
echo "$rating"
}

result=$(mvp_rating_calculator "$1" "$2" "$3" "$4")
echo "$result"


