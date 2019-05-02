#!/bin/zsh

set -eu
zmodload zsh/mapfile

# This script runs the benchmark passed.
if [[ $# -lt 3 ]]; then
	echo "Usage $0 <benchmark (s)> (...) <number of machines> <label>"
	exit 1
fi

source /root/jcw78/scripts/general/parse_config.sh
source /root/jcw78/scripts/general/remote_run.sh

typeset -a dry_run
zparseopts -D -E -dry-run=dry_run

runs=$(get_config_value runs)
lts_directory=$(get_config_value LTSLocation)
results_directory=$(get_config_value ResultsDirectory)

typeset -a benchmarks

while [[ $# -gt 2 ]]; do
	benchmarks+="$1"
	shift
done

num_machines=$1
label=$2

echo "Running benchmarks: $benchmarks"

# Setup the config to work on the right number of machines:
./generate_config.sh $num_machines

typeset -a machines
machines=($(cat < machines))
echo "Running apps on ${#machines} machines"
typeset -a capture_machines
capture_machines=($(cat < capture_machines))
echo "Running capture cards on ${#capture_machines} machines"
config_dir=$PWD


if [[ ${#dry_run} != 0 ]]; then
	echo "Doing $runs runs on $num_machines different machines"
	echo "Machines are ${machines[@]:0:$num_machines}"
	echo "Benchmarks are $benchmarks"
	echo "Run name is $label"
	exit 0
fi

# Only install on the number of machines we are using.  Recall this
# is a ZSH script so arrays start at 0.
/root/jcw78/scripts/apps/install_apps.sh ${machines[@]:0:$num_machines}
pushd /root/jcw78/SUMMER2017/apps/benchmark/
for benchmark in "${benchmarks[@]}"; do
	./run.sh install $benchmark
done

for run in $(seq 1 $runs); do
	# Make sure that the benchmark doesn't already happen 
	# to be running
	for benchmark in "${benchmarks[@]}"; do
		./run.sh stop $benchmark || echo "$benchmark not already running"
	done
	sleep 1
	# Clear any old results from the results directories:
	echo "Clearing old results..."
	for machine in ${machines[@]}; do
		remote_run_command $machine "rm -rf $results_directory"
	done
	# Start all the capture cards:
	for machine in ${capture_machines[@]}; do
		# Kill any ongoing recording going on:
		remote_run_script $machine hpt/stop_recording.sh
		# Get the interfaces/CPUs we are using on those machines.
		use_both=$(get_config_value "${machine}_both_ports" /root/jcw78/scripts/apps/capture_config)
		# TODO -- IT WOULD BE GOOD TO AUTO-MOUNT THE CAPTURE LOCAITON.
		cpus=$(get_config_value "${machine}_cpus" /root/jcw78/scripts/apps/capture_config)
		capture_location=$(get_config_value "${machine}_capture_location" /root/jcw78/scripts/apps/capture_config)
		if [[ $use_both == *Yes* ]]; then
			interface1=$(get_config_value "${machine}_if1" /root/jcw78/scripts/apps/capture_config)
			interface2=$(get_config_value "${machine}_if2" /root/jcw78/scripts/apps/capture_config)
			remote_run_script $machine hpt/record_port.sh $interface1 $interface2 $capture_location/$benchmark/${num_machines}_machines/$machine $cpus $capture_location/$benchmark/${num_machines}_machines/${machine}_cmd_out
		else
			interface1=$(get_config_value "${machine}_if1" /root/jcw78/scripts/apps/capture_config)
			remote_run_script $machine hpt/record_port.sh $interface1 $capture_location/$benchmark/${num_machines}_machines/$machine $cpus $capture_location/$benchmark/${num_machines}_machines/${machine}_cmd_out
		fi
	done
	echo "Old results cleared... Starting  new run"
	for benchmark in "${benchmarks[@]}"; do
		./run.sh start $benchmark
	done
	# Make sure the servers have really started
	sleep 1
	for benchmark in "${benchmarks[@]}"; do
		./run.sh run $benchmark &
	done
	wait
	sleep 1

	echo "Run done!"
	# Stop everything
	for benchmark in "${benchmarks[@]}"; do
		./run.sh stop $benchmark || echo "Nothing to kill" &
	done
	wait

	sleep 3

	# Stop the capture
	for machine in ${capture_machines[@]}; do
		remote_run_script $machine hpt/stop_recording.sh
	done

	# Get the files from each machine.  If they don't exist,
	# that's alright, the machines just might not have been
	# involved.
	mkdir -p $lts_directory/apps_capture/$label/${num_machines}_machines/run/run_$run
	for machine in ${machines[@]}; do
		scp -r $machine:$results_directory $lts_directory/apps_capture/$label/${num_machines}_machines/run/run_$run/$machine || echo "It seems that machine $machine did not produce any data."
	done

	# Compress the capture files from each machine, then put them into the LTS:
	for machine in ${capture_machines[@]}; do
		remote_run_command $machine "mkdir -p $lts_directory/apps_capture/$label/${num_machines}_machines/run/run_$run"
		remote_run_command $machine "bzip2 $capture_location/$label/${num_machines}_machines/${machine}-0.expcap; mv $capture_location/$label/${num_machines}_machines/${machine}-0.expcap.bz2 $lts_directory/apps_capture/$label/${num_machines}_machines/run/run_$run/${machine}.expcap.bz2; mv $capture_location/$label/${num_machines}_machines/${machine}_cmd_out $lts_directory/apps_capture/$label/${num_machines}_machines/run/run_$run/${machine}_cmd_out" &
	done
	wait

	# Also get the log information and the host information.
	for machine in ${machines[@]}; do
		echo "Getting log files from $machine"
		scp $machine:~/hostinfo $lts_directory/apps_capture/$label/${num_machines}_machines/run/run_$run/$machine || echo "Machine $machine did not dump host information"
		scp -r $machine:~/logs $lts_directory/apps_capture/$label/${num_machines}_machines/run/run_$run/$machine
	done
done
popd
