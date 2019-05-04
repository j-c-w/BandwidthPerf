#!/bin/zsh

set -eu
source /root/jcw78/scripts/general/remote_run.sh

if [[ $# -eq 0 ]]; then
	for machine in $(cat < machines); do
		remote_run_command $machine "reboot"
	done
else
	for machine in $@; do
		remote_run_command $machine "reboot"
	done
fi
