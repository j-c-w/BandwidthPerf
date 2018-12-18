#!/bin/bash

if [[ "$#" -ne 1 ]]; then
	echo "Usage: $0 <packet size>"
fi

source ../general/parse_config.sh
lts_loc=$(get_config_value 'HPTPermanentStorageLocation')

files=( $lts_loc/${1}B/*_output )
for size in {100..10000..100}; do
	file="$lts_loc/${1}B/${size}_output"
	# Get the number of drops:

done
