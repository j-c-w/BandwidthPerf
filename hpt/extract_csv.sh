#!/bin/zsh

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <input file> <output file>"
    exit 1
fi

# -n 2000 is the number of bytes to extract per packet.
/root/jcw78/scripts/hpt_setup/exanic-exact/exact-capture-1.0RC/bin/exact-pcap-parse -i "$1" -c "$2" -f expcap -n 2000
echo  "Extracting CSV done"
