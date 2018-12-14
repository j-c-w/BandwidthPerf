#!/bin/bash

# This is a script that passes all the arguments it receives onto
# the remote OSNT machine.

set -eu

if [[ ! -f .installed ]]; then
	echo "Run setup_software.sh"
	exit 1
fi

source ../general/parse_config.sh
source ../general/remote_run.sh

osnt_mach=$(get_config_value "OSNTMachine")
remote_run $osnt_mach local_OSNT_cmd.sh "$@"
