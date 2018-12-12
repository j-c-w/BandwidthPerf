#!/bin/bash

set -eu

if [[ ! -f .installed ]]; then
	echo "Run setup_software.sh"
	exit 1
fi

if [[ "$#" -ne 1 ]]; then
	echo "Usage $0 <original location of file>"
	exit 1
fi

source ../general/parse_config.sh

file="$1"
hptmachine="$(get_config_value "HPTMachine")"
initial_location="$(get_config_value "HPTTempStorageLocation")"
target_location="$(get_config_value "HPTPermanentStorageLocation")"

ssh $hptmachine 'bash -s ' < local_HPT_move.sh "$initial_location/$1" "$target_location/$1"
