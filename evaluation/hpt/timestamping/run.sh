#!/bin/zsh

set -eu

typeset -a test_lists
zparseopts -D -E -single-hpt=test_lists -dual-hpt=test_lists -hpt-dag=test_lists

if [[ ${#test_lists} -lt 1 ]]; then
	echo "Usage: $0 then one of:
		--single-hpt (for two ports on a single HPT card)
		--dual-hpt (for two HPT cards)
		--hpt-dag (to compare an HPT card and a DAG)"
	exit 1
fi

compress_after=3

source /root/jcw78/scripts/general/parse_config.sh
source /root/jcw78/scripts/general/remote_run.sh
# First, setup the machines
./setup_accuracy_machines.sh

# Now, get the number of runs:
runs=$(get_config_value "Runs")
HPTMachine=$(get_config_value "MachineB")
OtherHPTMachine=$(get_config_value "OtherHPTMachine" dual_hpt/config)
DAGMachine=$(get_config_value "DAGMachine" hpt_vs_dag/config)
lts_loc=$(get_config_value "LTSLocations")

if [[ ${test_lists[@]} == *"--single-hpt"* ]]; then
	last_compress=1
	for run in $(seq 1 $runs); do
		echo "Starting run number $run"
		pushd single_hpt/
		./run.sh
		popd

		# This script will have compressed each one individually,
		# meaning we only have to move the directory as a whole.
		remote_run_command $HPTMachine "mv /root/jcw78/nvme/hpt_accuracy_same_card/ /root/jcw78/nvme/hpt_accuracy_same_card_run_$run/"

		if (( run % compress_after == 0 )) || [[ $run == $runs ]]; then
			remote_run_command $HPTMachine "cd /root/jcw78/nvme; parallel 'cd /root/jcw78/nvme/hpt_accuracy_same_card_run_{}; bzip2 /root/jcw78/nvme/hpt_accuracy_same_card_run_{}/*.expcap' ::: $(seq -s' ' $last_compress $run)"
			last_compress=$((run + 1))
		fi
	done
	# Copy all those files to the long term storage device.
	remote_run_command $HPTMachine "mkdir -p $lts_loc/hpt_accuracy_same_card"
	remote_run_command $HPTMachine "rm -rf $lts_loc/hpt_accuracy_same_card/hpt_accuracy_same_card_run_*"
	remote_run_command $HPTMachine "mv /root/jcw78/nvme/hpt_accuracy_same_card_run_* $lts_loc/hpt_accuracy_same_card"
fi

if [[ ${test_lists[@]} == *dual-hpt* ]]; then
	last_compress=1
	echo "Now, make sure that OSNT is connected to two different HPT cards through a splitter."
	cont_msg="Enter to continue"
	vared 'cont_msg'

	for run in $(seq 1 $runs); do
		pushd dual_hpt
		./run.sh
		popd

		# This script will have compressed each one individually,
		# meaning we only have to move the directory as a whole.
		remote_run_command $HPTMachine "mv /root/jcw78/nvme/hpt_accuracy_different_cards/ /root/jcw78/nvme/hpt_accuracy_different_cards_card_0_run_$run/"
		remote_run_command $OtherHPTMachine "mv /root/jcw78/nvme/hpt_accuracy_different_cards/ /root/jcw78/nvme/hpt_accuracy_different_cards_card_1_run_$run/"

		if (( run % compress_after == 0 )) || [[ $run == $runs ]]; then
			remote_run_command $HPTMachine "cd /root/jcw78/nvme; parallel 'cd /root/jcw78/nvme/hpt_accuracy_different_cards_card_0_run_{}; bzip2 /root/jcw78/nvme/hpt_accuracy_different_cards_card_0_run_{}/*.expcap' ::: $(seq -s' ' $last_compress $run)"
			remote_run_command $OtherHPTMachine "cd /root/jcw78/nvme; parallel 'cd /root/jcw78/nvme/hpt_accuracy_different_cards_card_1_run_{}; bzip2 /root/jcw78/nvme/hpt_accuracy_different_cards_card_1_run_{}/*.expcap' ::: $(seq -s' ' $last_compress $run)"
			last_compress=$(( run + 1 ))
		fi
	done

	# Move all those to the LTS device.
	remote_run_command $HPTMachine "rm -rf $lts_loc/hpt_accuracy_different_cards_card_0"
	remote_run_command $HPTMachine "mkdir -p $lts_loc/hpt_accuracy_different_cards_card_0"
	remote_run_command $HPTMachine "mv /root/jcw78/nvme/hpt_accuracy_different_cards_card_0_run_* $lts_loc/hpt_accuracy_different_cards_card_0"

	remote_run_command $OtherHPTMachine "rm -rf $lts_loc/hpt_accuracy_different_cards_card_1"
	remote_run_command $OtherHPTMachine "mkdir -p $lts_loc/hpt_accuracy_different_cards_card_1"
	remote_run_command $OtherHPTMachine "mv /root/jcw78/nvme/hpt_accuracy_different_cards_card_1_run_* $lts_loc/hpt_accuracy_different_cards_card_1"
fi

if [[ "${test_lists[@]}" == *-hpt-dag* ]]; then
	last_compress=1
	echo "Make sure that OSNT is connected to a DAG and an HPT card through a splitter."
	cont_msg="Enter to continue"
	vared 'cont_msg'

	for run in $(seq 1 $runs); do
		pushd hpt_vs_dag/
		./run.sh
		popd

		# This script will have compressed each one individually,
		# meaning we only have to move the directory as a whole.
		remote_run_command $HPTMachine "mv /root/jcw78/nvme/hpt_accuracy_vs_dag/ /root/jcw78/nvme/hpt_accuracy_vs_dag_run_$run/"
		remote_run_command $DAGMachine "mv /root/jcw78/nvme/hpt_accuracy_vs_dag/ /root/jcw78/nvme/hpt_accuracy_vs_dag_run_$run/"

		if (( run % compress_after == 0 )) || [[ $run == $runs ]]; then
			remote_run_command $HPTMachine "cd /root/jcw78/nvme; parallel 'cd /root/jcw78/nvme/hpt_accuracy_vs_dag_run_{}; bzip2 /root/jcw78/nvme/hpt_accuracy_vs_dag_run_{}/*.expcap' ::: $(seq -s' ' $last_compress $run)"
			remote_run_command $DAGMachine "cd /root/jcw78/nvme; parallel 'cd /root/jcw78/nvme/hpt_accuracy_vs_dag_run_{}; bzip2 /root/jcw78/nvme/hpt_accuracy_vs_dag_run_{}/*.erf' ::: $(seq -s' ' $last_compress $run)"
			last_compress=$((run + 1))
		fi
	done

	# Move all those to the LTS device.
	remote_run_command $HPTMachine "mkdir -p $lts_loc/hpt_hpt_accuracy_vs_dag"
	remote_run_command $HPTMachine "rm -rf $lts_loc/hpt_hpt_accuracy_vs_dag/hpt_accuracy_vs_dag_run_*"
	remote_run_command $HPTMachine "mv /root/jcw78/nvme/hpt_accuracy_vs_dag_run_* $lts_loc/hpt_hpt_accuracy_vs_dag"

	# Move all those to the LTS device.
	remote_run_command $DAGMachine "mkdir -p $lts_loc/dag_hpt_accuracy_vs_dag"
	remote_run_command $DAGMachine "rm -rf $lts_loc/dag_hpt_accuracy_vs_dag/hpt_accuracy_vs_dag_run_*"
	remote_run_command $DAGMachine "mv /root/jcw78/nvme/hpt_accuracy_vs_dag_run_* $lts_loc/dag_hpt_accuracy_vs_dag"
fi

echo "All done!"
