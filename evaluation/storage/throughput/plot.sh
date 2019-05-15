#!/bin/zsh

source /root/jcw78/scripts/general/parse_config.sh

runs=$(get_config_value Runs)
folders=($(get_config_value Folders))
names=($(get_config_value Names))

typeset -a flags
for name in $names; do
	flags+='--input'
	flags+="$name"
	flags+="${name}_out"
done
python plot.py ${flags[@]}
