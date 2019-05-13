#!/bin/zsh

set -eu

source /root/jcw78/scripts/general/parse_config.sh
source /root/jcw78/scripts/general/remote_run.sh

if [[ $(dirname $0) != "." ]]; then
	cd $(dirname $0)
fi

runs=$(get_config_value Runs)
HPTMachine=$(get_config_value MachineB)
LTSLocation=$(get_config_value LTSLocations)

# First, setup the machines.
./setup_throuput_machines.sh

# Then, run all sub-tests:
echo "Running rate scan on a single port."
echo "Make sure port 0 of OSNT is connected to the HPT card."
cont_msg="Enter> to continue when this is done"
vared 'cont_msg'
pushd one_port_scan/
# ./run.sh
popd
echo "Finished running rate scan on a single port."
echo "Make sure wires are now configured so that port 0 of OSNT is connected through an optical tap to ports 0 and 1 of the HPT card"
cont_msg="Enter> to continue when this is done"
vared 'cont_msg'
pushd two_port_scan/
# These build up data accross runs.
remote_run_command $HPTMachine "echo -n '' > /root/jcw78/nvme/port_data_builder"
for i in $(seq 1 $runs); do 
	./run.sh

	remote_run_command $HPTMachine "mkdir -p $LTSLocation/two_port_scan/run_${i}"
	remote_run_command $HPTMachine "mv /root/jcw78/nvme/two_port_scan/ $LTSLocation/two_port_scan/run_$i"
done

popd
echo "All done!"
