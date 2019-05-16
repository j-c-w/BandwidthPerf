#!/bin/bash

# This script plots the rate observed by iperf against the rate requested.

set -eu
source /root/jcw78/scripts/general/parse_config.sh

lts_loc=$(get_config_value LTSLocation ../config)
min_rate=$(get_config_value MinRate)
max_rate=$(get_config_value MaxRate)
step_size=$(get_config_value StepSize)
runs=$(get_config_value Runs)

# We intentionally ignore the step size here.
# Checking whether a file exists is relatively cheap.
# By going up in steps of 1 we can have different measurement
# granularities in different places.
results_file=results
echo -n "" > $results_file
for i in $(seq $min_rate $step_size $max_rate); do
	for run in $(seq 1 $runs); do
		file=$lts_loc/nrg_rate/run_${run}/${i}_iperf_client_${run}_out
		if [[ -f $file ]]; then
			rate=$(awk -F'[ -]*' '/bits/ { print $8" "$9}' $file)
			if [[ $rate != '' ]]; then
				echo "$i,$rate" >> $results_file
			fi
		fi
	done
done

# Now, call the python plotter from this:
python ./plot_bandwidth_graph.py $results_file
