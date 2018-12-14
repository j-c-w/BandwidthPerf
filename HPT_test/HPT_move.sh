#!/bin/bash

set -eu

if [[ ! -f .installed ]]; then
	echo "Run setup_software.sh"
	exit 1
fi

if [[ "$#" -ne 2 ]]; then
	echo "Usage $0 <source> <target>"
	exit 1
fi

source ../general/parse_config.sh
source ../general/remote_run.sh

f_source="$1"
f_target="$2"
hptmachine="$(get_config_value "HPTMachine")"

remote_run $hptmachine local_HPT_move.sh "$f_source" "$f_target"
