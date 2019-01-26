#!/bin/bash

export DRIVER_FOLDER=/root/jcw78/NetFPGA-SUME-live/lib/sw/std/driver/sume_riffa_v1_0_0
export SUME_FOLDER=/root/jcw78/NetFPGA-SUME-live
export PATH=$PATH:/home/SDK/2016.4/bin/:/home/Vivado/2016.4/bin/

current_dir=$PWD
pushd NetFPGA-SUME-live/tools/scripts
chmod +x ./run_load_image.sh
./run_load_image.sh $current_dir/setup_super_gadget.sh
popd
