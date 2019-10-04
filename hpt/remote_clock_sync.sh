#!/bin/zsh


source /root/jcw78/scripts/general/remote_run.sh

set -eu
if [[ $# -ne 2 ]]; then
	echo "Usage: $0 <machine> <device name>"
	exit 1
fi

machine="$1"
dev_name="$2"

remote_run_command $machine "nohup /root/jcw78/scripts/hpt/clock_sync_slave.sh $dev_name &"
