#!/bin/zsh

set -eu

if [[ $(dirname $0) != "." ]]; then
	cd $(dirname $0)
fi

# First, setup the machines.
./setup_throuput_machines.sh

# Then, run all sub-tests:
echo "Running rate scan on a single port."
echo "Make sure port 0 of OSNT is connected to the HPT card."
cont_msg="Enter> to continue when this is done"
vared 'cont_msg'
pushd one_port_scan/
./run.sh
popd
echo "Finished running rate scan on a single port."
echo "Make sure wires are now configured so that port 0 of OSNT is connected through an optical tap to ports 0 and 1 of the HPT card"
echo "TODO"
