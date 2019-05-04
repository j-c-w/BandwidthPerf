#!/bin/zsh

set -eu
zmodload zsh/mapfile

# This script runs the benchmark passed.
if [[ $# -lt 3 ]]; then
	echo "Usage $0 <benchmark (s)> (...) <number of machines> <label>"
	echo "--dry-run to not actually run"
	echo "--no-capture to disable capture"
	echo "--no-reboot to not reboot the benchmarking machines before running"
	exit 1
fi

source /root/jcw78/scripts/general/parse_config.sh
source /root/jcw78/scripts/general/remote_run.sh

typeset -a dry_run
typeset -a no_capture
typeset -a no_reboot
zparseopts -D -E -dry-run=dry_run -no-capture=no_capture -no-reboot=no_reboot

runs=$(get_config_value runs)
lts_directory=$(get_config_value LTSLocation)
results_directory=$(get_config_value ResultsDirectory)
timeout_limit=$(get_config_value TimeoutLimit)
reboot_time=$(get_config_value RebootTime)

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
echo "Running apps on ${#machines} total machines"
echo "Requested use of $num_machines of them"
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
	# Reboot the machines we are using and give them time
	# to turn on.  (Unless this was disabled)
	if [[ ${#no_reboot} == 0 ]]; then
		echo "Starting machine reboot..."
		/root/jcw78/scripts/apps/reboot_machines.sh ${machines[@]:0:$num_machines}
		sleep $reboot_time
		echo "Reboot done!"
	fi

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
	if [[ ${#no_capture} == 0 ]]; then
		# Start all the capture cards:
		for machine in ${capture_machines[@]}; do
			# Kill any ongoing recording going on:
			remote_run_script $machine hpt/stop_recording.sh
			# TODO -- IT WOULD BE GOOD TO AUTO-MOUNT THE CAPTURE LOCAITON.
			capture_location=$(get_config_value "${machine}_capture_location" /root/jcw78/scripts/apps/capture_config)
			# Clear the capture location. (But don't delete the location itself).
			remote_run_command $machine "rm -rf $capture_location/*"
			# Get the interfaces/CPUs we are using on those machines.
			use_both=$(get_config_value "${machine}_both_ports" /root/jcw78/scripts/apps/capture_config)
			cpus=$(get_config_value "${machine}_cpus" /root/jcw78/scripts/apps/capture_config)
			if [[ $use_both == *Yes* ]]; then
				interface1=$(get_config_value "${machine}_if1" /root/jcw78/scripts/apps/capture_config)
				interface2=$(get_config_value "${machine}_if2" /root/jcw78/scripts/apps/capture_config)
				remote_run_script $machine hpt/record_port.sh $interface1 $interface2 $capture_location/$benchmark/${num_machines}_machines/$machine $cpus $capture_location/$benchmark/${num_machines}_machines/${machine}_cmd_out
			else
				interface1=$(get_config_value "${machine}_if1" /root/jcw78/scripts/apps/capture_config)
				remote_run_script $machine hpt/record_port.sh $interface1 $capture_location/$benchmark/${num_machines}_machines/$machine $cpus $capture_location/$benchmark/${num_machines}_machines/${machine}_cmd_out
			fi
		done
	fi
	echo "Old results cleared... Starting  new run"

	# Remove any failed markers from before.
	rm -f .failed
	for benchmark in "${benchmarks[@]}"; do
		timeout -s KILL $timeout_limit ./run.sh start $benchmark || touch .failed
	done
	# Make sure the servers have really started
	sleep 1
	if [[ ! -f .failed ]]; then
		# If the setup failed, we shouldn't run the main apps.
		for benchmark in "${benchmarks[@]}"; do
			(timeout -s KILL $timeout_limit ./run.sh run $benchmark ||
			touch .failed) &
		done
	fi
	wait
	sleep 1

	echo "Run done!"
	# Stop everything
	for benchmark in "${benchmarks[@]}"; do
		./run.sh stop $benchmark || echo "Nothing to kill" &
	done

	sleep 3

	if [[ ${#no_capture} -eq 0 ]]; then
		# Stop the capture
		for machine in ${capture_machines[@]}; do
			remote_run_script $machine hpt/stop_recording.sh
		done
	fi

	# Get the files from each machine.  If they don't exist,
	# that's alright, the machines just might not have been
	# involved.
	# First clear any old results from the folder we are about
	# to populate.
	if [[ -d $lts_directory/apps_capture/$label/${num_machines}_machines/run/run_$run ]]; then
		rm -rf $lts_directory/apps_capture/$label/${num_machines}_machines/run/run_$run
	fi
	mkdir -p $lts_directory/apps_capture/$label/${num_machines}_machines/run/run_$run
	for machine in ${machines[@]:0:$num_machines}; do
		# We need to make sure that the directory is created
		# regardless of whether we copy anything back.
		mkdir -p $lts_directory/apps_capture/$label/${num_machines}_machines/run/run_$run/$machine
		scp -r $machine:$results_directory $lts_directory/apps_capture/$label/${num_machines}_machines/run/run_$run/$machine || echo "It seems that machine $machine did not produce any data."
	done

	if [[ ${#no_capture} == 0 ]]; then
		# Compress the capture files from each machine, then put them into the LTS:
		for machine in ${capture_machines[@]}; do
			remote_run_command $machine "mkdir -p $lts_directory/apps_capture/$label/${num_machines}_machines/run/run_$run"
			remote_run_command $machine "bzip2 $capture_location/$label/${num_machines}_machines/${machine}-0.expcap; mv $capture_location/$label/${num_machines}_machines/${machine}-0.expcap.bz2 $lts_directory/apps_capture/$label/${num_machines}_machines/run/run_$run/${machine}.expcap.bz2; mv $capture_location/$label/${num_machines}_machines/${machine}_cmd_out $lts_directory/apps_capture/$label/${num_machines}_machines/run/run_$run/${machine}_cmd_out" &
		done
		wait
	fi

	# Also get the log information and the host information.
	for machine in ${machines[@]:0:$num_machines}; do
		echo "Getting log files from $machine"
		scp $machine:~/hostinfo $lts_directory/apps_capture/$label/${num_machines}_machines/run/run_$run/$machine
		scp -r $machine:~/logs $lts_directory/apps_capture/$label/${num_machines}_machines/run/run_$run/$machine
	done

	if [[ -f .failed ]]; then
		# This benchmark failed because something timed out.  Make that failure clear in the storage directory and exit with an error.
		# If the benchmark failed because of a timeout, something is wrong and we probably shouldn't repeat it anyway.
		echo "Benchmark timed out when running!"
		echo "Benchmark time out: either increase the TimeoutLimit in the apps/config file or look to see if the benchmark deadlocked somehow. " > $lts_directory/apps_capture/$label/${num_machines}_machines/run/run_$run/FAILED_WITH_TIMEOUT
		exit 124
	fi


	echo "Done with run!"
done
if [[ ${#no_capture} == 0 ]]; then
	echo "Done with capture!"
else
	echo "No capture run"
fi
popd
