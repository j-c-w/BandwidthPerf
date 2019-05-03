#!/bin/zsh

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <input expcap file> <output pcap file>"
    exit 1
fi

/root/jcw78/scripts/hpt_setup/exanic-exact/exact-capture-1.0RC/bin/exact-pcap-extract -i "$1" -w "$2"

# The ExaNIC tool mangles the name, so undo that.
mv ${2}_0.pcap $2
