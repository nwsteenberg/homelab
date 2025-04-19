#!/usr/bin/env bash

export KUBECONFIG=$(pwd)/kubeconfig.yaml
export PATH=$(pwd)/bin:$PATH

# Should probably be set in .bashrc
export VISUAL=vim
export EDITOR="$VISUAL"
source <(kubectl completion bash)
alias k=kubectl
