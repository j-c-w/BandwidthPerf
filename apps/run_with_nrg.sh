#!/bin/zsh

set -eu

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <benchmark>"
	exit 1
fi

echo "This is only here for reproduction purposes of some initial latency experiments.  YOU SHOULD USE run_all.sh INSTEAD."
read 'q?press enter to run this anyway'

source /root/jcw78/scripts/general/remote_run.sh
source /root/jcw78/scripts/general/parse_config.sh

nrg_mach=$(get_config_value nrg_machine)
benchmark=$1
lts_loc=$(get_config_value LTSLocation)

for latency in $(cat < times); do
	# Make sure that the NRG is programmed.
	remote_run_script $nrg_mach "bitfiles/setup_bitfile.sh" super_gadget.bit

	# Now, program the thing:
	remote_run_script $nrg_mach "nrg/set_delay.sh" $latency

	# Do the run:
	./run.sh $benchmark

	# Move the files into a folder:
	rm -rf $lts_loc/apps/$benchmark/run_with_latency_$latency
	mv $lts_loc/apps/$benchmark/run $lts_loc/apps/$benchmark/run_with_latency_$latency

	echo "Done with runs at latency $latency"
done

echo "Done!"
