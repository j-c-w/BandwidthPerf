#!/bin/bash

set -eu
if [[ $# -ne 1  ]]; then
	echo "Usage: $0 <delay>"
	exit 1
fi

cd /root/jcw78/NRG-dev/sw/api/
python ../gui/set_delay.py $1
