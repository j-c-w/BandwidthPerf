#!/bin/bash

mkdir -p /root/jcw78
pushd /root/jcw78/
git clone https://github.com/NetFPGA/NRG-dev
pushd NRG-dev
git checkout 1b07d3f516fd2349fd367b7123a6f117273d92cf
