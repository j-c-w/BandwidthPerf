#!/bin/bash

# Note that this script ends /all/ captures.

set -eu

if [[ ! -f .installed ]]; then
	echo "Run setup_software.sh"
	exit 1
fi

if [[ "$#" -ne 0 ]]; then
	echo "Script takes no arguments and kills all remote captures."
	exit 1
fi

source ../general/parse_config.sh

osnt_mach=$(get_config_value "HPTMachine")
ssh $osnt_mach 'bash -s ' < local_HPT_end_capture.sh
