#!/bin/bash

# Bootstrap jumphost

set -x

# Install base packages
sudo apt update -y
sudo apt install -y \
    dnsutils \
    curl \
    jq \
    wget
    
# Install kubectl (gcloud installed by default for GCP VM)
echo "--- Installing kubectl ---"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
mkdir -p ~/.local/bin/kubectl
mv ./kubectl ~/.local/bin/kubectl

# Configure kubectl command completition
echo "--- Installing kubectl command completition ---"
sudo apt install bash-completion -y
source /usr/share/bash-completion/bash_completion
echo 'source <(kubectl completion bash)' >>~/.bashrc

# Generate kubeconfig and store to Secret Manager
echo "--- Generating kubeconfig for GKE ---"
source gke.vars
mkdir ~/.kube
> ~/.kube/config 

gcloud container clusters get-credentials $DSO_GKE_CLUSTER_NAME --zone $DSO_GCP_ZONE --project $DSO_PROJECT --internal-ip
cp ~/.kube/config /tmp/kubeconfig
gcloud secrets create kubeconfig-$DSO_GKE_CLUSTER_NAME --data-file=/tmp/kubeconfig --labels=dso_owner=$DSO_OWNER,dso_project=$DSO_PROJECT

#gcloud secrets versions access 1 --secret="kubeconfig-$DSO_PROJECT" > ~/.kube/config
