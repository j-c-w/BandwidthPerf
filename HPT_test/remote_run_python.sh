#!/bin/bash

set -ue

if [[ "$#" -lt 1 ]]; then
	echo "Usage: $0 <script location> <args>"
	exit 1
fi

source ../general/remote_scp.sh
source ../general/remote_run.sh
source ../general/parse_config.sh

host=$(get_config_value "HPTMachine")

echo "Running on $host"
# Create the required directories:
ssh $host "if [[ ! -d /root/jcw78/temp_scripts ]]; then; mkdir -p /root/jcw78/temp_scripts; fi"

echo "Running on $(hostname)"

# Copy the python script over:
remote_scp $host $1 /root/jcw78/temp_scripts

echo "Running on $host"

# Now, remote run the script.
remote_run $host local_run_python.sh $1 $@
