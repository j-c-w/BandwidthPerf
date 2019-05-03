#!/bin/zsh

set -eu
zmodload zsh/mathfunc

source /root/jcw78/scripts/general/parse_config.sh
source /root/jcw78/scripts/general/remote_run.sh

typeset -a dry_run
typeset -a no_setup
zparseopts -D -E -dry-run=dry_run -no-setup=no_setup
if [[ $# -ne 0 ]]; then
	echo "Expected no arguments"
	exit 1
fi

if [[ ${#no_setup} -eq 0 ]] && [[ ${#dry_run} -eq 0 ]]; then
	./setup_nrg_machines.sh
fi

runs=$(get_config_value "Runs")
min_rate=$(get_config_value "MinRate")
max_rate=$(get_config_value "MaxRate")
step_size=$(get_config_value "StepSize")

iperf1_mach=$(get_config_value "MachineA")
iperf1_mach_test_interface=$(get_config_value "MachineATestIP")
iperf1_mach_interface=$(get_config_value "NICA")
iperf2_mach=$(get_config_value "MachineD")
iperf2_mach_test_interface=$(get_config_value "MachineDTestIP")
iperf2_mach_interface=$(get_config_value "NICD")
HPTMachine=$(get_config_value "MachineC")
NRGMachine=$(get_config_value "MachineB")
should_record=$(get_config_value "Record")
iperf_run_length=$(get_config_value "IPerfRunLength")

lts_location=$(get_config_value "LTSLocation" ../config)
hpt_port=$(get_config_value "HPTPort" ../config)
cpus=$(get_config_value "HPTCPUs" ../config)

if [[ $should_record == True ]]; then
	# Stop any recording that might be going on:
	remote_run_script $HPTMachine hpt/stop_recording.sh
fi

# Make sure the interfaces have the right IP addresses:
remote_run_command $iperf1_mach "ifconfig $iperf1_mach_interface up $iperf1_mach_test_interface"
remote_run_command $iperf2_mach "ifconfig $iperf2_mach_interface up $iperf2_mach_test_interface"

for run in $(seq 1 $runs); do
	for rate in $(seq $min_rate $step_size $max_rate); do
		echo  "Starting run $run at rate $rate"
		if [[ ${#dry_run} -gt 0 ]]; then
			continue
		fi

		# Setup the NRG.
		set -x
		remote_run_script $NRGMachine nrg/set_rate.sh $(( $rate / 1000.0 ))
		# Make sure that the NRG has time to get set  up.
		sleep 1

		file=/root/jcw78/nvme/nrg_rate/${rate}_run_$run
		if [[ $should_record == True ]]; then
			# Start the HPT recording.
			remote_run_script $HPTMachine hpt/record_port.sh $hpt_port $file $cpus /root/jcw78/nvme/nrg_rate/${rate}_run_${run}_cmd_out
		fi

		# Run iperf
		/root/jcw78/scripts/iperf/run_iperf.sh $iperf1_mach $iperf1_mach_test_interface $iperf2_mach $iperf_run_length ${rate}_iperf_server_${run}_out ${rate}_iperf_client_${run}_out

		# Move the iperf command output to a more permanent folder:
		mkdir -p $lts_location/nrg_rate_data
		mv ${rate}_iperf_server_${run}_out $lts_location/nrg_rate_data
		mv ${rate}_iperf_client_${run}_out $lts_location/nrg_rate_data

		if [[ $should_record == True ]]; then
			# Stop the HPT recording.
			remote_run_script $HPTMachine hpt/stop_recording.sh

			# Compress if needed
			files_to_compress+=${file}-0.expcap
			if [[ ${#files_to_compress} -gt 10 ]]; then
				remote_run_script $HPTMachine general/parallel_compress.sh $files_to_compress
				unset files_to_compress
				typeset -a files_to_compress
			fi
		fi
	done

	if [[ $should_record == True ]]; then
		# Compress any files left to do:
		if [[ ${#files_to_compress} -gt 0 ]]; then
			remote_run_script $HPTMachine general/parallel_compress.sh $files_to_compress
			unset files_to_compress
			typeset -a files_to_compress
		fi
	fi
	# Move the iperf files into the LTS location.
	mkdir -p $lts_location/nrg_rate/run_$run
	mv $lts_location/nrg_rate_data/* $lts_location/nrg_rate/run_$run
done

if [[ $should_record == True ]]; then
	# Finally, move the captured files to the long term storage.
	remote_run_command $HPTMachine "mkdir -p $lts_location/nrg_rate/pcaps"
	remote_run_command $HPTMachine "mv /root/jcw78/nvme/nrg_rate/* $lts_location/nrg_rate/pcaps"
fi
