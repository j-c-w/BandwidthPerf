This tests the rate-limiting-ness of the NRG.  In this test,
we run iperf between two machines in TCP mode.  We run this
at various rates less than 3Gbps (as determined in the other
rate tests).

We attempt to get some idea of the accuracy of the NRG in limiting
the bandwidth.

To set this up, connect NICA on MachineA into the NetFGPA (used fo the NRG) on MachineB. 

If you intend  to capture (not required: more complete information, but much slower):
	That NetFPGA should be connected to an optical splitter.
	One end of the optical splitter should go into port 0 of an HPT card on MachineC.  The other end of the optical splitter should go into NICD on MachineD

Otherwise:
	That NetFPGA should be connected to NICD on MachineD.
	Make sure that "Record: False " in the config file.

Edit the config files:
	../config
	config

As required.
