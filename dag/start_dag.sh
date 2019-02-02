#!/bin/bash

if [[ $# -ne 2 ]]; then
	echo "Usage: $0 <device> <output name>"
fi

dagload
dagsnap -d $1 -o $2
