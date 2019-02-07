#!/bin/bash

set -eu
if [[ $# -ne 1  ]]; then
	echo "Usage: $0 <rate>"
	exit 1
fi

cd /root/jcw78/NRG-dev/sw/gui/
python set_bandwidth.py $1