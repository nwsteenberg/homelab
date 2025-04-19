#!/usr/bin/env bash

# This script is intented to be executed as the first thing on a new proxmox Ubuntu 24.04 VM
# It contains any prerequisites that are needed prior to usage

# update the package list
apt update

# install qemu-guest-agent
apt install -y qemu-guest-agent

# install yq
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq

# install the latest kernel
apt dist-upgrade

# reboot the VM
reboot
