#!/usr/bin/env bash

# This script is intented to be executed as the first thing on a new proxmox Ubuntu 24.04 VM
# It contains any prerequisites that are needed prior to usage

# update the package list
apt update

# install qemu-guest-agent
apt install -y qemu-guest-agent yq

# install the latest kernel
apt dist-upgrade

# reboot the VM
reboot
