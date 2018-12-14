#!/bin/bash

echo "On machine $(hostname)"
if [[ "$#" -ne 2 ]]; then
	echo "Usage $0 <port number> <output file>"
	exit 1
fi

port=$1
out_file=$2

# The ExaNIC appears to react fine to having multiple
# instances running.  There is a kill script, but
# we don't do that here.  This lets us start multiple
# experiments on the machine.
pushd ~/jcw78/exanic-software/util
echo "Recording on port $port into file $out_file"
nohup ./exanic-capture -i exanic0:$port -w "$out_file" &> err_port$port -F erf &
echo "Capture started!"
