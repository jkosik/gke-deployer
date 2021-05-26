# ArgoCD

## Installation
Jumphost or adminhosts are bootstrapped using argocd.sh which deploys ArgoCD into GKE cluster and deploys ArgoCD console to the machine for further maintenance.

## To access ArgoCD GUI:
#### Option 1)  
- On Jumphost:  
```
kubectl -n argocd port-forward svc/argocd-server -n argocd 8080:443
```

- On desktop:  
```
ssh -L 1234:localhost:8080 user@34.116.135.131 -i /data/access/gcp
https://localhost:1234/
```

#### Option 2)  
Update AgroCD Service and deploy appropriate Ingress according to [official howto](https://argoproj.github.io/argo-cd/getting_started/#3-access-the-argo-cd-api-server) and expose GUI outside the cluster.