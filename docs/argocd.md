# ArgoCD

## Change initial ArgoCD password
The initial password is stored in `argocd-initial-admin-secret` Secret in `argocd` namespace. [Login to Jumphost](jh.md) and update password.
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

argocd login <ARGOCD_SERVER>
argocd account update-password
```

Note: Default login name is `admin`. When `<ARGOCD_SERVER>` is not exposed outside K8S Service, first use `kubectl port-forward` or other options described below.

## Manage ArgoCD:
#### 1. Using GitOps to manage Application in ArgoCD - RECOMMENDED


#### 2. Using ArgoCD binary preinstalled on Jumphost
```
argocd --help
```

#### 3. Using ArgoCD GUI tunneled over SSH form your workstation

- Authenticate to appropriate GCP Project and `./tunnel-argocd.sh PATH_TO_JH_PRIVATE_SSH_KEY`, e.g. `./tunnel-argocd.sh /data/access/gcp`.

`tunnel-argocd.sh`:
```
#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Path to SSH private key not supplied"
    exit 1
fi

export JH_EXTERNAL_IP=`gcloud compute instances describe jh --format='get(networkInterfaces[0].accessConfigs[0].natIP)'`
ssh user@$JH_EXTERNAL_IP -i $1 'kubectl -n argocd port-forward svc/argocd-server -n argocd 8080:443' &
ssh -L 1234:localhost:8080 user@$JH_EXTERNAL_IP -i $1
```
- Command will keep terminal window busy and local tcp socket will emerge (1234/tcp).
- Open browser on your machine: https://localhost:1234/.

Note: In case Jumphost already has port-forwarded argo-server session open, ignore warning produced by the script - all will work. If you insist to terminanate obsolete port-forward on the Jumphost, connect to Jumphost and run `pkill kubectl -9`.

#### 4. Exposing ArgoCD to directly reachable network
Update AgroCD Service and deploy appropriate Ingress according to [official howto](https://argoproj.github.io/argo-cd/getting_started/#3-access-the-argo-cd-api-server) and expose GUI outside the cluster.

#### How to use ArgoCD to manage apps in remote clusters
https://argoproj.github.io/argo-cd/getting_started/#5-register-a-cluster-to-deploy-apps-to-optional

