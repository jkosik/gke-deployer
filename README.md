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
4. create GitHub Actions Secret for GCP_SA. Remove new lines before importing JSON file to the GitHub UI.
```
jq -c . GCP_SA.json
```
5. create GitHub Actions Secret for GCP_SSH_PRIVATE_KEY used in Jumphost (Ansible and administration).

## Running CICD and git branch management
Branches are organized as `dev/stage/prod`. Branch name is passed to `INFRA_ENV` varaible within CICD workflow. Based on that Terraform decides which *.tfvars file to use. Also Ansible
and decides variable used within Terraform as well as Ansible for parametrization.

## Deploying applications to K8S cluster
Applications can be deployed in multiple ways:
- using Jumphost with preinstalled kubectl (user can install additional tools as Helm)
- using [ArgoCD](docs/argocd.md)


## Additional info
#### Master-Workload architecture
In production, optionally build Master GCP Project to create and manage Workload GCP Projects. This project assumes target GCP project and SA exists.

**Normally Master GCP Project would contain SA for running Terraform provisioning of Workload GCP Projects and GKEs within. Free Tier does not allow to use SA for creating another GCP Projects, thus we need workarounds using personal GCP account to create Workload GCP Projects or we precreate Workload GCP Project and Workload SA in advance manually.**

#### GKE Deployment using gcloud
Instead of Terraform you can use `gcloud` powered deployment pipeline. Update `other/gke-deploy-gcloud/gke.vars` and run [gke-deploy-gcloud/deployment-local.sh](other/gke-deploy-gcloud/deployment-local.sh) to build GKE from the console. Optionally use [GitHub Actions](other/gke-deploy-gcloud/.github/workflows/gke-deploy-gcloud.yaml).

### GCP side notes
- When creating GKE, use `--region` fior HA cluster. Otherwise build just zonal GKE cluster instead of `--zone`).
- Authenticate Terraform or gcloud using `export GOOGLE_CREDENTIALS=GCP_SA.json`

#### Dynamic inventory
Normally we grab JH IP using gcloud and template inventory file `inventory-template.yaml`

For more complex usecases use dynamic inventory for GCP:
```
ansible-galaxy collection install google.cloud
ansible-inventory -i inventory-dynamic-gcp.yaml --list
ansible -i inventory-dynamic-gcp.yaml all -m ping
```
- parse output and create inventory file on the fly

