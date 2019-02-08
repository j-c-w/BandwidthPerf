#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <device name>"
	exit 1
fi

pkill exanic-clock-sync

pushd /root/jcw78/scripts/hpt_setup/exanic-software/util/
./exanic-clock-sync $1:pps &
popd
