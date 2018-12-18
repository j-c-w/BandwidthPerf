#!/bin/bash

set -eu
if [[ "$#" -ne 1 ]]; then
	echo "Usage: $0 <permanenet storage loc>"
	exit 1
fi

# This script should silently list the full names or all the locations corresponding to bandwidth tests.
cd $1
find $(pwd) -maxdepth 1 -name '*B'
