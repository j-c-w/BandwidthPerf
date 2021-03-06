#!/bin/zsh
#
zmodload zsh/mathfunc

echo "This script runs and captures all of the setups defined"
echo "in the ./apps file.  See that file for comments on how"
echo "to modify it"

set -eu
typeset -a dry_run
typeset -a no_capture
typeset -a no_reboot
zparseopts -D -E -dry-run=dry_run -no-capture=no_capture -no-reboot=no_reboot

if [[ $# -ne 0 ]]; then
	echo "Usage: $0 [flags]"
	echo "--dry-run to just print values"
	echo "--no-capture to not capture"
	echo "--no-reboot to not reboot machines between runs"
	exit 1
fi

source /root/jcw78/scripts/general/parse_config.sh
source /root/jcw78/scripts/general/remote_run.sh

nrg_machines=($(cat < nrg_machines))
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
	no_capture_setting=$(cut -f3 -d ' ' <<< $line)
	nrg_delay=$(cut -f4 -d ' ' <<< $line)
	nrg_bandwidth=$(cut -f5 -d ' ' <<< $line)
	alternate_config_env=$(cut -f6 -d ' ' <<< $line)

	# All remaining items are benchmarks.
	benchmarks=($(cut --complement -f1-6 -d' ' <<< $line))
	echo "Running ${#benchmarks} benchmarks"

	# Move in the new config-env if we are using it.
	if [[ $alternate_config_env != None ]]; then
		echo "Using a different config-env.sh.  Moving the defualt one into config-env.sh.old"
		echo "Copying from $alternate_config_env"
		if [[ ${#dry_run} == 0 ]]; then
			set -x
			current_dir=$PWD
			pushd /root/jcw78/SUMMER2017/apps/benchmark
			if [[ ! -f config-env.sh.old ]]; then
				# If this isn't the case, there was probably an early exit that left the FS in an invalid state.
				mv config-env.sh config-env.sh.old
			fi
			cp $current_dir/$alternate_config_env config-env.sh
			popd
		fi
	fi

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

	for nrg_machine in ${nrg_machines[@]}; do
		if [[ $nrg_machine == *None* ]]; then
			continue
		fi

		echo "Using the NRG!"
		echo "NRG machine is $nrg_machine"
		echo "Setting NRG delay to $nrg_delay"
		echo "Seeting NRG rate to $nrg_bandwidth"

		remote_run_script $nrg_machine bitfiles/setup_bitfile.sh super_gadget.bit

		if [[ $nrg_delay != *None* ]]; then
			remote_run_script $nrg_machine nrg/set_delay.sh $nrg_delay
		else
			remote_run_script $nrg_machine nrg/set_delay.sh 0
		fi
		
		if [[ $nrg_bandwidth != *None* ]]; then

			remote_run_script $nrg_machine nrg/set_rate.sh $(( nrg_bandwidth / 1000.0 ))
		else
			remote_run_script $nrg_machine nrg/set_rate.sh 10
		fi
	done

	no_capture_flags=""
	if [[ ${#no_capture} != 0 || $no_capture_setting == NoCapture ]]; then
		no_capture_flags="--no-capture"
	fi

	no_reboot_flags=""
	if [[ ${#no_reboot} != 0 ]]; then
		no_reboot_flags="--no-reboot"
	fi

	# If the benchmark times out, it will exit with code
	# 124.  If that happens, then we should note it in the
	# BENCHMARK_TIMEOUTS file, but keep going.
	# This '||' business is a bit of a hack to avoid
	# issues with set -e.
	ret_code=0
	(./capture_run.sh $benchmarks $number_of_machines $name $no_capture_flags $no_reboot_flags | tee capture_run_output; echo ${pipestatus[1]} > .ret_code)
	ret_code=$(cat < .ret_code)
	echo "Benchmark done, return code '$ret_code'"

	# If the config-end.sh.old was created, then move that back.
	if [[ -f /root/jcw78/SUMMER2017/apps/benchmark/config-env.sh.old ]]; then
		pushd /root/jcw78/SUMMER2017/apps/benchmark/
		mv config-env.sh.old config-env.sh
		popd
	fi

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

	cat capture_run_output >> ALL_RUNS_OUTPUT_LOG

	echo "Run finished, moving on to next run"
done
