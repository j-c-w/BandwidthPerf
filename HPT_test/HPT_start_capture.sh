#!/bin/bash

set -eu

if [[ ! -f .installed ]]; then
	echo "Run setup_software.sh"
	exit 1
fi

if [[ "$#" -ne 2 ]]; then
	echo "Usage: $0 <port number> <file>"
	exit 1
fi

source ../general/parse_config.sh
source ../general/remote_run.sh

hpt_mach=$(get_config_value "HPTMachine")
remote_run $hpt_mach local_HPT_start_capture.sh "$@"
