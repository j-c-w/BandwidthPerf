#!/bin/zsh

# Install the apps folder on this device in the appropriate location on the machines specified.
set -eu

source /root/jcw78/scripts/general/parse_config.sh
source /root/jcw78/scripts/general/remote_run.sh

if [[ $# -eq 0 ]]; then
	echo "Usage: $0 <machines to install>"
	exit 1
fi

for arg in "$@"; do
	remote_run_command $arg "rm -rf ~/benchmark"
	scp -r /root/jcw78/SUMMER2017/apps/benchmark/ $arg:~/benchmark
	default_nic=$(get_config_value $arg)
	remote_run_script "$arg" apps/replacement_sed.sh "$default_nic"
done
