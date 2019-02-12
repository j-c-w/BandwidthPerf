#!/bin/bash

# Install the apps folder on this device in the appropriate location on the machines specified.

if [[ $# -eq 0 ]]; then
	echo "Usage: $0 <machines to install>"
	exit 1
fi

for arg in "$@"; do
	scp -r /root/jcw78/SUMMER2017/apps/benchmark/ $arg:~/benchmark
done
