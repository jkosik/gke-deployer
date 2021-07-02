# gke-deployer
Deploys GKE to GCP and postdeploys [Jumphost](docs/jh.md) with tooling and bootstraps GKE with primarily [ArgoCD](docs/argocd.md)...

## Prerequisites
- create GCP project, e.g. `workload-318005`
- create GCP Service account (SA) and store SA JSON file.
- create GCP Cloud Storage for tfstate in the Workload project
```
gsutil mb -p workload-318005 -c standard -l europe-central2 -b on gs://tfstate_PROJECT_ID_gke-deployer
```
- create GitHub Actions Secret for GCP_SA. Remove new lines before importing JSON file to the GitHub UI.
```
jq -c . GCP_SA.json
```
- create GitHub Actions Secret for GCP_SSH_PRIVATE_KEY used in Jumphost (Ansible and adminstration).

## Running CICD and git branch management
Branches are organized as `dev/stage/prod`. Branch name is passed to `INFRA_ENV` varaible within CICD workflow. Based on that Terraform decides which *.tfvars file to use. Also Ansible
and decides variable used within Terraform as well as Ansible for parametrization.

## Additional info
#### Master-Workload architecture
In production, optionally build Master GCP Project to manage Workload GCP Projects.

**Normally Master GCP Project would contain SA for running Terraform provisioning of Workload GCP Projects and GKEs within. Free Tier does not allow to use SA for creating another GCP Projects, thus we need workarounds using personal GCP account to create Workload GCP Projects or we precreate Workload GCP Project and Workload SA in advance manually.**

- Export ENV vars
```
export DSO_PROJECT=dso-main
export DSO_OWNER=juraj
export DSO_BILLING_ACCOUNT=YOUR_BILLING_ACCOUNT_ID
cd ~/
```
- Create GCP project, e.g. `dso-main`
```
gcloud projects create $DSO_PROJECT --labels=dso_owner=$DSO_OWNER
```
- Activate newly created project within your user profile
```
$ cat ~/.config/gcloud/configurations/config_juraj
[core]
project = dso-main
account = EMAIL

[compute]
zone = europe-central2-a
region = europe-central2

$ gcloud config configurations activate juraj
Activated [juraj].
```
- Activate billing and enable needed APIs
```
gcloud beta billing projects link $DSO_PROJECT --billing-account=$DSO_BILLING_ACCOUNT
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  secretmanager.googleapis.com
```

#### GKE Deployment using gcloud
Creates minimalistic zonal GKE (for HA use regional cluster `--region` instead of `--zone`).
Update `other/gke-deploy-gcloud/gke.vars` and run [gke-deploy-gcloud/deployment-local.sh](other/gke-deploy-gcloud/deployment-local.sh) to build GKE from the console. Optionally use Workflows for [GitHub Actions](.github/workflows/gke-deploy-gcloud.yml).

#### Auth using SA for Terraform
export GOOGLE_CREDENTIALS=GCP_SA.json

#### Dynamic inventory
Normally we grab JH IP using gcloud:
```
JH_IP=$(gcloud compute instances describe jh --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
sed s/CHANGEME/$JH_IP/g inventory-template.yml > inventory-ephemeral.yml
ansible-playbook -i inventory-ephemeral.yml site.yml
```

For more complex usecases use dynamic inventory for GCP:
```
ansible-galaxy collection install google.cloud
ansible-inventory -i inventory-dynamic-gcp.yml --list
ansible -i inventory-dynamic-gcp.yml all -m ping
```
- parse output and create inventory file on the fly

## TBD
- decouple infra (GKE) and configuration (k8s bootstrapping, k8s apps...) - separate workflows? Dissect k8s app deployment (argo, prometheus and so on...)