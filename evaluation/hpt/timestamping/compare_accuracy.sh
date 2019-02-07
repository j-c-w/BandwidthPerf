#!/bin/zsh

set -eu

# This script goes through and extracts the mean inter-arrival
# times of the accuracy scripts.  It:
# 	Copies and unzips every file in the passed folder.
# 	Goes through and determines the mean inter-arrival times
# 	of those files.
# 	Stores the results of this in a results file.

if [[ $# -ne 1 ]]; then
	echo "Usage: $0 <accuracy folder>"
	exit 1
fi

source /root/jcw78/scripts/general/parse_config.sh

results_file="$1/statistics"
tmp_dir=$(get_config_value "WorkDirectory")

expcap_files=$(find -wholename "$1/*/*.expcap")
pcap_files=$(find -wholename "$1/*/*.pcap")
bz_files=$(find -wholename "$1/*/*.expcap.bz2")
parallel -j 10 /root/jcw78/scripts/evaluation/hpt/timestamping/compare_accuracy_single_file.sh {} $tmp_dir ::: $expcap_files $pcap_files $bz_files

# Now collate all of those:
stats_files=$(find -wholename="$tmp_dir/*.statistics")
echo "" -n > tmp_results_file
for file in $(sort $stats_files); do
	# We add the basename of the file to the data.
	key=$(basename $file)
	echo "$key: $(cat $file)" >> tmp_results_file
done

mv tmp_results_file $results_file
