#!/bin/bash

set -eu
set -x

# This script takes a single argument.  That is the
# (compressed) expcap file to consider.

source /root/jcw78/scripts/general/parse_config.sh

decomp_loc=$(get_config_value DecompressLocation)

if [[ $# -ne 1 ]] || [[ $1 != *.expcap.bz2 ]]; then
	echo "Usage $0 <.expcap.bz2 file>"
	exit 1
fi

if [[ ! -d $decomp_loc ]]; then
	echo "Not a location we  can decompress from $decomp_loc"
	echo "Try editing the config."
	exit 1
fi

if [[ ! -f $1 ]]; then
	echo "Input file $1 is not a file"
	exit 1
fi

# Copy the file over to the decompress location.
cp "$1" $decomp_loc

new_filename="$decomp_loc/$(basename $1)"
extracted_expcap_filename="${new_filename/.bz2/}"
csv_filename="${new_filename/.expcap.bz2/.csv}"
# Convert this into a PCAP file for proceesing with our scripts.
/root/jcw78/scripts/general/expcap_to_csv.sh "$new_filename" "$csv_filename"

# Now, draw the distribution graph.  Leave the graph here.
full_csv_filename=$(readlink -f $csv_filename)
pushd /root/jcw78/process_pcap_traces/
python inter_arrival_distribution_graph.py "$full_csv_filename"
popd

# Remove things to clear space
rm -f $full_csv_filename $new_filename $extracted_expcap_filename

echo "Done drawing graph for $1!"
