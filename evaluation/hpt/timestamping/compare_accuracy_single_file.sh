#!/bin/bash

set -eu
if [[ $# -ne 2 ]]; then
	echo "Usage: <File to compute the statistics of> <temp location to copy to>"
	exit 1
fi
tmp_dir=$2

cp $1 $tmp_dir/$1
bunzip2 $tmp_dir/$1

result_file=${1/.bz2/}

cd /root/jcw78/process_pcap_traces/interarrival_statistics.py $tmp_dir/$result_file > $tmp_dir/${1}.statistics
rm $tmp_dir/$1 $tmp_dir/$result_file
