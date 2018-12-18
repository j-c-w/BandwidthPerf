#!/bin/zsh

set -eu

typeset -a zip
zparseopts -D -E -- -zip=zip

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

expr_name="$1"
file="$2"
hptmachine="$(get_config_value "HPTMachine")"
initial_location="$(get_config_value "HPTTempStorageLocation")"
target_location="$(get_config_value "HPTPermanentStorageLocation")"

# We compress the file if requested:
if [[ ${#zip} -gt 0 ]]; then
	remote_run $hptmachine local_compress.sh "$initial_location/$file"
	# File now ends in gz.
	file="$file.gz"
fi

remote_run $hptmachine local_HPT_move.sh "$initial_location/$file" "$target_location/$expr_name/$file"
