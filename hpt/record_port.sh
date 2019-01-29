#!/bin/bash

if [[ $# -ne 4 ]]; then
	echo "Usage: <port> <output capture file> <cpus list (see exanic documentation)> <command line output file>"
	echo "The CPUs should be a colon-separated list of three CPUs. e.g. 44:45:46"
	exit 1
fi

# The ExaNIC appears to react fine to having multiple               
# instances running.  There is a kill script, but
# we don't do that here.  This lets us start multiple
# experiments on the machine.
port=$1
out_file=$2
cpus=$3
cmd_out_file=$4

pushd /root/jcw78/scripts/hpt_setup/exanic-exact/exact-capture-1.0RC/bin
nohup ./exact-capture -i $port -o $out_file --cpus 44:45:46 --no-kernel &> $cmd_out_file &
echo "Capture started!"
echo "Capturing into file $out_file, with command output into file $cmd_out_file"
