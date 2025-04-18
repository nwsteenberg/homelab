#!/usr/bin/env bash

# This is a script to install the prerequisites for Kubernetes on Ubuntu 24.04 using kubeadm

# Static IP configuration
vm_ip=$(hostname -I)
vm_nameserver=$(yq '.network.deco_mesh.nameserver' env.yaml)
vm_gateway=$(yq '.network.deco_mesh.gateway' env.yaml)
# Create backup of the original netplan config
cp /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.bak
cat >/etc/netplan/50-cloud-init.yaml <<EOL
network:
  version: 2
  ethernets:
    eth0:
      addresses: [${vm_ip}/24]
      nameservers:
        addresses: [${vm_nameserver}]
      routes:
        - to: default
          via: ${vm_gateway}
EOL

apt update
apt install -y containerd apt-transport-https ca-certificates curl gnupg

mkdir /etc/containerd
containerd config default | tee /etc/containerd/config.toml
# Enable systemd cgroup driver and ipv4 forwarding
sed 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml
sed 's/#net.ipv4.ip_forward=1/net.ipv4.ipforward=1/g' -i /etc/sysctl.conf
echo "br_netfilter" >> /etc/modules-load.d/k8s.conf

# Setup Kubernetes keyring (from https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management)
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring

apt update
apt install kubectl kubeadm kubelet

reboot
