#!/bin/zsh

set -eu
source /root/jcw78/scripts/general/remote_run.sh

for machine in $(cat < machines); do
	remote_run_command $machine "reboot"
done
