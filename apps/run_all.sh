#!/bin/zsh

echo "This script runs and captures all of the setups defined"
echo "in the ./apps file.  See that file for comments on how"
echo "to modify it"

set -eu
typeset -a dry_run
typeset -a no_capture
zparseopts -D -E -dry-run=dry_run -no-capture=no_capture

source /root/jcw78/scripts/general/parse_config.sh
source /root/jcw78/scripts/general/remote_run.sh

nrg_machine=$(get_config_value NRGMachine)
timeout_limit=$(get_config_value TimeoutLimit)

typeset -a lines

# Parse the apps file.  
while IFS= read -r line; do
	lines+="$line"
done < apps

for line in ${lines[@]}; do
	if [[ $line == *#* ]] || [[ $line == '' ]]; then
		continue
	fi
	echo $line

	name=$(cut -f1 -d ' ' <<< $line)
	number_of_machines=$(cut -f2 -d ' ' <<< $line)
	nrg_delay=$(cut -f3 -d ' ' <<< $line)
	nrg_bandwidth=$(cut -f4 -d ' ' <<< $line)

	# All remaining items are benchmarks.
	benchmarks=$(cut --complement -f1-4 -d' ' <<< $line)

	if [[ $nrg_delay != *None* ]] && [[ $nrg_bandwidth != *None* ]]; then
		echo "Warning: setup with both delay and bandwidth is untested.  Remove this warning (and subsequent exit) if you are sure."
		exit 1
	fi

	if [[ ${#dry_run} == 1 ]]; then
		echo "Name $name, number $number_of_machines, benchmarks $benchmarks"
		echo "NRG delay is $nrg_delay"
		echo "NRG bandwidth is $nrg_bandwidth"
		continue
	fi

	if [[ $nrg_machine != *None* ]]; then
		echo "Using the NRG!"
		echo "NRG machine is $nrg_machine"

		remote_run_script $nrg_machine bitfiles/setup_bitfile.sh super_gadget.bit
	fi

	if [[ $nrg_delay != *None* ]]; then
		remote_run_script $nrg_machine nrg/set_delay.sh $nrg_delay
	else
		remote_run_script $nrg_machine nrg/set_delay.sh 0
	fi
	
	if [[ $nrg_bandwidth != *None* ]]; then

		remote_run_script $nrg_machine nrg/set_rate.sh $nrg_bandwidth
	else
		remote_run_script $nrg_machine nrg/set_rate.sh $nrg_bandwidth
	fi

	flags=""
	if [[ ${#no_capture} != 0 ]]; then
		flags="--no-capture"
	fi

	# If the benchmark times out, it will exit with code
	# 124.  If that happens, then we should note it in the
	# BENCHMARK_TIMEOUTS file, but keep going.
	# This '||' business is a bit of a hack to avoid
	# issues with set -e.
	ret_code=0
	(./capture_run.sh $benchmarks $number_of_machines $name $flags | tee capture_run_output) || ret_code=$?
	if [[ $ret_code == 124 ]]; then
		echo "Benchmark timed out.  Logging information to BENCHMARK_TIMEOUTS"
		echo "The run specified by line '$line' has timed out.  This happened at $(date)" >> BENCHMARK_TIMEOUTS
	elif [[ $ret_code == 123 ]]; then
		echo "One or more of the machines was unreachable. "
		echo "The run specified by line '$line' is using a machine that is not reachable.  See the run logs for more information." >> MACHINE_FAILURES
	elif [[ $ret_code == 122 ]]; then
		echo "Error: one of the machines you were capturing from has died"
		echo "This is a fatal error.  Exiting"
		echo "The run specified by '$line' is using a machine that is not reachable.  We did not carry on because the machine that failed is being captured from.  This should be fixed." >> MACHINE_FAILURES
		exit 122
	elif [[ $ret_code != 0 ]]; then
		# Misc error.  We don't exit any more, but we do keep the output as a record.
		echo "=========== FAILED RUNNING ========== (error code $ret_code)"
		echo "Config line was $line"
		echo "Capture run output was:"
		cat capture_run_output >> FAILED_RUNS_LOG
	fi

	echo "Run finished, moving on to next run"
done
