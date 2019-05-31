#!/bin/zsh

set -eu
source /root/jcw78/scripts/general/parse_config.sh

typeset -a no_extract
zparseopts -D -E -no-extract=no_extract

if [[ $# -ne 1 ]] || [[ ! -d $1 ]]; then
	echo "Usage: $0 <data folder>"
	echo "--no-extract to avoid extracting the data"
	exit 1
fi

min_rate=$(get_config_value MinRate)
max_rate=$(get_config_value MaxRate)
step_size=$(get_config_value StepSize)
num_packets_sent=$(get_config_value NumberToSend)
runs=$(get_config_value Runs ../config)
packet_size=$(get_config_value PacketSize)

# Process the data to produce the processed data folder.
pushd $1
typeset -a parsed_data
for run in $(seq 1 $runs); do
	echo "parsing data for run $run"
	pushd run_$run/two_port_scan

	if [[ ${#no_extract} == 0 ]]; then
		echo -n "" > both_ports_data
		for i in $(seq $min_rate $step_size $max_rate); do
			# Get the number of received packets for each
			# port and put it in a file.
			awk -F'[: ]+' '/SW Wrote:/ {print $4}' ${i}_both_ports_cmd_out >> both_ports_data
		done
	fi

	parsed_data+=($PWD/both_ports_data)
	popd
done
popd

set -x
python plot.py $min_rate $step_size $max_rate $num_packets_sent $packet_size ${parsed_data[@]}
