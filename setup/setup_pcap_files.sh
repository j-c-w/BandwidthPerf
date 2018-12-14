#!/bin/bash

set -ue
# Copy all the local pcap files to the remote machine.
if [[ "$#" -ne 2 ]]; then
	echo "Usage: $0 <target machine> <max pcap size>"
fi

# Generate all sizes of PCAP file up to max size:
pushd ../pcap_files/
for i in {1..${2}}; do
	if [[ ! -f $i.cap ]]; then
		python ../general/generate_pcap.py $i
		mv variable_length.pcap $i.cap
	fi
done
popd

# Now, copy them all.
source ../general/remote_scp.sh

files=( ../pcap_files/*.cap )
host=$1

ssh $host 'mkdir -p /root/jcw78/pcap_files'
for file in $files; do
	set -x
	remote_scp $host $file /root/jcw78/pcap_files
done
