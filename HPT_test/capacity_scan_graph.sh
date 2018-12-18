#!/bin/zsh

set -ue
cat <<EOF
This draws a graph containing the loss rates for various
packet sizes at various rates.
EOF

echo "Usage: $0 [ optionally only plot these sizes ]"

source ../general/parse_config.sh
source ../general/remote_run.sh

# Get the permanent storage location.
storage_loc=$(get_config_value "HPTPermanentStorageLocation")
hpt_machine=$(get_config_value "HPTMachine")

if [[ "$#" -eq 0 ]]; then
	# First, get all the local files:
	remote_run $hpt_machine local_capacity_scan_graph_get_files.sh $storage_loc

	#  Now, the output files should be 
	echo "Drawing graph for files:" $(cat .ssh_output)

	cat .ssh_output
	typeset -a args
	for arg in $(cat .ssh_output); do
		args+="$arg"
	done
	echo "args are ${args[@]}"
	# Now draw the sizes:
	./remote_run_python.sh capacity_scan_graph.py ${args[@]}
else
	# In this case, we already know the file names, so we don't
	# have to get them.  Just run the python script with the
	# right arguments.
	typeset -a prefixed_args
	
	for arg in $@; do
	prefixed_args+="$storage_loc/${arg}B"
	done
	echo "Prefixed args ${prefixed_args[@]}"
	./remote_run_python.sh capacity_scan_graph.py "${prefixed_args[@]}"
fi
