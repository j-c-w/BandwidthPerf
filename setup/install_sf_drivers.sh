#!/bin/bash

set -eu

if [[ $# -ne 1 ]]; then
	echo "Usage $0 <SF driver zip>"
	exit 1
fi
unzip $1 -d slf_drivers
# Go to the extract zip file.
cd slf_drivers

# Convert to DPKG
alien -c *.noarch.rpm

# And install
dpkg -i *.deb

rmmod sfc || true
modprobe sfc
