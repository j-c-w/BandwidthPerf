#!/bin/zsh

set -ue

zmodload zsh/mathfunc

source /root/jcw78/scripts/general/parse_config.sh
source /root/jcw78/scripts/general/remote_run.sh

# Get the number of packets to send.
num_to_send=$(get_config_value NumberToSend)
starting_rate=$(get_config_value MinRate)
final_rate=$(get_config_value MaxRate)
increase=$(get_config_value StepSize)

OSNTMachine=$(get_config_value MachineA ../config)
HPTMachine=$(get_config_value MachineB ../config)

exa_port0=$(get_config_value HPTInterface0 ../config)
cpus=$(get_config_value HPTCPUs0 ../config)
packet_length=64 #  In bytes.
# Keep track of the total space used.
total_space=0.0
# Wire capacity in Mbps.
wire_capacity=10000

# Before we start, make sure that all existing recording
# is killed:
remote_run_script $HPTMachine hpt/stop_recording.sh

for rate in $(seq $starting_rate $increase $final_rate); do
	echo "Capturing at $rate Mbps"
	# Start the exanic recording.
	remote_run_script $HPTMachine hpt/record_port.sh $exa_port0 /root/jcw78/nvme/${rate}_one_port.erf $cpus /root/jcw78/nvme/${rate}_cmd_out

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
	echo "Expected space is $expected_space"
	echo "Total space used by this test is $total_space GB"

	# Run OSNT at the desired rate.
	remote_run_script $OSNTMachine osnt/run_osnt.sh -ifp0 /root/jcw78/scripts/pcap_files/64.cap -rpn0 $num_to_send -ipg0 $ipg -run
	sleep $(( int(expected_time) + 3 ))

	# End the exanic recording.
	remote_run_script $HPTMachine hpt/stop_recording.sh
done
