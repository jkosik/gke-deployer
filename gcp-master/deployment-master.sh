#!/bin/bash

# Prepares master GKE project using initial oauth2 personal credentials

set -x
set -e

# Vars
source ./project.vars

# Create project
echo "--- Creating project $DSO_PROJECT ---"
gcloud projects create $DSO_PROJECT --labels=dso_owner=$DSO_OWNER,dso_project=$DSO_PROJECT
gcloud config set project $DSO_PROJECT

# Enable billing and link to billing account
echo "--- Enabling billing ---"
gcloud beta billing projects link $DSO_PROJECT --billing-account=$DSO_BILLING_ACCOUNT 

# Enable needed GCP APIs for a project
echo "--- Enabling GCP APIs for the project ---"
gcloud services enable \
  anthos.googleapis.com \
  cloudresourcemanager.googleapis.com \
  compute.googleapis.com \
  container.googleapis.com \
  gkeconnect.googleapis.com \
  gkehub.googleapis.com \
  secretmanager.googleapis.com

# Set defaults
echo "--- Setting default region/zone ---"
gcloud config set compute/region $DSO_GCP_REGION
gcloud config set compute/zone $DSO_GCP_ZONE

# Create privileged SA and store to Secret Manager
echo "--- Creating SA ---"

gcloud iam service-accounts create sa-owner --description="sa-owner" --display-name="sa-owner"
gcloud projects add-iam-policy-binding $DSO_PROJECT --member=serviceAccount:sa-owner@$DSO_PROJECT.iam.gserviceaccount.com --role=roles/owner
gcloud iam service-accounts keys create creds-sa-owner-$DSO_PROJECT.json --iam-account=sa-owner@$DSO_PROJECT.iam.gserviceaccount.com

gcloud secrets create sa-owner --data-file=creds-sa-owner-$DSO_PROJECT.json --labels=dso_owner=$DSO_OWNER,dso_project=$DSO_PROJECT

# Switch to SA (use full path)
gcloud auth activate-service-account --key-file=/tmp/creds-sa-owner-$DSO_PROJECT.json --project=$DSO_PROJECT

# Create default network (adminhost, future peerings,...)
echo "--- Preparing default networking ---"
gcloud compute networks create $DSO_PROJECT-default --subnet-mode custom
gcloud compute firewall-rules create $DSO_PROJECT-default --network $DSO_PROJECT-default --allow tcp:22,udp,icmp # --source-ranges 192.168.0.0/20

# Create default subnetwork 
gcloud compute networks subnets create $DSO_PROJECT-$DSO_GCP_REGION-default \
    --network $DSO_PROJECT-default \
    --region $DSO_GCP_REGION \
    --range 192.168.0.0/20 \
    --enable-private-ip-google-access  

# Create adminhost in default subnet
echo "--- Deploying adminhost ---"
gcloud compute instances create adminhost --hostname=adminhost-$DSO_PROJECT.localhost \
  --subnet=$DSO_PROJECT-$DSO_GCP_REGION-default \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --service-account=sa-owner@$DSO_PROJECT.iam.gserviceaccount.com \
  --image-project=debian-cloud \
  --image=debian-10-buster-v20210512 \
  --machine-type=e2-small \
  --tags=adminhost

gcloud compute instances add-metadata adminhost --metadata-from-file ssh-keys=ssh-keys
gcloud compute firewall-rules create $DSO_PROJECT-adminhost --network $DSO_PROJECT-default --allow tcp:22,udp,icmp --target-tags adminhost

# Bootstrap adminhost
echo "--- Bootstrapping adminhost ---"
gcloud compute scp --ssh-key-file=$PRIVATE_SSH_KEY_PATH --recurse ../postdeploy/adminhost/ user@jh:~/jumphost
gcloud compute ssh --ssh-key-file=$PRIVATE_SSH_KEY_PATH user@adminhost -- 'cd ~/adminhost && source bootstrap-adminhost.sh'

# Create GKE network
echo "--- Preparing networking for GKE ---"
gcloud compute networks create $DSO_PROJECT --subnet-mode custom

# Create subnetwork
gcloud compute networks subnets create $DSO_PROJECT-$DSO_GCP_REGION \
    --network $DSO_PROJECT \
    --region $DSO_GCP_REGION \
    --range 192.168.16.0/20 \
    --secondary-range secondary-subnet-services=10.0.32.0/20,secondary-subnet-pods=10.4.0.0/14 \
    --enable-private-ip-google-access    

# Deploy GKE
# FW rules towards k8s nodes, master-ipv4-cidr and secondary-subnet-pods are automatically created when spawning GKE
echo "--- Deploying GKE ---"
gcloud container clusters create $DSO_GKE_CLUSTER_NAME \
    --zone $DSO_GCP_ZONE \
    --network $DSO_PROJECT \
    --subnetwork $DSO_PROJECT-$DSO_GCP_REGION \
    --cluster-secondary-range-name secondary-subnet-pods \
    --services-secondary-range-name secondary-subnet-services \
    --enable-master-authorized-networks \
    --master-authorized-networks 178.41.36.135/32 \
    --enable-ip-alias \
    --enable-private-nodes \
    --master-ipv4-cidr 172.16.0.0/28 \
    --num-nodes $DSO_GKE_NODES \
    --machine-type $DSO_GKE_MACHINE_TYPE

# Create Cloud NAT for egress communication from private GKE
echo "--- Createing Cloud NAT for private GKE ---"
gcloud compute routers create $DSO_PROJECT \
    --network $DSO_PROJECT \
    --region $DSO_GCP_REGION

gcloud compute routers nats create $DSO_PROJECT \
    --router-region $DSO_GCP_REGION \
    --router $DSO_PROJECT \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips

# Deploy jumphost. Reachable at: gcloud compute instances describe jh --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
# Jumphost has default visibility GKE API at "-master-ipv4-cidr 172.16.0.0/28"
echo "--- Deploying and configuring jumphost ---"
gcloud compute instances create jh --hostname=jumphost-$DSO_PROJECT.localhost \
  --subnet=$DSO_PROJECT-$DSO_GCP_REGION \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --service-account=sa-owner@$DSO_PROJECT.iam.gserviceaccount.com \
  --image-project=debian-cloud \
  --image=debian-10-buster-v20210512 \
  --machine-type=e2-small \
  --tags=jh

gcloud compute instances add-metadata jh --metadata-from-file ssh-keys=ssh-keys
gcloud compute firewall-rules create $DSO_PROJECT-jh --network $DSO_PROJECT --allow tcp:22,udp,icmp --target-tags jh

## Bootstrap jumphost for GKE
gcloud compute scp --ssh-key-file=$PRIVATE_SSH_KEY_PATH --recurse ../postdeploy/jumphost/ user@jh:~/jumphost
gcloud compute scp --ssh-key-file=$PRIVATE_SSH_KEY_PATH project.vars user@jh:~/jumphost/project.vars
gcloud compute ssh --ssh-key-file=$PRIVATE_SSH_KEY_PATH user@jh -- 'cd ~/jumphost && source bootstrap-jh.sh'