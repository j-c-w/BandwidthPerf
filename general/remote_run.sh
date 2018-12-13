#!/bin/bash


remote_run() {
	if [[ "$#" -lt 2 ]]; then
		echo "usage: runremote.sh remotehost localscript arg1 arg2 ..."
		exit 1
	fi

	host=$1
	realscript="$2"
	shift 2

	declare -a args

	count=1
	for arg in "$@"; do
	  args[$count]="$(printf '%q' "$arg")"
	  count=$((count+1))
	done

	echo "SSH'ing to $realscript"
	if [[ $# -gt 0 ]]; then
		ssh $host 'cat | bash /dev/stdin ' "${args[@]}" < "$realscript"
	else
		ssh $host 'bash -s ' < $realscript
	fi
	echo "Executing on $(hostname)"
}
