#!/bin/bash

set -eu

if [[ "$#" -ne 1 ]]; then
	echo "Usage: $0 <packet size>"
	exit 1
fi

typeset -i size=$1

source ../general/parse_config.sh
lts_dir=$(get_config_value "HPTPermanentStorageLocation")

for rate in {100..10000..100}; do
	./run_one_port_capture.sh $rate $size

	# We also want to copy the final output, which indicates
	# the number of packets the HPT thinks it dropped.
	./HPT_move.sh '/root/jcw78/exanic-software/util/err_port0' "$lts_dir/${size}B/${rate}_output"
done
