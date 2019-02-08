#!/bin/bash

if [[ $# -ne 3 ]]; then
	echo "Usage: $0 <device> <output name> <cmd output file>"
fi

if [[ ! -d $(dirname $2) ]]; then
	mkdir -p $(dirname $2)
fi

if [[ ! -d $(dirname $3) ]]; then
	mkdir -p $(dirname $3)
fi

export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

dagload
dagsnap -d $1 -o $2 > $3 &
