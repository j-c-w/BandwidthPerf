#!/bin/bash

sudo apt install nfs-common
mkdir -p /root/jcw78/lts
sudo mount -o soft,intr archive.cl.cam.ac.uk:/export/jcw78 /root/jcw78/lts
