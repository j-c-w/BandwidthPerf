#!/bin/bash

set -ue

source ../general/parse_config.sh 
VIVADO_LOC=$(get_config_value "VivadoLocation")
XMD_LOC=$(get_config_value "XMDLocation")

if [[ ! -f /root/.vimrc ]]; then
	echo "imap jk <Esc>
	imap JK <Esc>
	nmap <Space>w :w<CR>" > /root/.vimrc
else
	echo "VIMRC already exists, not overwriting"
fi

mkdir -p /root/jcw78
cd /root/jcw78

# Get the scripts directory:
if [[ ! -d scripts ]]; then
	git clone https://github.com/j-c-w/BandwidthPerf scripts
fi

if [[ ! -d NetFPGA-SUME-live ]]; then
	# Get SUME (and build the module)
	git clone https://github.com/NetFPGA/NetFPGA-SUME-live.git
fi

pushd NetFPGA-SUME-live/lib/sw/std/driver/sume_riffa_v1_0_0
make
popd

# Get OSNT and the NRG-dev folder.
if [[ ! -d NRG-dev ]]; then
	git clone https://github.com/j-c-w/NRG-dev
fi

if [[ ! -d OSNT-SUME-live ]]; then
	git clone https://github.com/NetFPGA/OSNT-SUME-live.git
fi

# Finally, get the SUMMER2017 repo:
if [[ ! -d SUMMER2017 ]]; then
	git clone https://github.com/j-c-w/SUMMER2017
fi

# Copy the local bitfiles to the top level.
cp /root/jcw78/scripts/bitfiles/* /root/jcw78

# Generate the pcap files:
pushd /root/jcw78/scripts/pcap_files/
echo "Generating PCAP files..."
for i in $(seq 1 1518); do
	if [[ ! -f $i.cap ]]; then
		python ../general/generate_pcap.py $i &> /dev/null
		mv variable_length.pcap $i.cap
	fi
done
popd
echo "Done generating PCAP files."

# Make sure vivado is installed:
if [[ ! -d $VIVADO_LOC ]]; then
	echo "Vivado should be installed in $VIVADO_LOC"
	echo "Edit the config file in $PWD/config"
	echo "Install failed: set Vivado location and run again"
	exit 1
fi
if [[ ! -d $XMD_LOC ]]; then
	echo "XMD should be installed in $XMD_LOC"
	echo "Edit the config file in $PWD/config"
	echo "Install failed: set XMD location and run again"
	exit 1
fi
echo "Install finished!"
