#!/bin/bash

set -eu

if [[ $# -ne 3 ]]; then
	echo "Usage $0 <run no> <lts loc> <decompression location>"
	exit 1
fi
run=$1

# Move the compressed file to the decompression location
cp $2/dag_hpt_accuracy_vs_dag/hpt_accuracy_vs_dag_run_$run/10000_joint_timing_dag.erf.bz2 $3/dag_card_run_${run}.erf.bz2
cp $2/hpt_accuracy_different_cards_card_1/hpt_accuracy_different_cards_card_1_run_$run/10000_joint_timing_card_1-0.expcap.bz2 $3/different_cards_run_${run}_card_1.expcap.bz2
echo "Done copying!"


# Now decompress both:
bzip2 -d $3/different_cards_run_${run}_card_0.expcap.bz2 &
bzip2 -d $3/different_cards_run_${run}_card_1.expcap.bz2 &
wait
echo "Done decompressing!"

# Now convert those to pcap:
/root/jcw78/scripts/general/expcap_to_pcap.sh $3/different_cards_run_${run}_card_0.expcap $3/different_cards_run_${run}_card_0.pcap &
/root/jcw78/scripts/general/expcap_to_pcap.sh $3/different_cards_run_${run}_card_1.expcap $3/different_cards_run_${run}_card_1.pcap &
wait
echo "Converted to PCAP!"

# Now run the plotter:
pushd /root/jcw78/process_pcap_traces/
python arrival_time_difference_plot.py "$3/different_cards_run_${run}_card_0.pcap_0.pcap" "$3/different_cards_run_${run}_card_1.pcap_0.pcap"
popd
echo "Done... Cleaning up!"

# Delete the extracted expcap files:
rm -f $3/different_cards_run_${run}_card_0.pcap
rm -f $3/different_cards_run_${run}_card_1.pcap
rm -f $3/different_cards_run_${run}_card_0.pcap_0.pcap
rm -f $3/different_cards_run_${run}_card_1.pcap_0.pcap
rm -f $3/different_cards_run_${run}_card_0.expcap.bz
rm -f $3/different_cards_run_${run}_card_1.expcap.bz
rm -f $3/different_cards_run_${run}_card_0.expcap
rm -f $3/different_cards_run_${run}_card_1.expcap
echo "Done!"
