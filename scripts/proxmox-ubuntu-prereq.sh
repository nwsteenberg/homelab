#!/usr/bin/env bash

# This script is intented to be executed as the first thing on a new proxmox Ubuntu 24.04 VM
# It contains any prerequisites that are needed prior to usage

# install qemu-guest-agent
apt-get install -y qemu-guest-agent

# reboot the VM
reboot
