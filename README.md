# gke-deployer

## Definition of terms
- DSO - DevSecOps. Used to prefix variables, project names to avoid naming conflicts.
- Master - refers to the root GCP project. Resources within (e.g. Service Accounts) will manage lifecycle of the Clients.
- Client - Application team and primarily GKE clusters they request from DSO.

## Process
1. DSO populates "Master" GCP project in the very beginning. One-time job.
2. Client passes to DSOGKE cluster and supplies parameters from `project.vars`
3. DSO deploys Client K8S infrastruture via GitOps
4. Post-deployment changes are applied on Client infrastucture as a separate layer of GitOps automation ad-hoc, e.g. VPC peerings, VPNs, Anthos registrations...

## Master GCP project
`master-gcp/deployment-master.sh` populates master GCP project.

## Client GCP project
`client/deployment.yaml` creates the following:
- Client GCP project.
- Service account with project `owner` permissions. Storing SA credentials to GCP Secret Manager in the Client project.
- Preparing network and subnetworks for deploying GKE.
- Private GKE reachable from with machines in the same subnet. Generating kubeconfig and storing it to GCP Secret Manager in the Client project.
- Internet-facing jumphost for managing GKE from inside the VPC. VMs in the GKE VPC can reach 172.x.x.x (GKE control plane) automatically. 
- Bootstrapping jumphost to use `gcloud` and `kubectl` out of the box.

## IP address scheme
IP ranges harmonization is needed for efficient peerings and overall maintenance.  
#### Master project
- Default subnet in Master project uses 192.168.0.0/20. 

#### Client projects
- VPC network for GKE: `192.168.240.0/20`
- Service and Pod subnets: `--secondary-range secondary-subnet-services=10.0.32.0/20,secondary-subnet-pods=10.4.0.0/14`
- GKE control plane: `--master-ipv4-cidr 172.16.0.0/28`

## Open questions
- `deployment.yaml` to use SA with parent in non-free Tier.
- GCP Project to GKE mapping, 1:1 vs 1:N?
- Workload Identities for GKE - introduced complexity & known limitations