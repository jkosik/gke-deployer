# ArgoCD
This project preinstall ArgoCD to the GKE.

There are multiple ways of managing ArgoCD:
1. Infrastructure is built with Argo CD & Application owners use Argo GUI or CLI for further configuration.
2. Infrastructure is built with Argo CD & Application owners follow self-managed ArgoCD pattern and build master Application with ArgoCD manifests, e.g. `argocd-cm.yaml`
3. Application owners deploy ArgoCD by themselves, e.g. using Helm and [custom values.yaml file](configuration/argocd/values-custom.yaml).

## Change initial ArgoCD password
The initial password is stored in `argocd-initial-admin-secret` Secret in `argocd` namespace. [Login to Jumphost](jh.md) and update password.
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

argocd login <ARGOCD_SERVER>
argocd account update-password
```

Note: Default login name is `admin`. When `<ARGOCD_SERVER>` is not exposed outside K8S Service, first use `kubectl port-forward` or other options described below.

## Manage ArgoCD:
#### 1. Using GitOps to manage Applications in ArgoCD - RECOMMENDED
Unless ArgoCD API is exposed to our CICD tool directly, we access target ArgoCD APIs via the Jumphost.
It is recommended to enrich the ArgoCD Application deployment pipeline with checks, e.g.:
- `kubectl -n argocd get applications.argoproj.io`
- using e2e test of deployed application
- using PrometheusRules

#### 2. Using ArgoCD GUI tunneled over SSH

- Authenticate to appropriate GCP Project and `./tunnel-argocd.sh PATH_TO_JH_PRIVATE_SSH_KEY`, e.g. `./tunnel-argocd.sh /data/access/gcp`.

`tunnel-argocd.sh`:
```
#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Path to SSH private key not supplied"
    exit 1
fi

export JH_IP=`gcloud compute instances describe jh --format='get(networkInterfaces[0].accessConfigs[0].natIP)'`
export ARGOCD_IP=`ssh user@$JH_IP -i $1 'kubectl -n argocd get svc argocd-server-internal-lb-l4 -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"'`
ssh -fN -L 1234:$ARGOCD_IP:443 user@$JH_IP -i $1
echo "=== Tunnel to ArgoCD is running. Please open the browser at https://localhost:1234/ to log in. ==="
echo "Options to terminate the tunnel: 'fuser -k 1234/tcp' or 'your custom shell-specific command'."
```

- Open browser on your machine: https://localhost:1234/.

Additional notes:
- LB for ArgoCD might not be ready immediately after infrastructure deployment. Check from JH using `kubectl -n argocd get svc argocd-server-internal-lb-l4`.
- ArgoCD tunneled to your workstation can be access via browser as well as via CLI: `argcd login localhost:1234`.

#### 3. Exposing ArgoCD GUI to directly reachable network
Update AgroCD Service and deploy appropriate Ingress according to [official howto](https://argoproj.github.io/argo-cd/getting_started/#3-access-the-argo-cd-api-server) and expose GUI outside the cluster.


#### 4. Using ArgoCD binary preinstalled on the Jumphost
```
argocd --help
```

#### How to use ArgoCD to manage apps in remote clusters
https://argoproj.github.io/argo-cd/getting_started/#5-register-a-cluster-to-deploy-apps-to-optional

