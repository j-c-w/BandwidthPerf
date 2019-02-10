#!/bin/bash

pkill exanic-clock-sync
pushd /root/jcw78/scripts/hpt_setup/exanic-software/util/
# Make sure that the PPS master pulse is off
./exanic-config $1 pps-out off
popd
