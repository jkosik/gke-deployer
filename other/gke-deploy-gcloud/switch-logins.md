# gcloud user profiles (See ls ~/.config/gcloud/configurations/)
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
juraj@xps ~ $ gcloud auth activate-service-account --key-file=/home/juraj/creds-sa-owner-workload-318005.json 

```

# In case of overwritten user in the active gcloud profile, just pick the right one from ~/.config/gcloud/credentials.db
#gcloud config set account juraj.kosik@gmail.com
#gcloud config set project dso-main

# source gke.vars, grab auth secret and activate it with active gcloud configuration
source gke.vars
gcloud secrets versions access 1 --secret="sa-owner" > /home/juraj/creds-sa-owner-$DSO_PROJECT.json
gcloud auth activate-service-account --key-file=/home/juraj/creds-sa-owner-$DSO_PROJECT.json --project=$DSO_PROJECT

# Create Service Account and generate JSON Key
```
gcloud iam service-accounts create sa-owner --description="sa-owner" --display-name="sa-owner"
gcloud projects add-iam-policy-binding $DSO_PROJECT --member=serviceAccount:sa-owner@$DSO_PROJECT.iam.gserviceaccount.com --role=roles/owner
gcloud iam service-accounts keys create creds-sa-owner-$DSO_PROJECT.json --iam-account=sa-owner@$DSO_PROJECT.iam.gserviceaccount.com
gcloud secrets create sa-owner --data-file=creds-sa-owner-$DSO_PROJECT.json --labels=dso_owner=juraj,dso_project=$DSO_PROJECT
```

