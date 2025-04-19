#!/usr/bin/env bash

mkdir -p ../bin

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
mv kubectl ../bin/kubectl
chmod +x ../bin/kubectl
