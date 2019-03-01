#!/bin/zsh

set -eu
zmodload zsh/mapfile

# This script runs the benchmark passed.
if [[ $# -ne 1 ]]; then
	echo "Usage $0 <benchmark>"
	exit 1
fi

source /root/jcw78/scripts/general/parse_config.sh

runs=$(get_config_value runs)
lts_directory=$(get_config_value LTSLocation)
results_directory=$(get_config_value ResultsDirectory)
benchmark=$1

typeset -a machines
machines=($(cat < machines))
echo "${#machines}"

/root/jcw78/scripts/apps/install_apps.sh $machines
pushd /root/jcw78/SUMMER2017/apps/benchmark/
./run.sh install $benchmark

for run in $(seq 1 $runs); do
	# Make sure that the benchmark doesn't already happen 
	# to be running
	./run.sh stop $benchmark || echo "Not already running"
	./run.sh start $benchmark
	# Make sure the servers have really started
	sleep 1
	./run.sh run $benchmark
	sleep 1

	echo "Run done!"

	# Get the files from each machine.  If they don't exist,
	# that's alright, the machines just might not have been
	# involved.
	mkdir -p $lts_directory/apps/$benchmark/run/run_$run
	for machine in ${machines[@]}; do
		scp -r $machine:$results_directory $lts_directory/apps/$benchmark/run/run_$run/$machine || echo "It seems that machine $machine did not produce any data."
	done

	# Stop everything
	./run.sh stop $benchmark || echo "Nothing to kill"

	sleep 3
done
popd
