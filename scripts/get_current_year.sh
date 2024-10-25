while IFS=, read -r test; do
	echo "$test"
done < ../databases/current_year.txt
