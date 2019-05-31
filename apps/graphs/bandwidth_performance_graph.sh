#!/bin/zsh

if [[ $# -lt 1 ]]; then
	echo "Usage: $0 <benchmark folders>"
	echo "The sub-folders should be in the format:"
	echo "<app name>_<rate>_mbps"
fi

python bandwidth_performance_graph.py $@
