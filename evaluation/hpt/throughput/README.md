This test analyzes the packet capture facilities of the HPT card at higher throughputs.

#Setup
Connect a NetFPGA on Machine A to an optical tap.  Connect the outputs of the optical tap to the HPT card on Machine B.  (i.e. both ports of the HPT card should be connected to the optical tap).
Make sure that Machine A has vivado and XMD installed.

Edit the config file with the appropriate hostnames/IPs
for machine A and B.

Make sure that the local disk on machine B has enough space to store the traces (compressed).  If not, mount a long term storage disk in /root/jcw78/lts.  That is where all PCAP files will be left.

Then, execute ./run.sh
