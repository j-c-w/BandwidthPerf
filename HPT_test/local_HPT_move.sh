#!/bin/echo "This should not be run directly."
echo "On machine $(hostname)"
set -eu

if [[ "$#" -ne 2 ]]; then
	echo "Usage: source file, target file"
	echo "Actual usage was $@ ($#)"
	exit 1
fi

# We attempt to make the target directory if it does not
# exist.

if [[ ! -d $(dirname $2) ]]; then
	mkdir -p $(dirname $2)
fi

mv $1 $2
