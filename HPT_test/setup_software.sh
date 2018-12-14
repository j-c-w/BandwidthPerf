#!/usr/bin/zsh

set -eu

cat <<EOF
This is a script that sets up the software to record
on the machines.  It will use the machines specified
in the config file.
EOF

typeset -a no_ramdisk
zparseopts -D -E -no-ramdisk=no_ramdisk

source ../general/parse_config.sh
source ../general/remote_run.sh

# Get the machine names:
get_config_value 'HPTMachine' config
hpt_machine=$(get_config_value 'HPTMachine')
osnt_machine=$(get_config_value 'OSNTMachine')
vivaldo_config_location=$(get_config_value 'VivadoSetting')
hpt_temp_storage_loc=$(get_config_value 'HPTTempStorageLocation')
max_line_size=$(get_config_value 'MaxLineSize')

# On the HPT machine, install the HPT hardware.
remote_run $hpt_machine ../setup/setup_exanic_machine.sh
# Also, add a RAMDisk, 64gigs.
if [[ ${#no_ramdisk[@]} -eq 0 ]]; then
	remote_run $hpt_machine ../setup/setup_ramdisk.sh $hpt_temp_storage_loc 64g || (echo "Use --no-ramdisk to skip ramdisk"; exit 1)
else
	echo "Requested no RAMDISK, skipping"
fi

# Likewise, on the OSNT machine, install the ONST hardware.
remote_run $osnt_machine ../setup/setup_osnt_machine.sh
ssh $osnt_machine 'bash -s' < ../setup/init_osnt.sh  $vivaldo_config_location

# Get all the PCAP files we might need onto the OSNT machine.
../setup/setup_pcap_files.sh $osnt_machine $max_line_size

# Now, touch a file to indicate this was completed.
touch .installed
