This experiment tests the accuracy of two different HPT cards.

The setup is as follows.

MachineA should be running a NetFGPA.  Port 0 of the NetFPGA should be
connected to an optical tap.

The first output of the optical tap should be connected to an HPT
card on MachineB.

The second output of the optical tap should be connected to
an HPT card on OtherHPTMachine.

The two HPT cards should be connected using a coax cable into their
PPS ports.
