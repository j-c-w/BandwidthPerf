#!/bin/bash

export DRIVER_FOLDER=/root/jcw78/NetFPGA-SUME-live/lib/sw/std/driver/sume_riffa_v1_0_0
export SUME_FOLDER=/root/jcw78/NetFPGA-SUME-live

current_dir=$PWD
pushd NetFPGA-SUME-live/tools/scripts
./run_load_image.sh $current_dir/setup_super_gadget.sh
popd
