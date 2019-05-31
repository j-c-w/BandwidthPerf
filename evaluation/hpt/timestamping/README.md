This test compares the accuracy of an Endace DAG card
and an ExaNIC HPT card.  This is done by comparing the timestamps
of the two devices.

There are three tests:
	dual_hpt: this compares two HPT cards.
	Connect OSNT through an optical tap into two HPT
	cards.  Connect the PPS ports on the HPT cards
	to the same clock source.

	single_hpt: this compares two ports on a single
	HPT card.  Connect OSNT through an optical tap into
	each port of the HPT card.

	hpt_vs_dag: This test compares an Endace DAG timestamps
	to an HPT card's timestamps.  Connect OSNT through
	an optical tap into the DAG and the HPT.

To run these tests:
	1) Edit the config files:
		config
		dual_hpt/config
		single_hpt/config
		hpt_vs_dag/config
	2) Run run.sh (reconfiguring the physical hardware when  prompted)

	3) Each folder has a 'plot.sh' script that can be used to plot the results.
