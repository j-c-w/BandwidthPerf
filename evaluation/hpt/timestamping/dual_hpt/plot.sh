#!/bin/bash

# Do a different plot for each run.
set -eu

source /root/jcw78/scripts/general/parse_config.sh

lts_location=$(get_config_value LTSLocations ../config)
tmp_location=$(get_config_value WorkDirectory ../config)
runs=$(get_config_value Runs ../config)

parallel --max-procs 10 "./single_plot.sh {} $lts_location $tmp_location" ::: $(seq 1 $runs)
