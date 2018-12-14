#!/bin/zsh

# This script runs a capture from port 0 of OSNT into to port 0
# of the HPT.  It runs for a few seconds.

set -eu
zmodload zsh/mathfunc

if [[ "$#" -ne 1 ]]; then
	echo "Usage: $0 <rate (in mbps)>"
	exit 1
fi

typeset -i rate=$1
typeset -i size=$2

if [[ $rate -gt 10000 ]]; then
	echo "Rate cannot be greater than 10000."
	exit 1
fi

source ../general/parse_config.sh

storage_location=$(get_config_value "HPTTempStorageLocation")

target_time=10
# We are using a 10gig link and 64 byte packets.  So, the wire
# time is 64 * 8 / 10000* 10**6 \approx 52ns.
ipg=$((int(rint($(echo "scale=30; (64 * 8 / $rate) * 1000" | bc)))))
echo "c"
num_packets=$((int(rint($(echo "scale=30; $target_time * 1000000000 / ($ipg + 53)" | bc)))))
capfile=hpt_at_${rate}_mbps

echo "IPG: $ipg"
echo "Packets $num_packets"

./HPT_end_capture.sh
echo "Killed all other running HPT capture instances."
./HPT_start_capture.sh "${size}B" $storage_location/$capfile
echo "Capture started"
./OSNT_cmd.sh -ifp0 /root/jcw78/pcap_files/$size.cap
echo "Loaded PCAP files"
sleep 1
./OSNT_cmd.sh -rpn0 $num_packets -ipg0 $ipg -run
echo "Generation started!"
sleep 12
./HPT_end_capture.sh

# Now, move the HPT files over to the long term storage.
./HPT_move_capture.sh $capfile
