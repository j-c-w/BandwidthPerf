#!/bin/bash

set -eu

if [[ ! -f .installed ]]; then
	echo "Run setup_software.sh"
	exit 1
fi

source ../general/parse_config.sh
source ../general/remote_run.sh

set -x
osnt_mach=$(get_config_value "HPTMachine")
remote_run $osnt_mach local_HPT_start_capture.sh "$@"
