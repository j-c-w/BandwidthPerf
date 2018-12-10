#!/bin/bash

mkdir -p ~/jcw78

pushd ~/jcw78
if [[ ! -d exanic-software ]]; then
	git clone https://github.com/exablaze-oss/exanic-software
fi

# Regardless, check out the 'right' version and build it all.
pushd exanic-software
git checkout c2aff3c0d120d4cf278b32c1c0b37b45904cb788
make
popd
