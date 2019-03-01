#!/bin/bash

set -eu

if [[ $# -ne 3 ]]; then
	echo "Usage $0 <run no> <lts loc> <decompression location>"
	exit 1
fi
run=$1

# Move the compressed file to the decompression location
cp $2/hpt_accuracy_same_card/hpt_accuracy_same_card_run_$run/3000_joint_timing_0-0.expcap.bz2 $3/same_card_run_${run}_port_0.expcap.bz2
cp $2/hpt_accuracy_same_card/hpt_accuracy_same_card_run_$run/3000_joint_timing_1-0.expcap.bz2 $3/same_card_run_${run}_port_1.expcap.bz2
echo "Done copying!"


# Now decompress both:
bzip2 -d $3/same_card_run_${run}_port_0.expcap.bz2 &
bzip2 -d $3/same_card_run_${run}_port_1.expcap.bz2 &
wait
echo "Done decompressing!"

# Now convert those to pcap:
/root/jcw78/scripts/general/expcap_to_csv.sh $3/same_card_run_${run}_port_0.expcap $3/same_card_run_${run}_port_0.csv &
/root/jcw78/scripts/general/expcap_to_csv.sh $3/same_card_run_${run}_port_1.expcap $3/same_card_run_${run}_port_1.csv &
wait
echo "Converted to PCAP!"

# Now run the plotter:
pushd /root/jcw78/process_pcap_traces/
python arrival_time_difference_plot.py "$3/same_card_run_${run}_port_0.csv" "$3/same_card_run_${run}_port_1.csv"
# Move the produced graph:
mkdir -p $2/graphs/single_hpt_timestamp_differences
mv same_card_run_${run}_port_0.csv_diff_same_card_run_${run}_port_1.csv.eps $2/graphs/single_hpt_timestamp_differences/${run}.eps
popd
echo "Done... Cleaning up!"

# Delete the extracted expcap files:
rm -f $3/same_card_run_${run}_port_0.pcap
rm -f $3/same_card_run_${run}_port_1.pcap
rm -f $3/same_card_run_${run}_port_0.csv
rm -f $3/same_card_run_${run}_port_1.csv
rm -f $3/same_card_run_${run}_port_0.expcap.bz
rm -f $3/same_card_run_${run}_port_1.expcap.bz
rm -f $3/same_card_run_${run}_port_0.expcap
rm -f $3/same_card_run_${run}_port_1.expcap
echo "Done!"
