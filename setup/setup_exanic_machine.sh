#!/bin/bash

set -ue
mkdir -p /root/jcw78/scripts/hpt_setup/

pushd /root/jcw78/scripts/hpt_setup/
if [[ ! -d exanic-software ]]; then
	git clone https://github.com/exablaze-oss/exanic-software
fi

# Regardless, check out the 'right' version and build it all.
pushd exanic-software
git checkout c2aff3c0d120d4cf278b32c1c0b37b45904cb788
make
make install
popd

# Once we have this, we can load the right kernel module:
if [[ $(lsmod | grep -ce 'exasock') -ge 1 ]]; then
	rmmod exasock
fi
if [[ $(lsmod | grep -ce 'exanic') -ge 1 ]]; then
	rmmod exanic
fi

modprobe exasock 
modprobe exanic
exanic-config exanic0

# Check that the firmware is the right date:
pushd /root/jcw78/scripts/hpt_setup/exanic-software/util/
fm_date=$(./exanic-config | grep -ce 'Firmware date: 20180221 ')
popd
if [[ $fm_date == 0 ]]; then
	# Now, get the firmware and install it.
	if [[ ! -f exanic_hpt_20180221.fw.gz ]]; then
		wget https://exablaze.com/downloads/exanic/exanic_hpt_20180221.fw.gz
	fi

	if [[ ! -f exanic_hpt_20180221.fw ]]; then
		gzip -d exanic_hpt_20180221.fw.gz
	fi

	# Now, install that firmware.
	firmware_loc="$PWD/exanic_hpt_20180221.fw"
	pushd /root/jcw78/scripts/hpt_setup/exanic-software/util
	./exanic-fwupdate -d exanic0 -r $firmware_loc
	# Note that the system needs a reboot now, so
	# exit with an error, inform the user and then wait.
	echo "$(hostname) NOW NEEDS TO BE REBOOTED.  Re-run this script after reboot."
	# Exit with an error to make sure all scripts stop.
	exit 1
fi

# Install any python software needed.
python -m pip install -U matplotlib
