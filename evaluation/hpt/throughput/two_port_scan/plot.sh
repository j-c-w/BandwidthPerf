#!/bin/bash

source /root/jcw78/scripts/general/parse_config.sh

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <data folder>"
fi

min_rate=$(get_config_value MinRate)
max_rate=$(get_config_value MaxRate)
step_size=$(get_config_value StepSize)

# Process the data to produce the processed data file.
pushd $(dirname $1)
echo -n "" > port1_data
echo -n "" > port2_data
for i in $(seq $min_rate $step_size $max_rate); do
	# Get the number of received packets for each
	# port and put it in a file.
	awk -F' ' '/SW Wrote:/ {print $3}' ${i}_two_port_cmd_out_0 >> port0_data
	awk -F' ' '/SW Wrote:/ {print $3}' ${i}_two_port_cmd_out_1 >> port1_data
done

python plot.py $(dirname $1) $min_rate $max_rate $step_size
