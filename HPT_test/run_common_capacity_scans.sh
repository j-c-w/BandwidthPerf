#!/bin/bash

set -eu

# This script runs several capacity scans with different packet sizes.
typeset -a sizes=( 64 120 128 240 256 360 480 512 600 720 840 960 1024 )
for size in ${sizes[@]}; do
	echo "Scanning size $size"
	./capacity_scan_one_port.sh $size
done
