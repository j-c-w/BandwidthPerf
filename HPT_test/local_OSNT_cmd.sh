#!/bin/bash

set -eu
echo "On machine $(hostname)"
# This should only ever be used over SSH.
pushd ~/jcw78/OSNT-SUME-live/projects/osnt/sw/host/app/cli/
python osnt-tool-cmd.py "$@"
popd
