# gke-deployer
Deploys GKE to GCP and postdeploys [Jumphost](docs/jh.md) with tooling and bootstraps GKE with primarily [ArgoCD](docs/argocd.md)...

## Prerequisites 
- create Workload GCP project, e.g. `workload-318005`
- create Workload Service account (SA)
- create GCP Cloud Storage for tfstate in the Workload project
```
gsutil mb -p workload-318005 -c standard -l europe-central2 -b on gs://tfstate_PROJECT_ID_gke-deployer
```
- store SA JSON in the CICD tool Secrets (Terraform infrastructure provisioning)
- store JH private ssh key in the CICD tool Secrets (Ansible configuration)
  
In production split Master and Workload GCP projects and manage SAs and `tfstate` files centrally. 

## Additional info
#### Master-Workload architecture
In production, build Master GCP Project to manage Workload GCP Projects.
  
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

