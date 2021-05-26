# gke-deployer

## Definition of terms
- `DSO` (DevSecOps) is used to prefix variables, project names and othe robjects to avoid naming conflicts.
- Master - refers to the root GCP project for managing Client projects in GCP. Master Service Account will manage lifecycle of the Clients.
- Client - represents GCP projects built for Application team. Includes primarily managed GKE clusters.

## Process
1. DSO populates "Master" GCP project in the very beginning. One-time job.
2. Client requests GKE and provides [project.vars](gcp-client/project.vars)
3. DSO builds K8S infrastruture for the Client. Entrypoint to the infrastructure is a per-project Jumphost with preinstalled tools.
4. Post-deployment changes are applied on the Client infrastucture as a separate process ad-hoc, e.g. VPC peerings, VPNs, Anthos registrations...

## Master GCP project
[gcp-master/deployment-master.sh](gcp-master/deployment-master.sh) builds Master GCP project and needed components.  
Master GCP project contains Master GKE cluster with [ArgoCD for managing Client infrastructure](docs/argocd.md) related applications, e.g. Prometheus stack, Loki, Goldpinger, Client ArgoCD, optionally service mesh, etc.

## Client GCP project
[gcp-client/deployment.sh](gcp-client/deployment.yaml) builds Client GCP project and needed components.  
Entrypoint to the Client infrastructure is Internet-facing jumphost with pre-installed tools.

## IP address scheme
IP ranges harmonization is needed for efficient peerings and overall maintenance.  
#### Master project
- Default VPC: 192.168.0.0/20. 
- GKE VPC: 192.168.16.0/20. 

#### Client projects
- GKE VPC: `192.168.240.0/20`
    - Service and Pod subnets: `--secondary-range secondary-subnet-services=10.0.32.0/20,secondary-subnet-pods=10.4.0.0/14`
    - GKE control plane: `--master-ipv4-cidr 172.16.0.0/28`

## Applications
Customer facing

## Open questions
- `deployment.yaml` to use SA with parent in non-free Tier.
- GCP Project to GKE mapping, 1:1 vs 1:N?
- Workload Identities for GKE - introducing complexity & known limitations
- exposing GKE API to Internet
