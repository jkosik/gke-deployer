# gke-deployer

## GKE Deployment
[gcp-master/deployment.sh](gcp-master/deployment.sh) builds GKE to the existing GCP project and postdeploys [jumphost](docs/jh.md) with supplementary applications as [ArgoCD](docs/argocd.md), Prometheus stack, Loki, Goldpinger, optionally service mesh, etc.

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
Customer facing

## Open questions
- `deployment.yaml` to use SA with parent in non-free Tier.
- GCP Project to GKE mapping, 1:1 vs 1:N?
- Workload Identities for GKE - introducing complexity & known limitations
- exposing GKE API to Internet
