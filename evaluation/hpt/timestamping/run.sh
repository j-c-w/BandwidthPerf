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


source /root/jcw78/scripts/general/parse_config.sh
source /root/jcw78/scripts/general/remote_run.sh
# First, setup the machines
./setup_size_machines.sh

# Now, get the number of runs:
runs=$(get_config_value "Runs")
HPTMachine=$(get_config_value "MachineB")
lts_loc=$(get_config_value "LTSLocations")

if [[ *single-hpt* == "${test_lists[@]}" ]]; then
	for run in $(seq 1 $runs); do
		echo "Starting run number $run"
		pushd single_hpt/
		./run.sh
		popd

		# This script will have compressed each one individually,
		# meaning we only have to move the directory as a whole.
		remote_run_command $HPTMachine "mv /root/jcw78/nvme/hpt_accuracy_same_card/ /root/jcw78/nvme/hpt_accuracy_same_card_run_$run/"

		if (( run % 10 = 0 )); then
			remote_run_command $HPTMachine "cd /root/jcw78/nvme; parallel bzip2 hpt_accuracy_same_card_run_{} ::: $(seq $((run - 9)) $run)"
		fi
	done
	# Copy all those files to the long term storage device.
	remote_run_command $HPTMachine "mkdir -p $lts/hpt_accuracy_same_card"
	remote_run_command $HPTMachine "mv /root/jcw78/nvme/hpt_accuracy_same_card_run_* $lts/hpt_accuracy_same_card"
fi

if [[ *dual-hpt* == ${test_lists[@]} ]]; then
	echo "Now, make sure that OSNT is connected to two different HPT cards through a splitter."
	cont_msg="Enter to continue"
	vared 'cont_msg'

	for run in $(seq 1 $runs); do
		pushd dual_hpt
		./run.sh
		popd

		# This script will have compressed each one individually,
		# meaning we only have to move the directory as a whole.
		remote_run_command $HPTMachine "mv /root/jcw78/nvme/hpt_accuracy_different_cards/ /root/jcw78/nvme/hpt_accuracy_different_cards_run_$run/"

		if (( run % 10 = 0 )); then
			remote_run_command $HPTMachine "cd /root/jcw78/nvme; parallel bzip2 hpt_accuracy_different_cards_run_{} ::: $(seq $((run - 9)) $run)"
		fi
	done

	# Move all those to the LTS device.
	remote_run_command $HPTMachine "mkdir -p $lts_loc/hpt_accuracy_different_cards"
	remote_run_command $HPTMachine "mv /root/jcw78/nvme/hpt_accuracy_different_cards_run_* $lts_loc/hpt_accuracy_different_cards"
fi

if [[ *-hpt-dag* == "${test_lists[@]}" ]]; then
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

		if (( run % 10 = 0 )); then
			remote_run_command $HPTMachine "cd /root/jcw78/nvme; parallel bzip2 hpt_accuracy_vs_dag_run_{} ::: $(seq $((run - 9)) $run)"
			remote_run_command $DAGMachine "cd /root/jcw78/nvme; parallel bzip2 hpt_accuracy_vs_dag_run_{} ::: $(seq $((run - 9)) $run)"
		fi
	done

	# Move all those to the LTS device.
	remote_run_command $HPTMachine "mkdir -p $lts_loc/hpt_accuracy_vs_dag"
	remote_run_command $HPTMachine "mv /root/jcw78/nvme/hpt_accuracy_vs_dag_run_* $lts_loc/hpt_accuracy_vs_dag"

	# Move all those to the LTS device.
	remote_run_command $DAGMachine "mkdir -p $lts_loc/hpt_accuracy_vs_dag"
	remote_run_command $DAGMachine "mv /root/jcw78/nvme/hpt_accuracy_vs_dag_run_* $lts_loc/hpt_accuracy_vs_dag"
fi

echo "All done!"
