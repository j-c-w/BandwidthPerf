This directory contains all the scripts used for the analysis of bandwidth.

To use:
1. Put this project in /root/jcw78/scripts
2. Go to setup
3. Run ./setup\_machine.sh (Do this even if you expanded this from a tar archive)
4. If this is a capture machine with an ExaNIC HPT, run ./setup\_exanic\_machine.sh
5. If this machine uses a 10G solarflare NIC and needs a driver update, run ./install\_sf\_drivers.sh
6. After setup\_machine.sh is finished, the following folders will be in /root/jcw78:
	- process\_pcap\_traces: start here to process expcap traces.
	- SUMMER2017: The benchmarking infrastructure this project is built on top of.  If you want to add new benchmarks, start here and go to SUMMER2017/apps/benchmark
	- pcap\_files: a set of generated pcap files for use during testing.
	- NRG-dev: APIs for the NRG.
	- NetFPGA-SUME-live + OSTN-SUME-line: 

After that is done, 
	- setup/: This contains scripts to set up machines.  Some scripts may need modification for your system: those are explained clearly in the README there.  Start here, or do steps 1-5 above to setup your  machines.
	- apps: This contains scripts used to run and capture from the benchmark suite.  If you are looking to run a capture, start here.
	- evaluation: This contains scripted tests to analyze the correctness, accuracy and precision of a capture setup.  If you are looking to analyze an experimental setup, start here.
	- hpt\_setup:  This contains Exablaze capture software and drivers.
	If you are looking to create a bespoke analysis of 
	Expcap traces, start here (If you are looking to repeat
	an existing analysis, start in process\_pcap\_traces -- see above).
	- bitfiles: This contains bitfiles for OSNT and the NRG.
	- dag: This contains scripts to start and stop the Endace DAG
	recording.
	- hpt: Contains scripts to start and stop the HPT recodring and manage clock synchronization.
	- nrg: Scripts to set rate and delay.
	- general:  This contains bash libraries loaded by other scripts.
	- HPT\_test/: This contains scripts used to test the HPT card.
	Some scripts may need to be run after every reboot.
	- 

#Configuration
Every directory has a `config` file and a `README`. You should start at the README, then edit the config file as appropriate.
