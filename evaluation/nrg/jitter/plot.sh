#!/bin/zsh

set -eu
source /root/jcw78/scripts/general/parse_config.sh
runs=$(get_config_value "Runs")
lts_location=$(get_config_value "LTSLocation")
tmp_location=$(get_config_value "TempStorageLocation")

zparseopts -D -E -no-extract=no_extract
if [[ $# -ne 0 ]]; then
	echo "Usage $0 [Flags]"
	echo "Pass --no-extract to skip extracting the expcap files into "
	echo "a summary data file."
	exit 1
fi

if [[ ${#no_extract} == 0 ]]; then
	echo "Extracting all the data.  Pass --no-extract to skip."
	sleep 2

	mkdir -p $tmp_location
	# Clear any cache files in the tmp location because those wouldn't be overwritten.
	rm $tmp_location/*.cache

	for jitter in $(cat < jitter); do
		for run in $(seq 1 $runs); do
			# Move that data over into the temp storage directory.
			(
			unjittered_fn=${jitter}_run_${run}-0.expcap.bz2
			jittered_fn=${jitter}_run_${run}_jitter-0.expcap.bz2
			unjittered=$lts_location/nrg_jitter/pcaps/$unjittered_fn
			jittered=$lts_location/nrg_jitter/pcaps/$jittered_fn

			set -x
			cp $unjittered $tmp_location
			cp $jittered $tmp_location

			# Now extract those.
			bunzip2 $tmp_location/$unjittered_fn -f
			bunzip2 $tmp_location/$jittered_fn -f

			unzipped_unjittered_fn=${unjittered_fn/.bz2/}
			unzipped_jittered_fn=${jittered_fn/.bz2/}

			/root/jcw78/scripts/hpt/extract_csv.sh $tmp_location/$unzipped_unjittered_fn $tmp_location/$unjittered_fn.csv
			/root/jcw78/scripts/hpt/extract_csv.sh $tmp_location/$unzipped_jittered_fn $tmp_location/$jittered_fn.csv

			# Once we have those extracted, work out all the packet
			# time diffs using the python script.
			python ./extract_latency_differences.py $tmp_location/$unjittered_fn.csv $tmp_location/$jittered_fn.csv $lts_location/nrg_jitter/pcaps/${jitter}_latency_differences_run_${run}.dat 

			# Finally, clean up.
			set -x
			rm -f $tmp_location/$unjittered_fn
			rm -f $tmp_location/$jittered_fn
			rm -f $tmp_location/$unzipped_unjittered_fn
			rm -f $tmp_location/$unzipped_jittered_fn
			rm -f $tmp_location/$unjittered_fn.csv
			rm -f $tmp_location/$jittered_fn.csv
			) &
		done
		wait
	done
fi

# Now that all of those are extracted, plot the actual graph.
python plot_latency_differences.py $lts_location/nrg_jitter/pcaps
