# gke-deployer
Deploys GKE using CICD tools - [GitHub Actions](.github/workflows/gke-deploy.yml) & Azure DevOps

## Prerequisites
- Export ENV vars
```
export DSO_PROJECT=dso-main
export DSO_OWNER=juraj
export DSO_BILLING_ACCOUNT=YOUR_BILLING_ACCOUNT_ID
cd ~/
```
- Create a root project, e.g. `dso-main`
```
gcloud projects create $DSO_PROJECT --labels=dso_owner=$DSO_OWNER
```
- Activate newly created project within your user profile
```
juraj@xps ~ $ cat ~/.config/gcloud/configurations/config_juraj
[core]
project = dso-main
account = juraj.kosik@gmail.com

[compute]
zone = europe-central2-a
region = europe-central2

juraj@xps ~ $ gcloud config configurations activate juraj
Activated [juraj].
```
- Activate billing and enable needed APIs
```
gcloud beta billing projects link $DSO_PROJECT --billing-account=$DSO_BILLING_ACCOUNT 
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  secretmanager.googleapis.com
```

- Create Service Account and generate JSON Key
```
gcloud iam service-accounts create sa-owner --description="sa-owner" --display-name="sa-owner"
gcloud projects add-iam-policy-binding $DSO_PROJECT --member=serviceAccount:sa-owner@$DSO_PROJECT.iam.gserviceaccount.com --role=roles/owner
gcloud iam service-accounts keys create creds-sa-owner-$DSO_PROJECT.json --iam-account=sa-owner@$DSO_PROJECT.iam.gserviceaccount.com
gcloud secrets create sa-owner --data-file=creds-sa-owner-$DSO_PROJECT.json --labels=dso_owner=juraj,dso_project=$DSO_PROJECT
```
- Activate newly created project within your SA profile
```
juraj@xps ~ $ cat ~/.config/gcloud/configurations/config_dso-main
[core]
project = dso-main
account = sa-main@dso-main.iam.gserviceaccount.com

[compute]
zone = europe-central2-a
region = europe-central2

juraj@xps ~ $ gcloud config configurations activate dso-main
juraj@xps ~ $ gcloud auth activate-service-account --key-file=creds-sa-owner-$DSO_PROJECT.json --project=$DSO_PROJECT
```

## GKE Deployment
Update `gke.vars` and run [gcp-master/deployment.sh](gcp-master/deployment.sh) builds GKE to the existing GCP project and postdeploys [Jumphost](docs/jh.md) with supplementary applications as [ArgoCD](docs/argocd.md), Prometheus stack, Loki, Goldpinger, optionally service mesh, etc.

## IP address scheme
IP ranges harmonization is needed for efficient peerings and overall maintenance.   
For K8S Nodes(VMs), SVCs and Pods:  
```
gcloud compute networks subnets create $DSO_PROJECT-$DSO_GCP_REGION \
...snipped..
    --range 192.168.16.0/20 \ 
    --secondary-range secondary-subnet-services=10.0.32.0/20,secondary-subnet-pods=10.4.0.0/14 
...snipped..
```
For K8S control plane:  
```
gcloud container clusters create $DSO_GKE_CLUSTER_NAME \
...snipped..
    --master-ipv4-cidr 172.16.0.0/28 #control plane
...snipped...
```

## Applications
TBD

## Open Issues
- Several workarounds implemented due to SA in Free Tier without parent not being able to create GCP Projects.
- GCP Project to GKE mapping, 1:1 vs 1:N?
- Workload Identities for GKE - introducing complexity & known limitations
- exposing GKE API to Internet
- Switching to SA account overwrites the active gcloud profile. Introduces confusion in local deployments. No problem in CICD. Fix by:
```
gcloud config set account juraj.kosik@gmail.com
gcloud config set project dso-main
gcloud config configurations list
```
