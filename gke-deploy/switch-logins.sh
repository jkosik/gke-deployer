#!/bin/bash

# See ls ~/.config/gcloud/configurations/
gcloud config configurations activate default

# In case of overwritten user in current profile, just pick the right one from ~/.config/gcloud/credentials.db
#gcloud config set account juraj.kosik@gmail.com

# source gke.vars, grab auth secret and activate it with active gcloud configuration
source gke.vars
gcloud secrets versions access 1 --secret="sa-owner" > /home/juraj/creds-sa-owner-$DSO_PROJECT.json
gcloud auth activate-service-account --key-file=/home/juraj/creds-sa-owner-$DSO_PROJECT.json --project=$DSO_PROJECT