#!/bin/bash

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <hpt device>"
	exit 1
fi

pkill exanic-clock-sy

pushd /root/jcw78/scripts/hpt_setup/exanic-software/util/
./exanic-config $1 pps-out on
popd
