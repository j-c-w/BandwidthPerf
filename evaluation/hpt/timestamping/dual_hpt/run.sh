#!/bin/zsh

set -ue

zmodload zsh/mathfunc

source /root/jcw78/scripts/general/parse_config.sh
source /root/jcw78/scripts/general/remote_run.sh

typeset -a dry_run
zparseopts -D -E -dry=dry_run

# Get the number of packets to send.
num_to_send=$(get_config_value NumberToSend)
starting_rate=$(get_config_value MinRate)
final_rate=$(get_config_value MaxRate)
increase=$(get_config_value StepSize)

OSNTMachine=$(get_config_value MachineA ../config)
HPTMachine=$(get_config_value MachineB ../config)
OtherHPTMachine=$(get_config_value OtherHPTMachine config)

exa_port=$(get_config_value HPTInterface0 ../config)
other_exa_port=$(get_config_value OtherHPTInterface0 config)
cpus=$(get_config_value HPTCPUs0 ../config)
other_cpus=$(get_config_value OtherHPTCPUs config)
# Keep track of the total space used.
total_space=0.0
# Wire capacity in Mbps.
wire_capacity=10000
packet_length=64

# Before we start, make sure that all existing recording
# is killed:
remote_run_script $HPTMachine hpt/stop_recording.sh
remote_run_script $OtherHPTMachine hpt/stop_recording.sh

for rate in $(seq $starting_rate $increase $final_rate); do
	echo "Capturing at $rate Mbps"
	# Calculate the IPG from the rate here:
	# On a 10G channel, one bit is 0.1ns.
	# IPG = target_rate * (packet wire time / max wire rate) - packet wire time
	packet_time=$(( 1000.0 * $packet_length * 8.0 / $wire_capacity ))
	ipg=$((int(rint($(echo "scale=30; 10000.0 * ($packet_time / $rate) - $packet_time" | bc)))))
	echo "==========================================="
	echo "Running tests for rate $rate"
	echo "This means using inter-arrival gap ${ipg}ns"
	expected_time=$(( (num_to_send * ($packet_length * 8)) / ($rate * 1000000) ))
	expected_space=$(( num_to_send * packet_length ))
	total_space=$(( total_space + expected_space / 1000000000.0 ))
	echo "Expected runtime is $expected_time"
	echo "Expected space is ${expected_space}B"
	echo "Total space used by this test is $total_space GB"
	if [[ ${#dry_run} -gt 0 ]]; then
		continue
	fi
	# Start the exanic recording on both machines.
	remote_run_script $HPTMachine hpt/record_port.sh $exa_port /root/jcw78/nvme/hpt_accuracy_different_cards/${rate}_joint_timing_card_0 $cpus /root/jcw78/nvme/hpt_accuracy_different_cards/${rate}_joint_timing_card_0_cmd_out
	remote_run_script $OtherHPTMachine hpt/record_port.sh $other_exa_port /root/jcw78/nvme/hpt_accuracy_different_cards/${rate}_joint_timing_card_1 $other_cpus /root/jcw78/nvme/hpt_accuracy_different_cards/${rate}_joint_timing_card_1_cmd_out

	# Run OSNT at the desired rate.
	remote_run_script $OSNTMachine osnt/run_osnt.sh -ifp0 /root/jcw78/scripts/pcap_files/64.cap -rpn0 $num_to_send -ipg0 $ipg -run
	sleep $(( int(expected_time) + 6 ))

	# End the exanic recording.
	remote_run_script $HPTMachine hpt/stop_recording.sh
	remote_run_script $OtherHPTMachine hpt/stop_recording.sh
done
