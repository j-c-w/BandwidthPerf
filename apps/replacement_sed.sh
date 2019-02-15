#!/bin/bash
set -x

if [[ $# -ne 1 ]]; then
	echo "Usage $0 <NIC>"
fi
sed -i "s/export DEFAULT_NIC='changeme'/export DEFAULT_NIC=${1}/" ~/benchmark/config-env.sh
