This is a directory of libraries used by other scripts in this project. 

If you are writing your own scripts for this project, you should know about these.

Libraries:
	Usage: source <full library path>

	- parse_config.sh: this provides calls most importantly get_config_value name config_file that reads data from config file.
	Config files are of the format key: value, where value
	cannot contain ':'.  Comments start with #.

	- paste_wrapper: This is a wrapper around the GNU paste tool.

	- remote_run.sh: This provides three remote run commands:
		- remote_run <remote hostname> <script location on local machine> args...
		- remote_run_script <remote hostname> <script location on remote machine (relative to /root/jcw78/)> <args>
		- remote_run_command <remote hostname> "command + args"
	- remote_scp.sh: This provides the remote_scp function, which is used as: remote_scp <host> <source file> <dest file>

Tools (executed as normal bash programs):

	- remote_exists.sh: This checks whether a remote file exists.
	- enable_intel_nic.sh: This enables unkown SFPs on Intel
	NICs.
	- expcap_to_csv.sh: This converts an expcap file to a CSV file.
	- expcap_to_pcap.sh: This converts an expcap file to  a pcap file.  Note the loss of resolution.

