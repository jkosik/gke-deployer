#!/bin/bash

# Register Client cluster
# Run as privileged SA from Master project

# Create connect-register SA and store to Secret Manager
echo "--- Creating connect-register SA ---"
gcloud iam service-accounts create sa-connect-$DSO_PROJECT --description="sa-connect-$DSO_PROJECT" --display-name="sa-connect-$DSO_PROJECT"
gcloud projects add-iam-policy-binding $DSO_PROJECT --member=serviceAccount:sa-connect-$DSO_PROJECT@$DSO_PROJECT.iam.gserviceaccount.com \
  --role=roles/gkehub.admin 
gcloud iam service-accounts keys create /tmp/creds-sa-connect-$DSO_PROJECT.json --iam-account=sa-connect-$DSO_PROJECT@$DSO_PROJECT.iam.gserviceaccount.com

gcloud secrets create sa-connect-$DSO_PROJECT --data-file=/tmp/creds-sa-connect-$DSO_PROJECT.json


# register GKE using SA (alternatively using Workload Identity)
echo "--- Registering $GKE_URI ---"
gcloud container hub memberships register $DSO_PROJECT \
   --gke-uri=$GKE_URI \
   --service-account-key-file=/home/user/creds-sa-connect-$DSO_PROJECT.json \
   --verbosity debug


gcloud container hub memberships register test --gke-uri=https://container.googleapis.com/v1/projects/dso-gke-client-1/zones/europe-central2-a/clusters/dso-gke-client-1 --service-account-key-file=connect-client1.json --verbosity debug


gcloud container hub memberships register dso-gke-client-1 \
            --context=gke_dso-gke-client-1_europe-central2-a_dso-gke-client-1 \
            --service-account-key-file=~/creds-sa-connect-dso-gke-client-1.json \
            --kubeconfig=~/.kube/config \
            --project=dso-master


# gcloud container hub memberships register $DSO_PROJECT \
#     --gke-cluster=$DSO_GCP_ZONE/$DSO_PROJECT \
#     --service-account-key-file=/home/user/creds-sa-connect-$DSO_PROJECT.json 

###TBD - automate, currenly heavily manual run, nonidempotent...

