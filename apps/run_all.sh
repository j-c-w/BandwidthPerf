#!/bin/zsh

echo "This script runs and captures all of the setups defined"
echo "in the ./apps file.  See that file for comments on how"
echo "to modify it"

# Parse the apps file.  
while IFS= read -r line; do
	if [[ $line == *#* ]] || [[ $line == '' ]]; then
		continue
	fi
	echo $line

	name=$(cut -f1 -d ' ' <<< $line)
	number_of_machines=$(cut -f2 -d ' ' <<< $line)
	# All remaining items are benchmarks.
	benchmarks=$(cut --complement -f1,2 -d' ' <<< $line)

	./capture_run.sh $benchmarks $number_of_machines $name --dry-run
done < apps
