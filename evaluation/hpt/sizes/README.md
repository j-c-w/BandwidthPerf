This tests whether the HPT card responds differently to
packets of different sizes.

To set this experiment up, connect port 0 of a NetFPGA on
machine A to port 0 of the exanic on machine B.

Edit the config files:
	config
	size_scan/config

Run 'run.sh'.  Results can be plotted with plot.sh
