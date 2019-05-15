#!/bin/zsh

source /root/jcw78/scripts/general/parse_config.sh

runs=$(get_config_value Runs)
folders=($(get_config_value Folders))
names=($(get_config_value Names))

for name in $names; do
	echo -n "" > ${name}_out
done

for run in $(seq 1 $runs); do
	for index in $(seq ${#folders[@]}); do
		folder=${folders[$index]}
		name=${names[$index]}

		echo "Starting run $run for disk $name"
		echo "Running in folder $folder"

		rm -f $folder/disk_test
		dd if=/dev/zero of=$folder/disk_test bs=8M count=4096 &> output

		awk -F' ' '/bytes/ {print $1,$8}' output >> ${name}_out
	done
done
