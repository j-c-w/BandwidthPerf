#!/bin/zsh

set -ue
if [[ $# -ne 0 ]]; then
	echo "Usage: $0"
	exit 1
fi

# This is a script that sets up the machines defined in the config
# file so that they are ready to do the test.

source ../../../general/parse_config.sh
source ../../../general/remote_run.sh

echo "Libraries loaded.  Extracting config values"

machA=$(get_config_value "MachineA")
machB=$(get_config_value "MachineB")

interface0=$(get_config_value "HPTInterface0")
interface1=$(get_config_value "HPTInterface1")

nvme_dev_name=$(get_config_value "NVMeDeviceName")
echo "Config values extracted for setup.  Starting running on"
echo $machA
echo $machB

# Run the generic setup on both machines.
remote_run $machA ../../../setup/pre_setup_machine.sh
remote_run $machB ../../../setup/pre_setup_machine.sh

# Run the exanic setup on machine B.
remote_run_script $machB setup/setup_exanic_machine.sh

# Make sure the ports are enabled.
remote_run_script $machB general/enable_exanic_port.sh $interface0
remote_run_script $machB general/enable_exanic_port.sh $interface1

# Now, flash OSNT to the NetFPGA in machine A.
remote_run_script $machA bitfiles/setup_bitfile.sh osnt_20170129.bit

# Disable frequency scaling on the capture machine.
remote_run_script $machB setup/disable_freq_scaling.sh

# Make sure the long term storage and the temporary NVMe are there on the capturing device.
if [[ $nvme_dev_name == *None* ]]; then
	echo "Mounting a ramdisk!"
	remote_run_script $machB setup/setup_ramdisk.sh /root/jcw78/nvme 200g
else
	echo "Mounting an NVMe!"
	remote_run_script $machB setup/setup_nvme.sh $nvme_dev_name
fi
