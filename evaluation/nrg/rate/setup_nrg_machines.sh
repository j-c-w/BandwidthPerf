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
machC=$(get_config_value "MachineC")
machD=$(get_config_value "MachineD")

NICA=$(get_config_value "NICA")
NICD=$(get_config_value "NICD")

nvme_dev_name=$(get_config_value "NVMeDeviceName")
echo "Config values extracted for setup.  Starting running on"
echo $machA
echo $machB
echo $machC
echo $machD

# Run the generic setup on both machines.
remote_run $machA ../../../setup/pre_setup_machine.sh
remote_run $machB ../../../setup/pre_setup_machine.sh
remote_run $machC ../../../setup/pre_setup_machine.sh
remote_run $machD ../../../setup/pre_setup_machine.sh

# Run the exanic setup on machine C.
remote_run_script $machC setup/setup_exanic_machine.sh

# Now, flash OSNT to the NetFPGA in machine B.
remote_run_script $machB bitfiles/setup_bitfile.sh super_gadget.bit

# Make sure the interfaces are up on A and D.
remote_run_command $machA "ifconfig $NICA up 192.168.0.2"
remote_run_command $machD "ifconfig $NICD up 192.168.0.3"

# Make sure the long term storage and the temporary NVMe are there on the capturing device.
remote_run_script $machC setup/setup_nvme.sh $nvme_dev_name
