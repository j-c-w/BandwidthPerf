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

installed=False

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

pushd /root/jcw78/SUMMER2017/apps/benchmark/
for run in $(seq 1 $runs); do
	echo "Starting new run at $(date)"
	#### This part handles rebooting machines for caches etc.
	# Reboot the machines we are using and give them time
	# to turn on.  (Unless this was disabled)
	if [[ ${#no_reboot} == 0 ]]; then
		echo "Starting machine reboot..."
		/root/jcw78/scripts/apps/reboot_machines.sh ${machines[@]}
		sleep $reboot_time
		echo "Reboot done!"
	fi

	#### This part handles machines that might have gone down
	# Get $num_machines machines that are up.
	typeset -a working_machines
	typeset -a broken_machines
	for mach in ${machines[@]}; do
		ping_attempts=0
		reached="True"
		while ! ping $mach -c 1; do
			ping_attempts=$((ping_attempts + 1))
			if (($ping_attempts > 5)); then
				reached=False
				echo "Failed to reach machine $mach!"
				echo "Seeing if there is another machine available"
				break
			fi
		done

		if [[ $reached == "True" ]]; then
			working_machines+=$mach
		else
			broken_machines+=$mach
		fi
	done

	if [[ ${#working_machines} < $num_machines ]]; then
		# If there are not enough working machines, skip this run.
		echo "Also aborting benchmark run."
		echo "Aborted run at $(date): machines ${broken_machines[@]} were broken.  If that list is empty, perhaps you asked for more machines than specified in the 'machines' file?" >> /root/jcw78/scripts/apps/BENCHMARK_MACHINE_FAILURES

		exit 123
	fi

	if [[ "${working_machines[@]}" != "${machines[@]}" ]]; then
		# If the working machines are not the same as the machines
		# we originally installed and setup for, then we need to
		# do that again.
		installed=False
	fi

	# Set machines equal to the number of working machines.
	machines=("${working_machines[@]}")

	# Install if we haven't installed yet:
	if [[ $installed == *False* ]]; then
		pushd /root/jcw78/scripts/apps
		./generate_config.sh $num_machines ${machines[@]:0:$num_machines}
		./install_apps.sh ${machines[@]}
		popd
		for benchmark in "${benchmarks[@]}"; do
			./run.sh install $benchmark
		done
		installed=True
	fi

	#### This part deals with running the benchmark.
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
	set -x
	if [[ ${#no_capture} == 0 ]]; then
		# Start all the capture cards:
		for machine in ${capture_machines[@]}; do
			echo "Setting up capture on $machine"
			# Kill any ongoing recording going on:
			remote_run_script $machine hpt/stop_recording.sh
			# Check that the machine we are instrumenting is not one that failed.
			instrumented_machine=$(get_config_value "${machine}_instrumenting" /root/jcw78/scripts/apps/capture_config)
			for broken_machine in ${broken_machines[@]}; do
				if [[ *${broken_machine}* == $instrumented_machine ]]; then
					echo "A broken machine is one of the machines being instrumented"
					echo "Machine is $instrumented_machine and is being instrumented by the capture card on $machine"
					echo "This is a fatal error"
					exit 122
				fi
			done

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
				remote_run_script $machine hpt/record_port.sh $interface1 $interface2 $capture_location/$label/${num_machines}_machines/$machine $cpus $capture_location/$label/${num_machines}_machines/${machine}_cmd_out
			else
				interface1=$(get_config_value "${machine}_if1" /root/jcw78/scripts/apps/capture_config)
				remote_run_script $machine hpt/record_port.sh $interface1 $capture_location/$label/${num_machines}_machines/$machine $cpus $capture_location/$label/${num_machines}_machines/${machine}_cmd_out
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

	##### This part deals with the cleanup.
	# Get the files from each machine.  If they don't exist,
	# that's alright, the machines just might not have been
	# involved.
	# First clear any old results from the folder we are about
	# to populate.
	results_directory=$lts_directory/apps_capture/$label/${num_machines}_machines/run/run_$run/
	if [[ -d $results_directory ]]; then
		rm -rf $results_directory
	fi

	mkdir -p $results_directory
	for machine in ${machines[@]:0:$num_machines}; do
		# We need to make sure that the directory is created
		# regardless of whether we copy anything back.
		mkdir -p $results_directory/$machine
		scp -r $machine:$results_directory $results_directory/$machine || echo "It seems that machine $machine did not produce any data."
	done

	if [[ ${#no_capture} == 0 ]]; then
		# Compress the capture files from each machine, then put them into the LTS:
		for machine in ${capture_machines[@]}; do
			# Catalogue the machine that each machine captured on.
			instrumented_machine=$(get_config_value "${machine}_instrumenting" /root/jcw78/scripts/apps/capture_config)

			remote_run_command $machine "mkdir -p $results_directory"
			remote_run_command $machine "bzip2 $capture_location/$label/${num_machines}_machines/${machine}-0.expcap; mv $capture_location/$label/${num_machines}_machines/${machine}-0.expcap.bz2 $results_directory/${instrumented_machine}_captured_by_${machine}.expcap.bz2; mv $capture_location/$label/${num_machines}_machines/${machine}_cmd_out $results_directory/${instrumented_machine}_captured_by_${machine}_cmd_out" &
		done
		wait
	fi

	# Also get the log information and the host information.
	for machine in ${machines[@]:0:$num_machines}; do
		echo "Getting log files from $machine"
		scp $machine:~/hostinfo $results_directory/$machine
		scp -r $machine:~/logs $results_directory/$machine
	done

	# Finally, we want to keep the relevant parts of the config file.  Namely, we want to keep the part that links each  machine to each role.
	roles_file=$results_directory/MachineRoles
	touch $roles_file

	# The  config file works in IP addresses.  Leave the mapping
	# of machine to IP address that we used in there.
	for machine in ${machines[@]:0:$num_machines}; do
		management_interface=$(nslookup $machine | tail -n 3 | awk -F':' '/Address: / {print $2 }' | tr -d ' ')
		echo "IP Address for $machine is $management_interface" >> $roles_file
	done

	# Get the relevant parts of the config file and leave it
	# as evidence
	for benchmark in ${benchmarks[@]}; do
		echo "Configuration for benchmark $benchmark is:" >> $roles_file
		grep -e $benchmark config >> $roles_file
	done

	if [[ -f .failed ]]; then
		# This benchmark failed because something timed out.  Make that failure clear in the storage directory and exit with an error.
		# If the benchmark failed because of a timeout, something is wrong and we probably shouldn't repeat it anyway.
		echo "Benchmark timed out when running!"
		echo "Benchmark time out: either increase the TimeoutLimit in the apps/config file or look to see if the benchmark deadlocked somehow. " > $results_directory/FAILED_WITH_TIMEOUT
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
