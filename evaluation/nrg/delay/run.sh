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
hpt_port=$(get_config_value "HPTPort" ../config)
hpt_port1=$(get_config_value "HPTPort1" ../config)
cpus=$(get_config_value "HPTCPUs" ../config)
cpus1=$(get_config_value "HPTCPUs1" ../config)
rate=$(get_config_value "Rate")
num_to_send=$(get_config_value "NumPackets")
wire_capacity=10000
size=64

# Stop any recording that might be going on:
remote_run_script $HPTMachine hpt/stop_recording.sh
for run in $(seq 1 $runs); do
	for delay in $(cat < delays); do
		echo  "Starting run $run at rate $rate"
		if [[ ${#dry_run} -gt 0 ]]; then
			continue
		fi
		packet_time=$(( 1000.0 * $size * 8.0 / $wire_capacity ))
		ipg=$((int(rint($(echo "scale=30; 10000.0 * ($packet_time / $rate) - $packet_time" | bc)))))
		echo "==========================================="
		echo "Running tests for rate $rate"
		echo "This means using inter-arrival gap ${ipg}ns"
		expected_time=$(( (num_to_send * ($size * 8)) / ($rate * 1000000) ))
		expected_space=$(( num_to_send * size ))
		total_space=$(( total_space + expected_space / 1000000000.0 ))
		echo "Expected runtime is $expected_time"
		echo "Expected space is ${expected_space}B"
		echo "Total space used by this test is $total_space GB"

		if [[ ${#dry_run} -gt 0 ]]; then
			continue
		fi

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
		sleep $(( int(expected_time) + 3 ))

		# Stop the HPT recording.
		remote_run_script $HPTMachine hpt/stop_recording.sh

		files_to_compress+=${file}-0.expcap
		files_to_compress+=${file1}-0.expcap
		if [[ ${#files_to_compress} -gt 10 ]]; then
			remote_run_script $HPTMachine general/parallel_compress.sh $files_to_compress
			unset files_to_compress
			typeset -a files_to_compress
		fi
	done
done

if [[ ${#files_to_compress} -gt 0 ]]; then
	remote_run_script $HPTMachine general/parallel_compress.sh $files_to_compress
	unset files_to_compress
	typeset -a files_to_compress
fi

# Finally, move the captured files to the long term storage.
remote_run_command $HPTMachine "mkdir -p $lts_location/nrg_delay/pcaps"
remote_run_command $HPTMachine "mv /root/jcw78/nvme/nrg_delay/* $lts_location/nrg_delay/pcaps"
