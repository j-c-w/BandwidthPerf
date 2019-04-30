#!/bin/zsh

set -eu
zmodload zsh/mapfile

# This script runs the benchmark passed.
if [[ $# -ne 1 ]]; then
	echo "Usage $0 <benchmark>"
	exit 1
fi

source /root/jcw78/scripts/general/parse_config.sh
source /root/jcw78/scripts/general/remote_run.sh

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
	sleep 1
	# Clear any old results from the results directories:
	echo "Clearing old results..."
	for machine in ${machines[@]}; do
		remote_run_command $machine "rm -rf $results_directory"
	done
	echo "Old results cleared... Starting  new run"
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

	# Also get the log information and the host information.
	for machine in ${machines[@]}; do
		scp $machine:~/hostinfo $lts_directory/apps_capture/$benchmark/${num_machines}_machines/run/run_$run/$machine || echo "Machine $machine did not dump host information"
		scp -r $machine:~/logs $lts_directory/apps_capture/$benchmark/${num_machines}_machines/run/run_$run/$machine || echo "Machien did not dump log information"
	done
done
popd
