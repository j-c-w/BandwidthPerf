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

exa_port0=$(get_config_value HPTInterface0 ../config)
exa_port1=$(get_config_value HPTInterface1 ../config)
both_cpus=$(get_config_value HPTCPUsBoth ../config)
# Keep track of the total space used.
total_space=0.0
# Wire capacity in Mbps.
wire_capacity=10000
packet_length=$(get_config_value PacketSize)

# Before we start, make sure that all existing recording
# is killed:
remote_run_script $HPTMachine hpt/stop_recording.sh

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
	# Start the exanic recording.
	remote_run_script $HPTMachine hpt/record_port.sh $exa_port0 $exa_port1 /root/jcw78/nvme/two_port_scan/${rate}_two_port.erf $both_cpus /root/jcw78/nvme/two_port_scan/${rate}_both_ports_cmd_out

	# Run OSNT at the desired rate.
	remote_run_script $OSNTMachine osnt/run_osnt.sh -ifp0 /root/jcw78/scripts/pcap_files/64.cap -rpn0 $num_to_send -ipg0 $ipg -run
	sleep $(( int(expected_time) + 6 ))

	# End the exanic recording.
	remote_run_script $HPTMachine hpt/stop_recording.sh

	# Remove the capture file: we don't actually care about that.
	remote_run_command $HPTMachine "rm /root/jcw78/nvme/two_port_scan/*.expcap"
done
