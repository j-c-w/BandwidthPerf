#!/bin/bash

set -ue
if [[ "$#" -lt 1 ]]; then
	echo "Usage: <script> args"
	exit 1
fi

script=$1
shift

if [[ "$#" -gt 0 ]]; then
	python /root/jcw78/temp_scripts/$script "$@"
else
	python /root/jcw78/temp_scripts/$script
fi
