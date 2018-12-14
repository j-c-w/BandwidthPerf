#!/bin/bash

set -eu

if [[ ! -f .installed ]]; then
	echo "Run setup_software.sh"
	exit 1
fi

if [[ "$#" -ne 2 ]]; then
	echo "Usage $0 <expr name> <filename>"
	exit 1
fi

source ../general/parse_config.sh
source ../general/remote_run.sh

file="$1"
hptmachine="$(get_config_value "HPTMachine")"
initial_location="$(get_config_value "HPTTempStorageLocation")"
target_location="$(get_config_value "HPTPermanentStorageLocation")"

remote_run $hptmachine local_HPT_move.sh "$initial_location/$1" "$target_location/$expr_name/$1"
