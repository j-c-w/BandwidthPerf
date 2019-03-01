#!/bin/zsh

set -eu

typeset -a no_clean
zparseopts -D -E -no-clean=no_clean

if [[ $# -ne 3 ]]; then
	echo "Usage $0 <run no> <lts loc> <decompression location>"
	exit 1
fi
run=$1

# Move the compressed file to the decompression location
cp $2/hpt_accuracy_different_cards_card_0/hpt_accuracy_different_cards_card_0_run_$run/10000_joint_timing_card_0-0.expcap.bz2 $3/different_cards_run_${run}_card_0.expcap.bz2
cp $2/hpt_accuracy_different_cards_card_1/hpt_accuracy_different_cards_card_1_run_$run/10000_joint_timing_card_1-0.expcap.bz2 $3/different_cards_run_${run}_card_1.expcap.bz2
echo "Done copying!"


# Now decompress both:
bzip2 -d $3/different_cards_run_${run}_card_0.expcap.bz2 &
bzip2 -d $3/different_cards_run_${run}_card_1.expcap.bz2 &
wait
echo "Done decompressing!"

# Now convert those to pcap:
/root/jcw78/scripts/general/expcap_to_csv.sh $3/different_cards_run_${run}_card_0.expcap $3/different_cards_run_${run}_card_0.csv &
/root/jcw78/scripts/general/expcap_to_csv.sh $3/different_cards_run_${run}_card_1.expcap $3/different_cards_run_${run}_card_1.csv &
wait
echo "Converted to PCAP!"

# Now run the plotter:
pushd /root/jcw78/process_pcap_traces/
python arrival_time_difference_plot.py "$3/different_cards_run_${run}_card_0.csv" "$3/different_cards_run_${run}_card_1.csv"
# Move the produced graph:
mkdir -p $2/graphs/dual_hpt_timestamp_differences
mv different_cards_run_${run}_card_0.csv_diff_different_cards_run_${run}_card_1.csv.eps $2/graphs/dual_hpt_timestamp_differences/${run}.eps
popd
echo "Done... Cleaning up!"

# Delete the extracted expcap files:
if [[ ${#no_clean} == 0 ]]; then
	rm -f $3/different_cards_run_${run}_card_0.pcap
	rm -f $3/different_cards_run_${run}_card_1.pcap
	rm -f $3/different_cards_run_${run}_card_0.csv
	rm -f $3/different_cards_run_${run}_card_1.csv
	rm -f $3/different_cards_run_${run}_card_0.expcap.bz
	rm -f $3/different_cards_run_${run}_card_1.expcap.bz
	rm -f $3/different_cards_run_${run}_card_0.expcap
	rm -f $3/different_cards_run_${run}_card_1.expcap
fi
echo "Done!"
