#!/bin/bash

# This is a script that generates a config for N machines
# taken from the machines file.

if [[ $# -ne 1 ]]; then
	echo "Usage $0 <number of machines in config>"
	exit 1
fi

mach_no=0
role=master
config_file=/root/jcw78/SUMMER2017/apps/benchmark/config
total=$1
machines=($(cat < machines))

if (( total > ${#machines} )); then
	echo "You can't use more machines than defined.  Put more machines into the 'machines' file"
	exit 1
fi

master_apps=( pmls-master apache-server dns-server iperf-server hadoop-master memcached-server memcached-agent monitor-master mysql-server mysql-slave spark-master tcpdump-master tensorflow-master )
slave_apps=( pmls-slave apache-client dns-client iperf-client hadoop-slave memcached-client mysql-client ptpd-slave spark-slave tcpdump-slave tensorflow-slave )

echo "# Formate is: <management  interface for the machine in question> <interface over which tests will be run> <benchmark>-<role>" > $config_file

while (( mach_no < total )); do
	test_interface="192.168.0.$((mach_no + 7))"
	management_interface=$(nslookup ${machines[$mach_no]} | tail -n 3 | awk -F':' '/Address: / {print $2 }' | tr -d ' ')
	if [[ $role == master ]]; then
		for master_app in ${master_apps[@]}; do
			echo "$management_interface $test_interface $master_app" >> $config_file
		done
		role=slave
	else 
		for slave_app in ${slave_apps[@]}; do
			echo "$management_interface $test_interface $slave_app" >> $config_file
		done
	fi
	mach_no=$(( mach_no + 1 ))
done
