#!/bin/bash

# Helper script to authenticate

gcloud config configurations activate default

# source respective project.vars
source project.vars

gcloud secrets versions access 1 --secret="sa-owner" > /home/juraj/creds-sa-owner-$DSO_PROJECT.json
gcloud auth activate-service-account --key-file=/home/juraj/creds-sa-owner-$DSO_PROJECT.json --project=$DSO_PROJECT