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

if [[ ${#dry_run} -eq 0 ]] && [[ ${#no_setup} -eq 0 ]]; then
	./setup_nrg_machines.sh
fi

runs=$(get_config_value "Runs")

OSNTMachine=$(get_config_value "MachineA")
NRGMachine=$(get_config_value "MachineB")
HPTMachine=$(get_config_value "MachineC")

lts_location=$(get_config_value "LTSLocation" ../config)
hpt_port=$(get_config_value "HPTPort" config)
hpt_port1=$(get_config_value "HPTPort1" config)
cpus=$(get_config_value "HPTCPUs" config)
cpus1=$(get_config_value "HPTCPUs1" config)
rate=$(get_config_value "Rate")
num_to_send=$(get_config_value "NumPackets")
size=64

typeset -a files_to_compress
# Stop any recording that might be going on:
remote_run_script $HPTMachine hpt/stop_recording.sh
for run in $(seq 1 $runs); do
	for delay in $(cat < delays); do
		echo  "Starting run $run at rate $rate"
		if [[ ${#dry_run} -gt 0 ]]; then
			continue
		fi

		ipg=$((delay * 2)) # Get the packet all the way
		# through the NRG before we send another one.

		# Setup the NRG.
		remote_run_script $NRGMachine nrg/set_delay.sh $delay
		# Make sure that the NRG has time to get setup
		sleep 1

		file=/root/jcw78/nvme/nrg_delay/${delay}_run_$run
		file1=/root/jcw78/nvme/nrg_delay/${delay}_run_${run}_delayed
		# Start the HPTs recording.
		remote_run_script $HPTMachine hpt/record_port.sh $hpt_port $file $cpus /root/jcw78/nvme/nrg_delay/${delay}_run_${run}_cmd_out_port_0
		remote_run_script $HPTMachine hpt/record_port.sh $hpt_port1 $file1 $cpus1 /root/jcw78/nvme/nrg_delay/${delay}_run_${run}_cmd_out_port_1

		# Run OSNT.
		remote_run_script $OSNTMachine osnt/run_osnt.sh -ifp0 /root/jcw78/scripts/pcap_files/$size.cap -rpn0 $num_to_send -ipg0 $ipg -run
		sleep $((3 + $num_to_send * $ipg / 1000000000 ))

		# Stop the HPT recording.
		remote_run_script $HPTMachine hpt/stop_recording.sh

		files_to_compress+=${file}-0.expcap
		files_to_compress+=${file1}-0.expcap
		if [[ ${#files_to_compress} -gt 10 ]]; then
			remote_run_script $HPTMachine general/parallel_compress.sh ${files_to_compress[@]}
			unset files_to_compress
			typeset -a files_to_compress
		fi
	done
done

if [[ ${#files_to_compress} -gt 0 ]]; then
	remote_run_script $HPTMachine general/parallel_compress.sh ${files_to_compress[@]}
	unset files_to_compress
	typeset -a files_to_compress
fi

# Finally, move the captured files to the long term storage.
remote_run_command $HPTMachine "mkdir -p $lts_location/nrg_delay/pcaps"
remote_run_command $HPTMachine "mv /root/jcw78/nvme/nrg_delay/* $lts_location/nrg_delay/pcaps"
