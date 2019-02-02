#!/bin/bash

if [[ $# -ne 4 ]]; then
	echo "Usage: <port> <output capture file> <cpus list (see exanic documentation)> <command line output file>"
	echo "The CPUs should be a colon-separated list of three CPUs. e.g. 44:45:46"
	exit 1
fi

# Stop any other recording that is going on.
pkill exact-capture

port=$1
out_file=$2
cpus=$3
cmd_out_file=$4

# Make sure that the appropriate folders exist:
mkdir -p $(dirname $out_file)
mkdir -p $(dirname $cmd_out_file)

pushd /root/jcw78/scripts/hpt_setup/exanic-exact/exact-capture-1.0RC/bin
nohup ./exact-capture -i $port -o $out_file --cpus $cpus --no-kernel &> $cmd_out_file &
echo "Capture started!"
echo "Capturing into file $out_file, with command output into file $cmd_out_file"
