#!/bin/bash

# Prepares GKE project using initial oauth2 personal credentials

set -x
set -e

### Commented since 
### - vars are sourced directly in GitHub Actions workflow
### - project and SA is created manually due to limitation of SA in the Free Tier. See deployment.sh comments.

cd $GITHUB_WORKSPACE/gke-deploy

# Vars
# source ./gke.vars 

# gcloud config configurations activate juraj
# gcloud projects create workload-318005 --labels=dso_owner=$DSO_OWNER
# gcloud config set project workload-318005

# gcloud beta billing projects link $DSO_PROJECT --billing-account=$DSO_BILLING_ACCOUNT 

# gcloud services enable \
#   anthos.googleapis.com \
#   cloudresourcemanager.googleapis.com \
#   compute.googleapis.com \
#   container.googleapis.com \
#   gkeconnect.googleapis.com \
#   gkehub.googleapis.com \
#   secretmanager.googleapis.com

# gcloud iam service-accounts create sa-owner --description="sa-owner" --display-name="sa-owner"
# gcloud projects add-iam-policy-binding $DSO_PROJECT --member=serviceAccount:sa-owner@$DSO_PROJECT.iam.gserviceaccount.com --role=roles/owner
# gcloud iam service-accounts keys create creds-sa-owner-$DSO_PROJECT.json --iam-account=sa-owner@$DSO_PROJECT.iam.gserviceaccount.com

# gcloud secrets create sa-owner --data-file=creds-sa-owner-$DSO_PROJECT.json --labels=dso_owner=$DSO_OWNER,dso_project=$DSO_PROJECT

# Switch to SA (use full path). Overrides currently used gcloud profile. Ok for CI environment.
# gcloud auth activate-service-account --key-file=creds-sa-owner-$DSO_PROJECT.json --project=$DSO_PROJECT

### Same steps follow as in deployment.yaml

# Set defaults
echo "--- Setting default region/zone ---"
gcloud config set compute/region $DSO_GCP_REGION
gcloud config set compute/zone $DSO_GCP_ZONE

# # Create GKE network
# echo "--- Preparing networking for GKE ---"
# gcloud compute networks create $DSO_PROJECT --subnet-mode custom

# # Create GKE subnetwork
# gcloud compute networks subnets create $DSO_PROJECT-$DSO_GCP_REGION \
#     --network $DSO_PROJECT \
#     --region $DSO_GCP_REGION \
#     --range 192.168.16.0/20 \
#     --secondary-range secondary-subnet-services=10.0.32.0/20,secondary-subnet-pods=10.4.0.0/14 \
#     --enable-private-ip-google-access    

# # Deploy GKE
# # step autocreates: 
# #   - FW rules towards k8s control plane(master-ipv4-cidr) and k8s Pods(secondary-subnet-pods)
# #   - appends context to the current kubeconfig
# echo "--- Deploying GKE ---"
# gcloud container clusters create $DSO_GKE_CLUSTER_NAME \
#     --zone $DSO_GCP_ZONE \
#     --network $DSO_PROJECT \
#     --subnetwork $DSO_PROJECT-$DSO_GCP_REGION \
#     --cluster-secondary-range-name secondary-subnet-pods \
#     --services-secondary-range-name secondary-subnet-services \
#     --enable-master-authorized-networks \
#     --master-authorized-networks $DSO_GKE_PUBLIC_ACCESS_FROM \
#     --enable-ip-alias \
#     --enable-private-nodes \
#     --master-ipv4-cidr 172.16.0.0/28 \
#     --num-nodes $DSO_GKE_NODES \
#     --machine-type $DSO_GKE_MACHINE_TYPE

# # Create Cloud NAT for egress communication from private GKE
# echo "--- Creating Cloud NAT for private GKE ---"
# gcloud compute routers create $DSO_PROJECT \
#     --network $DSO_PROJECT \
#     --region $DSO_GCP_REGION

# gcloud compute routers nats create $DSO_PROJECT \
#     --router-region $DSO_GCP_REGION \
#     --router $DSO_PROJECT \
#     --nat-all-subnet-ip-ranges \
#     --auto-allocate-nat-external-ips

# Deploy jumphost. Reachable at: gcloud compute instances describe jh --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
# Jumphost has default visibility to GKE API at "-master-ipv4-cidr 172.16.0.0/28"
echo "--- Deploying and configuring jumphost ---"
gcloud compute instances create jh --hostname=jumphost-$DSO_PROJECT.localhost \
  --subnet=$DSO_PROJECT-$DSO_GCP_REGION \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --service-account=sa-owner@$DSO_PROJECT.iam.gserviceaccount.com \
  --image-project=debian-cloud \
  --image=debian-10-buster-v20210512 \
  --machine-type=e2-small \
  --tags=jh

gcloud compute instances add-metadata jh --metadata-from-file ssh-keys=ssh-pubkeys
#gcloud compute firewall-rules create $DSO_PROJECT-jh --network $DSO_PROJECT --allow tcp:22,udp,icmp --target-tags jh

### Moved to GitHub Action Workflow directly and utilize SA
## Bootstrap jumphost for GKE
#gcloud compute scp --ssh-key-file=$DSO_PRIVATE_SSH_KEY_PATH --recurse ../gke-postdeploy/jumphost/ user@jh:~/jumphost
#gcloud compute scp --ssh-key-file=$DSO_PRIVATE_SSH_KEY_PATH gke.vars user@jh:~/jumphost/gke.vars
#gcloud compute ssh --ssh-key-file=$DSO_PRIVATE_SSH_KEY_PATH user@jh -- 'cd ~/jumphost && source bootstrap-jh.sh'
#gcloud compute ssh --ssh-key-file=$DSO_PRIVATE_SSH_KEY_PATH user@jh -- 'cd ~/jumphost/argocd && source argocd.sh'

