#!/usr/bin/zsh

set -eu

cat <<EOF
This is a script that sets up the software to record
on the machines.  It will use the machines specified
in the config file.
EOF

source ../general/parse_config.sh

# Get the machine names:
get_config_value 'HPTMachine' config
hpt_machine=$(get_config_value 'HPTMachine')
osnt_machine=$(get_config_value 'OSNTMachine')
vivaldo_config_location=$(get_config_value 'VivadoSetting')

# On the HPT machine, install the HPT hardware.
ssh $hpt_machine 'bash -s' < ../setup/setup_exanic_machine.sh

# Likewise, on the OSNT machine, install the ONST hardware.
ssh $osnt_machine 'bash -s' < ../setup/setup_osnt_machine.sh
ssh $osnt_machine 'bash -s' < ../setup/init_osnt.sh  $vivaldo_config_location

# Now, touch a file to indicate this was completed.
touch .installed
