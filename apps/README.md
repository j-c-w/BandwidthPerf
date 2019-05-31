This folder contains scripts to run a capture.  This should be run on a machine not involved in the capture or the benchmarking.  You should first configure the capture files:

- apps: This file contains the benchmark setups to run. Setups specify the number of machines to use, which benchmark(s) to run, and any delays and/or rate limits to program to the NRG.
- config: This file contains miscellaneous configuration information. Examples are: the directory where local results are stored on each benchmarking machine, the directory where metadata should be placed and the number of times to run each setup.
capture\_machines: This is a list of capture machines.
capture\_config My script needs to know a significant amount about the setup of each capture machine. For each capture machine specified in the capture machines configuration file, this file specifies that machine’s parameters.
- machines: This is a list of benchmarking machines. Uninstrumented machines are dynamically selected from the list to replace others if they fail. To avoid the situation where an instrumented machine fails resulting in no capturable traffic, the entire script fails if an instrumented machine does unless specifically requested otherwise.
- nrg\_machines This file contains a list of machines with NRG’s attached to them.

(Reproduced from Jackson Woodruff's dissertation: Analyzing data center applications with high resolution packet traces)

Once you have the configuration files set up, run the `run\_all.sh' script.  Captures will appear in the LTSLocation (in config).

In addition to the capture results, this produces the following:
	- ALL\_RUNS\_OUTPUT\_LOG: stores the stdout from every run.
	- BENCHMARK\_MACHINE\_FAILURES: stores stdout from failed
	runs.
	- BENCHMARK\_TIMEOUTS: records any benchmarks that took
	too long to run
	MACHINE\_FAILURES: Records any  benchmark runs
	that failed due to benchmarking failures

Before using capture files, MAKE SURE TO CHECK THAT THERE
ARE NO DROPS.  This is done by looking at the stdout from the
capture cards (included in the results directory).  If
there are drops, look at the evaluation folder to identify
the bottlenecks.

Other scripts are (you should not have to use any of these except
for debugging purposes):

	- capture\_run.sh: This is called by run\_all.sh .  It does not
	know about the NRG, but does the acutal capturing.
	- reboot\_machines.sh: This reboots all benchmark machines.
	- replacement\_sed.sh: This is used by install\_apps.sh
	to configure benchmark machines.
	- install\_apps.sh: This is used to install the benchmarks
	in /root/jcw78/SUMMER2017/apps into each of the benchmarking
	machines.
	- run.sh: (see below)
	- run\_with\_latency.sh: These scripts are no longer used.
	They were used for initial latency runs and are kept
	for reproducibility reasons in the case of bugs.
	For new traces, use `capture\_run.sh'.
