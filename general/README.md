\This is a directory of libraries used by other scripts in this project. 

If you are writing your own scripts for this project, you should know about these.

Libraries:
	Usage: source <full library path>

	- parse\_config.sh: this provides calls most importantly get\_config\_value name config\_file that reads data from config file.
	Config files are of the format key: value, where value
	cannot contain ':'.  Comments start with #.

	- paste\_wrapper: This is a wrapper around the GNU paste tool.

	- remote\_run.sh: This provides three remote run commands:
		- remote\_run <remote hostname> <script location on local machine> args...
		- remote\_run\_script <remote hostname> <script location on remote machine (relative to /root/jcw78/)> <args>
		- remote\_run\_command <remote hostname> "command + args"
	- remote\_scp.sh: This provides the remote\_scp function, which is used as: remote\_scp <host> <source file> <dest file>

Tools (executed as normal bash programs):

	- remote\_exists.sh: This checks whether a remote file exists.
	- enable\_intel\_nic.sh: This enables unkown SFPs on Intel
	NICs.
	- expcap\_to\_csv.sh: This converts an expcap file to a CSV file.
	- expcap\_to\_pcap.sh: This converts an expcap file to  a pcap file.  Note the loss of resolution.

