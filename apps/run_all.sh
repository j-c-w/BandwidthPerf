#!/bin/zsh

echo "This script runs and captures all of the setups defined"
echo "in the ./apps file.  See that file for comments on how"
echo "to modify it"

set -x
set -eu
typeset -a dry_run
typeset -a no_capture
zparseopts -D -E -dry-run=dry_run -no-capture=no_capture

typeset -a lines

# Parse the apps file.  
while IFS= read -r line; do
	lines+="$line"
done < apps

for line in ${lines[@]}; do
	if [[ $line == *#* ]] || [[ $line == '' ]]; then
		continue
	fi
	echo $line

	name=$(cut -f1 -d ' ' <<< $line)
	number_of_machines=$(cut -f2 -d ' ' <<< $line)
	# All remaining items are benchmarks.
	benchmarks=$(cut --complement -f1,2 -d' ' <<< $line)
	if [[ ${#dry_run} == 1 ]]; then
		echo "Name $name, number $number_of_machines, benchmarks $benchmarks"
		continue
	fi

	if [[ ${#no_capture} == 0 ]]; then
		./capture_run.sh $benchmarks $number_of_machines $name
	else
		./capture_run.sh $benchmarks $number_of_machines $name --no-capture
	fi
	echo "Run finished, moving on to next run"
done
