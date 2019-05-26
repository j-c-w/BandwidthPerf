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

	for delay in $(cat < delays); do
		for run in $(seq 1 $runs); do
			# Move that data over into the temp storage directory.
			(
			undelayed_fn=${delay}_run_${run}-0.expcap.bz2
			delayed_fn=${delay}_run_${run}_delayed-0.expcap.bz2
			undelayed=$lts_location/nrg_delay/pcaps/$undelayed_fn
			delayed=$lts_location/nrg_delay/pcaps/$delayed_fn

			set -x
			cp $undelayed $tmp_location
			cp $delayed $tmp_location

			# Now extract those.
			bunzip2 $tmp_location/$undelayed_fn -f
			bunzip2 $tmp_location/$delayed_fn -f

			unzipped_undelayed_fn=${undelayed_fn/.bz2/}
			unzipped_delayed_fn=${delayed_fn/.bz2/}

			/root/jcw78/scripts/hpt/extract_csv.sh $tmp_location/$unzipped_undelayed_fn $tmp_location/$undelayed_fn.csv
			/root/jcw78/scripts/hpt/extract_csv.sh $tmp_location/$unzipped_delayed_fn $tmp_location/$delayed_fn.csv

			# Once we have those extracted, work out all the packet
			# time diffs using the python script.
			python ./extract_latency_differences.py $tmp_location/$undelayed_fn.csv $tmp_location/$delayed_fn.csv $lts_location/nrg_delay/pcaps/${delay}_latency_differences_run_${run}.dat 

			# Finally, clean up.
			rm -f $tmp_location/$undelayed_fn
			rm -f $tmp_location/$delayed_fn
			rm -f $tmp_location/$unzipped_undelayed_fn
			rm -f $tmp_location/$unzipped_delayed_fn
			rm -f $tmp_location/$undelayed_fn.csv
			rm -f $tmp_location/$delayed_fn.csv
			) &
		done
		wait
	done
fi

# Now that all of those are extracted, plot the actual graph.
python plot_latency_differences.py $lts_location/nrg_delay/pcaps --group 100 1000
