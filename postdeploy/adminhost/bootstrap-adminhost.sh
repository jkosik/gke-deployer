#!/bin/bash

# Bootstrap adminhost

set -x
set -e

# Install base packages
sudo apt update -y
sudo apt install -y \
    dnsutils \
    curl \
    jq \
    wget

# Install kubectl (gcloud installed by default)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
mkdir -p ~/.local/bin/kubectl || true
mv ./kubectl ~/.local/bin/kubectl

# Configure kubectl command completition
sudo apt install bash-completion -y
source /usr/share/bash-completion/bash_completion
echo 'source <(kubectl completion bash)' >>~/.bashrc

#gcloud secrets versions access 1 --secret="kubeconfig-$DSO_PROJECT" > ~/.kube/config