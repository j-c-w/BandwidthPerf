#!/bin/bash

# This script runs the tests.
# Get zunit:

if [[ ! -x /usr/local/bin/zunit ]]; then
	git clone https://github.com/zunit-zsh/zunit
	cd ./zunit
	./build.zsh
	chmod u+x ./zunit
	cp ./zunit /usr/local/bin
fi

if [[ ! -x /usr/local/bin/revolver ]]; then
	git clone https://github.com/molovo/revolver revolver
	chmod u+x revolver/revolver
	mv revolver/revolver /usr/local/bin
fi

# Run all the local shell scripts that start with
# 'test_'.
tests=$(find -maxdepth 1 -name 'test_*')
for t in $tests; do
	./$t
done
