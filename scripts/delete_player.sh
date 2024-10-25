#!/bin/bash

delete_player () {
    file="/OS-Midterm-Group-Project/databases/players.csv"
    
    # Check if the file exists
    if [[ ! -f "$file" ]]; then
        echo "File not found: $file"
        return 1
    fi

    grep "2024" "$file" | awk -F, -v player="$1" '$1 != player' > temp
    if [[ $? -eq 0 ]]; then  
        mv temp "$file"
        echo "Player '$1' deleted successfully."
    else
        echo "Error filtering players."
        rm temp 
    fi
}

echo "Enter the name of the player you wish to delete:"
read a

delete_player "$a"

