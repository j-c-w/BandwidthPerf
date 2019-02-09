#!/bin/zsh

set -eu
zmodload zsh/mathfunc

source /root/jcw78/scripts/general/parse_config.sh
source /root/jcw78/scripts/general/remote_run.sh

typeset -a dry_run
zparseopts -D -E -dry-run=dry_run
if [[ $# -ne 0 ]]; then
	echo "Expected no arguments"
	exit 1
fi

if [[ ${#dry_run} -eq 0 ]]; then
	# ./setup_nrg_machines.sh
fi

runs=$(get_config_value "Runs")
min_rate=$(get_config_value "MinRate")
max_rate=$(get_config_value "MaxRate")
step_size=$(get_config_value "StepSize")

iperf1_mach=$(get_config_value "MachineA")
iperf1_mach_test_interface=$(get_config_value "MachineATestIP")
iperf2_mach=$(get_config_value "MachineD")
HPTMachine=$(get_config_value "MachineC")
NRGMachine=$(get_config_value "MachineB")

lts_location=$(get_config_value "LTSLocation" ../config)
hpt_port=$(get_config_value "HPTPort" ../config)
cpus=$(get_config_value "HPTCPUs" ../config)

# Stop any recording that might be going on:
remote_run_script $HPTMachine hpt/stop_recording.sh
for run in $(seq 1 $runs); do
	for rate in $(seq $min_rate $step_size $max_rate); do
		echo  "Starting run $run at rate $rate"
		if [[ ${#dry_run} -gt 0 ]]; then
			continue
		fi

		# Setup the NRG.
		set -x
		remote_run_script $NRGMachine nrg/set_rate.sh $(( $rate / 1000.0 ))

		file=/root/jcw78/nvme/nrg_rate/${rate}_run_$run
		# Start the HPT recording.
		remote_run_script $HPTMachine hpt/record_port.sh $hpt_port $file $cpus /root/jcw78/nvme/nrg_rate/${rate}_run_${run}_cmd_out

		# Run iperf
		/root/jcw78/scripts/iperf/run_iperf.sh $iperf1_mach $iperf1_mach_test_interface $iperf2_mach 5 ${rate}_iperf_server_${run}_out ${rate}_iperf_client_${run}_out

		# Move the iperf command output to a more permanent folder:
		mkdir -p $lts_location/nrg_rate_data
		mv ${rate}_iperf_server_${run}_out $lts_location/nrg_rate_data
		mv ${rate}_iperf_client_${run}_out $lts_location/nrg_rate_data

		# Stop the HPT recording.
		remote_run_script $HPTMachine hpt/stop_recording.sh

		files_to_compress+=${file}-0.expcap
		if [[ ${#files_to_compress} -gt 10 ]]; then
			remote_run_script $HPTMachine general/parallel_compress.sh $files_to_compress
			unset files_to_compress
			typeset -a files_to_compress
		fi
	done

	mkdir -p $lts_location/nrg_rate
	# Clear any old data left there.
	rm -rf $lts_location/nrg_rate/run_$run
	mv $lts_location/nrg_rate_data $lts_location/nrg_rate/run_$run
done

# Finally, move the captured files to the long term storage.
remote_run_command $HPTMachine "mkdir -p $lts_location/nrg_rate/pcaps"
remote_run_command $HPTMachine "mv /root/jcw78/nvme/nrg_rate/* $lts_location/nrg_rate/pcaps"
