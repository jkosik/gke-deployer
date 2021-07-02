#!/bin/bash

# Importer of the Secret to the Terraform
# Jumphost downloads GKE kubeconfig and stores it to the GCP Secret Manager. Jumphost needs kubeconfig anyhow.
# We could manage kubeconfig within TF. TF does not provide resource for getting GKE kubeconfig TF local-exec is cumbersome.

if [ $# -eq 0 ]; then
    echo "Environment not provided."
    exit 1
fi

INFRA_ENV=$1
PROJECT_ID=$(cat dev.tfvars | grep project_id | cut -d\" -f2)
PROJECT_NUMBER=$(gcloud projects list --filter="$PROJECT_ID" --format="value(PROJECT_NUMBER)")
GKE_CLUSTER_NAME=$(cat dev.tfvars | grep gke_cluster_name | cut -d\" -f2)

terraform import -var-file=$INFRA_ENV.tfvars -allow-missing-config google_secret_manager_secret.kubeconfig projects/$PROJECT_NUMBER/secrets/kubeconfig-$GKE_CLUSTER_NAME

# check resource addition to Terraform
terraform show -json | jq '.values.root_module.resources[] | .type,.name '
