#!/bin/bash

if [[ $# -ne 3 ]]; then
	echo "Usage: $0 <device> <output name> <cmd output file>"
fi

dagload
dagsnap -d $1 -o $2 > $3 &
