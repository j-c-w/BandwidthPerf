#!/bin/bash

set -eu

if [[ $# -ne 6 ]]; then
	echo "Usage $0 <server> <server test interface> <client> <time> <server file> <client file>"
	exit 1
fi

server=$1
server_test_interface=$2
client=$3
time=$4
server_file=$5
client_file=$6

source /root/jcw78/scripts/general/remote_run.sh

kill_iperf() {
	# Kill any existing iperfs.
	remote_run_command $server "pkill iperf -9"
	remote_run_command $client "pkill iperf -9"
}
kill_iperf

set -x

# Start the server:
remote_run_command $server "iperf -s > $server_file &" &
# Make sure the server has actually started
sleep 1
remote_run_command $client "iperf -c $server_test_interface -t $time > $client_file"

sleep $time

# Now kill those servers:
kill_iperf

# Finally, get the server file and the client file back on the managing machine.
scp $server:$server_file .
scp $client:$client_file .
