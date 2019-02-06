#!/bin/bash

# This takes a long time.  Fortunatley, this can be done
# in parallel!

source /root/jcw78/scripts/general/parse_config.sh

lts_location=$(get_config_value LTSLocations)
min_size=$(get_config_value MinSize)
max_size=$(get_config_value MaxSize)
size_step=$(get_config_value SizeStep)
parallelism=$(get_config_value Parallelism)

# Now, get every compressed EXPCAP file in that directory.
parallel plot_single_capture.sh {}_psize.erf-0.expcap.bz2 ::: $(seq -s' ' $min_size $size_step $max_size)
