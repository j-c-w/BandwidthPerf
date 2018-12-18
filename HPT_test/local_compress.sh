#!/bin/bash

if [[ "$#" -ne 1 ]]; then
	echo "Usage: $0 <file to compress>"
	exit 1
fi

gzip "$1"
