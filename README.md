# gke-deployer
This projects assumes existing GCP projects with few prerequisites.
Deploys GKE to GCP and postdeploys [Jumphost](docs/jh.md) with tooling as kubectl, Helm, [ArgoCD](docs/argocd.md).
The code uses [GitHub Actions CICD](.github/workflows/gke-deploy.yaml). Alternatively follow [Azure DevOps howto](docs/azure-devops.md).

## Prerequisites
1. create GCP project, e.g. `workload-318005` with activated billing and few APIs:
```
gcloud beta billing projects link PROJECT_ID --billing-account=BILLING_ACCOUNT
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  secretmanager.googleapis.com
```
2. create GCP Service account (SA) and store SA JSON file.
3. create GCP Cloud Storage for tfstate in the Workload project
```
gsutil mb -p workload-318005 -c standard -l europe-central2 -b on gs://tfstate_PROJECT_ID_gke-deployer
```
4. create GitHub Actions Secret `GCP_SA`. Remove new lines before importing JSON file to the GitHub UI.
```
jq -c . GCP_SA.json
```
5. create GitHub Actions Secret `GCP_SSH_PRIVATE_KEY` for Jumphost access. GitHub actions support multiline variables. Not the case of Azure DevOps. Anyhow consider storing multiline variables as base64 and decode when using in the pipeline.

## Running CICD and git branch management
Branches are organized as `dev/stage/prod`. Branch name is passed to `INFRA_ENV` variable within CICD workflow. Based on `INFRA_ENV` variable Terraform decides which *.tfvars file to use. Ansible utilizes the same variable as well.

## Deploying applications to K8S cluster
Applications can be deployed in multiple ways:
- using Jumphost with preinstalled kubectl (user can install additional tools as Helm)
- using [ArgoCD](docs/argocd.md)

## Additional info
#### Master-Workload architecture
In production, consider building Master GCP Project to create and manage Workload GCP Projects e2e. Normally Master GCP Project would contain SA for running Terraform provisioning of the Workload GCP Projects and resources within. Free Tier does not allow to use SA for creating another GCP Projects, thus we precreate Workload GCP Project and Workload SA in advance manually.**

#### GKE Deployment using gcloud
Instead of Terraform you can use `gcloud` powered deployment pipeline. Update `other/gke-deploy-gcloud/gke.vars` and run [gke-deploy-gcloud/deployment-local.sh](other/gke-deploy-gcloud/deployment-local.sh) to build GKE from the console. Optionally use [GitHub Actions](other/gke-deploy-gcloud/.github/workflows/gke-deploy-gcloud.yaml).

#### GCP side notes
- When creating GKE, use `--region` fior HA cluster. Otherwise build just zonal GKE cluster instead of `--zone`).
- Authenticate Terraform or gcloud using `export GOOGLE_CREDENTIALS=GCP_SA.json`

#### Dynamic inventory
For more complex usecases use dynamic inventory for GCP and parse output if needed:
```
ansible-galaxy collection install google.cloud
ansible-inventory -i inventory-dynamic-gcp.yaml --list
ansible -i inventory-dynamic-gcp.yaml all -m ping
```

#### TODO
- Terraform import updates only state file. Add configuration block to TF, otherwise be ready to delete on apply.

