#!/usr/bin/env bash

# This is a script to install the prerequisites for Kubernetes on Ubuntu 24.04 using kubeadm

# Static IP configuration
vm_ip=$(hostname -I | awk '{print $1}')
vm_nameserver=$(yq '.networks.deco_mesh.nameserver' env.yaml)
vm_gateway=$(yq '.networks.deco_mesh.gateway' env.yaml)
# Create backup of the original netplan config
if [ ! -f /etc/netplan/50-cloud-init.yaml.bak ]; then
  echo "Backing up existing netplan configuration..."
  cp /etc/netplan/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml.bak
fi
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
echo "br_netfilter" > /etc/modules-load.d/k8s.conf
cat >/etc/sysctl.d/local.conf <<EOL
net.ipv4.ip_forward=1
EOL

# Setup Kubernetes keyring (from https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management)
if [ ! -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg ]; then
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring
  echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
  sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly
fi

apt update
apt install -y kubectl kubeadm kubelet

reboot