# gcloud registration fails - searching in dummy path for kubeconfig. setting KUBECONFIG manually?
# gcloud container hub memberships register $DSO_PROJECT \
# >    --gke-uri=$GKE_URI \
# >    --service-account-key-file=/home/user/creds-sa-connect-$DSO_PROJECT.json \
# >    --verbosity debug
#
# DEBUG: Making request: GET http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/sa-owner@dso-gke-client-1.iam.gserviceaccount.com/?recursive=true
# DEBUG: Starting new HTTP connection (1): metadata.google.internal:80
# DEBUG: http://metadata.google.internal:80 "GET /computeMetadata/v1/instance/service-accounts/sa-owner@dso-gke-client-1.iam.gserviceaccount.com/?recursive=true HTTP/1.1" 200 135
# DEBUG: Making request: GET http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/sa-owner@dso-gke-client-1.iam.gserviceaccount.com/token
# DEBUG: http://metadata.google.internal:80 "GET /computeMetadata/v1/instance/service-accounts/sa-owner@dso-gke-client-1.iam.gserviceaccount.com/token HTTP/1.1" 200 249
# DEBUG: Making request: GET http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/sa-owner@dso-gke-client-1.iam.gserviceaccount.com/?recursive=true
# DEBUG: Starting new HTTP connection (1): metadata.google.internal:80
# DEBUG: http://metadata.google.internal:80 "GET /computeMetadata/v1/instance/service-accounts/sa-owner@dso-gke-client-1.iam.gserviceaccount.com/?recursive=true HTTP/1.1" 200 135
# DEBUG: Making request: GET http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/sa-owner@dso-gke-client-1.iam.gserviceaccount.com/token
# DEBUG: http://metadata.google.internal:80 "GET /computeMetadata/v1/instance/service-accounts/sa-owner@dso-gke-client-1.iam.gserviceaccount.com/token HTTP/1.1" 200 249
# DEBUG: Running [gcloud.container.hub.memberships.register] with arguments: [--gke-uri: "https://container.googleapis.com/v1/projects/dso-gke-client-1/zones/europe-central2-a/clusters/dso-gke-client-1", --service-account-key-file: "/home/user/creds-sa-connect-dso-gke-client-1.json", --verbosity: "debug", CLUSTER_NAME: "dso-gke-client-1"]
# DEBUG: Making request: GET http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/sa-owner@dso-gke-client-1.iam.gserviceaccount.com/?recursive=true
# DEBUG: Starting new HTTP connection (1): metadata.google.internal:80
# DEBUG: http://metadata.google.internal:80 "GET /computeMetadata/v1/instance/service-accounts/sa-owner@dso-gke-client-1.iam.gserviceaccount.com/?recursive=true HTTP/1.1" 200 135
# DEBUG: Making request: GET http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/sa-owner@dso-gke-client-1.iam.gserviceaccount.com/token
# DEBUG: http://metadata.google.internal:80 "GET /computeMetadata/v1/instance/service-accounts/sa-owner@dso-gke-client-1.iam.gserviceaccount.com/token HTTP/1.1" 200 249
# DEBUG: Making request: GET http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/sa-owner@dso-gke-client-1.iam.gserviceaccount.com/?recursive=true
# DEBUG: Starting new HTTP connection (1): metadata.google.internal:80
# DEBUG: http://metadata.google.internal:80 "GET /computeMetadata/v1/instance/service-accounts/sa-owner@dso-gke-client-1.iam.gserviceaccount.com/?recursive=true HTTP/1.1" 200 135
# DEBUG: Making request: GET http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/sa-owner@dso-gke-client-1.iam.gserviceaccount.com/token
# DEBUG: http://metadata.google.internal:80 "GET /computeMetadata/v1/instance/service-accounts/sa-owner@dso-gke-client-1.iam.gserviceaccount.com/token HTTP/1.1" 200 249
# DEBUG: unable to load default kubeconfig: unable to load kubeconfig for /tmp/tmpl9ps6mwf/kubeconfig: Unable to read file [/tmp/tmpl9ps6mwf/kubeconfig]: [Errno 2] No such file or directory: '/tmp/tmpl9ps6mwf/kubeconfig'; recreating /tmp/tmpl9ps6mwf/kubeconfig
# DEBUG: Saved kubeconfig to /tmp/tmpl9ps6mwf/kubeconfig
# kubeconfig entry generated for dso-gke-client-1.
# DEBUG: Executing command: ['/usr/local/bin/kubectl', '--kubeconfig', '/tmp/tmpl9ps6mwf/kubeconfig', '--request-timeout', '20s', 'auth', 'can-i', '*', '*', '--all-namespaces']
# DEBUG: (gcloud.container.hub.memberships.register) Failed to check if the user is a cluster-admin: Unable to connect to the server: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
# Traceback (most recent call last):
#   File "/usr/lib/google-cloud-sdk/lib/googlecloudsdk/calliope/cli.py", line 982, in Execute
#     resources = calliope_command.Run(cli=self, args=args)
#   File "/usr/lib/google-cloud-sdk/lib/googlecloudsdk/calliope/backend.py", line 809, in Run
#     resources = command_instance.Run(args)
#   File "/usr/lib/google-cloud-sdk/lib/surface/container/hub/memberships/register.py", line 314, in Run
#     kube_client.CheckClusterAdminPermissions()
#   File "/usr/lib/google-cloud-sdk/lib/googlecloudsdk/command_lib/container/hub/kube_util.py", line 344, in CheckClusterAdminPermissions
#     'Failed to check if the user is a cluster-admin: {}'.format(err))
# googlecloudsdk.command_lib.container.hub.kube_util.KubectlError: Failed to check if the user is a cluster-admin: Unable to connect to the server: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)

# ERROR: (gcloud.container.hub.memberships.register) Failed to check if the user is a cluster-admin: Unable to connect to the server: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
