# ArgoCD, Argo Workflows and Argo Events
This project preinstall ArgoCD, Argo Workflows and Argo Events to the GKE and expose UIs using custom GCP Load Balancers to avoid need for `kubectl port-forward`.
Information in this document relates primarily to ArgoCD, however principles can be applied for Argo Workflows as well.

## Change initial ArgoCD password
The initial password is stored in `argocd-initial-admin-secret` Secret in `argocd` namespace. [Login to Jumphost](jh.md) and update password.
```
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

argocd login <ARGOCD_SERVER>
argocd account update-password
```

Note: Default login name is `admin`.

## ArgoCD configuration
Existing ArgoCD deployment can be managed via GUI, CLI client or as recommended using [self-management and App of Apps pattern as demonstrated here](https://github.com/jkosik/sample-app).

## Access Argo Workflows and ArgoCD UI from the workstation:
- Authenticate to appropriate GCP Project and run `./tunnel-argo.sh PATH_TO_JH_PRIVATE_SSH_KEY`.

`tunnel-argo.sh`:
```
#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Path to SSH private key not supplied"
    exit 1
fi

export JH_IP=`gcloud compute instances describe jh --format='get(networkInterfaces[0].accessConfigs[0].natIP)'`

export ARGO_IP=`ssh user@$JH_IP -i $1 'kubectl -n argo get svc argo-server-internal-lb-l4 -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"'`
ssh -fN -L 8000:$ARGO_IP:2746 user@$JH_IP -i $1
echo "=== Tunnel to Argo Workflows are running. Please open the browser at https://localhost:8000/ to log in. ==="
echo "Options to terminate the tunnel: 'fuser -k 8000/tcp' or 'your custom shell-specific command'."

export ARGOCD_IP=`ssh user@$JH_IP -i $1 'kubectl -n argocd get svc argocd-server-internal-lb-l4 -o=jsonpath="{.status.loadBalancer.ingress[0].ip}"'`
ssh -fN -L 8001:$ARGOCD_IP:443 user@$JH_IP -i $1
echo "=== Tunnel to ArgoCD is running. Please open the browser at https://localhost:8001/ to log in. ==="
echo "Options to terminate the tunnel: 'fuser -k 8001/tcp' or 'your custom shell-specific command'."
```

Additional notes:
- LB for Argo Workflows and ArgoCD might not be ready immediately after the infrastructure deployment. Check from JH using `kubectl -n argocd get svc argocd-server-internal-lb-l4`.
- Argo Workflows and ArgoCD tunneled to your workstation can be access via browser: `https://localhost:8001/` or CLI: `argocd login localhost:8001`.
- Argo can be exposed also via Ingress according to [official howto](https://argoproj.github.io/argo-cd/getting_started/#3-access-the-argo-cd-api-server).

## Alternative ArgoCD installation using Helm
Update `https://github.com/argoproj/argo-helm/blob/master/charts/argo-cd/values.yaml` as needed and save as `values-custom.yaml`, e.g.:

```
## Server
server:
  ## ArgoCD config
  ## reference https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/argocd-cm.yaml
  configEnabled: true
  config:
    repositories: |
      - name: sample-app
        type: git
        url: https://github.com/jkosik/sample-app.git

```
Deploy ArgoCD via Helm:
```
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm search repo argo/argo-cd --versions | head
helm upgrade --install -f values-custom.yaml argocd argo/argo-cd --version 3.10.0 -n argocd
```

## Login to Argo Workflows
Enable access to Argo UI, e.g. by SSH tunneling via Jumphost as described above.
To access UI we will need Bearer token.

kubectl create clusterrole argouser --verb=list,update --resource=workflows.argoproj.io,workflowtemplates.argoproj.io

kubectl create sa argouser1 -n argo
kubectl create clusterrolebinding argouser1 --clusterrole=argouser --serviceaccount=argo:argouser1
SECRET=$(kubectl -n argo get sa argouser1 -o=jsonpath='{.secrets[0].name}')
ARGO_TOKEN="Bearer $(kubectl -n argo  get secret $SECRET -o=jsonpath='{.data.token}' | base64 --decode)"
echo $ARGO_TOKEN

Use $ARGO_TOKEN in the frontpage of Argo Workflow UI.
