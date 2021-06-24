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
export JH_EXTERNAL_IP=`gcloud compute instances describe jh --format='get(networkInterfaces[0].accessConfigs[0].natIP)'`
ssh -L 1234:localhost:8080 user@$JH_EXTERNAL_IP -i PRIVATE_SSH_KEY
https://localhost:1234/
```

#### Option 2)  
Update AgroCD Service and deploy appropriate Ingress according to [official howto](https://argoproj.github.io/argo-cd/getting_started/#3-access-the-argo-cd-api-server) and expose GUI outside the cluster.

## ArgoCD credentials
The initial password is stored in `argocd-initial-admin-secret` Secret. Update password prior production use.
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

argocd login <ARGOCD_SERVER>
argocd account update-password
```

https://argoproj.github.io/argo-cd/getting_started/#5-register-a-cluster-to-deploy-apps-to-optional

