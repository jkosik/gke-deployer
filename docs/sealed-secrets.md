# SealedSecrets

## How to use SealedSecrets (assuming SealedSecret controller deployed on the k8s cluster)
1. Install client-side tool into /usr/local/bin/

```
GOOS=$(go env GOOS)
GOARCH=$(go env GOARCH)
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.16.0/kubeseal-$GOOS-$GOARCH
sudo install -m 755 kubeseal-$GOOS-$GOARCH /usr/local/bin/kubeseal
```

2. Create a standard k8s Secret file
3. Seal the Secret online (k8s API Servere must be reachable)
```
kubeseal --scope cluster-wide -o yaml < secret.yaml > sealedsecret.yaml
```
You can fetch SealedSecrets PEM certificate from the cluster and encrypt offline as well. "Bring your own certificate" is an option too.
4. Now `sealedsecret.yaml` is secure part of your git repository. Do not commit unencrypted Secret to git. Consider utilize `.gitignore` accordingly.

## Additional info
- Applying `sealedsecret.yaml` to k8s cluster results in creating Secret and SealedSecret resources.
- `gke-deployer` project backups SealedSecrets master key and encryption certificate to the GCP Secret Manager.
- SealedSecrets work out of box for Helm as well as ArgoCD
- Challenge: multicloud deployment. Separate Secrets manifests for all target clusters?