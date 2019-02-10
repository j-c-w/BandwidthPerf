#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <device name>"
	exit 1
fi

pkill exanic-clock-sync

pushd /root/jcw78/scripts/hpt_setup/exanic-software/util/
# Make sure that the PPS master pulse is off
./exanic-config $1 pps-out off

# Then start the slave.
./exanic-clock-sync $1:pps &

# Wait a while, then restart the slave.  It seems to give better
# results.
sleep 10
pkill exanic-clock-sync
sleep 1

./exanic-clock-sync $1:pps &
popd
