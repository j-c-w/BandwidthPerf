#!/bin/bash

set -eu
source /root/jcw78/scripts/general/parse_config.sh

if [[ $# -eq 0 ]] || [[ $# -gt 2 ]]; then
	echo "Usage: $0 <data folder>"
	echo "Or: Usage: $0 <data file 1> <data file 2>"
	exit 1
fi

min_rate=$(get_config_value MinRate)
max_rate=$(get_config_value MaxRate)
step_size=$(get_config_value StepSize)
num_packets_sent=$(get_config_value NumberToSend)

if [[ $# -eq 1 ]]; then
	# Process the data to produce the processed data folder.
	pushd $1
	echo -n "" > port0_data
	echo -n "" > port1_data
	for i in $(seq $min_rate $step_size $max_rate); do
		# Get the number of received packets for each
		# port and put it in a file.
		awk -F' ' '/SW Wrote:/ {print $3}' ${i}_two_port_cmd_out_0 >> port0_data
		awk -F' ' '/SW Wrote:/ {print $3}' ${i}_two_port_cmd_out_1 >> port1_data
	done
	popd

	python plot.py $1/port0_data $1/port1_data $min_rate $step_size $max_rate $num_packets_sent
else
	python plot.py $1 $2 $min_rate $step_size $max_rate $num_packets_sent
fi

mkdir -p $(dirname $1)/graphs
mv dropped_packets.eps $(dirname $1)/graphs/dropped_packets.eps
echo "Done! Graph in $(dirname $1)/graphs/dropped_packets.eps"
