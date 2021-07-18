# SealedSecrets

## How to use SealedSecrets (assuming SealedSecret controleer deployed on the k8s cluster)
1. Install client-side tool into /usr/local/bin/

```
GOOS=$(go env GOOS)
GOARCH=$(go env GOARCH)
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.16.0/kubeseal-$GOOS-$GOARCH
sudo install -m 755 kubeseal-$GOOS-$GOARCH /usr/local/bin/kubeseal
```

2. Create a sealed secret file

Note the use of `--dry-run` - this does not create a secret in your cluster.
```
kubectl create secret generic secret-name --dry-run --from-literal=foo=bar -o [json|yaml] | \
 kubeseal \
 --controller-name=sealed-secrets \
 --controller-namespace=default \
 --format [json|yaml] > mysealedsecret.[json|yaml]
```

The file `mysealedsecret.[json|yaml]` is a commitable file.

If you would rather not need access to the cluster to generate the sealed secret you can run:
```
kubeseal \
 --controller-name=sealed-secrets \
 --controller-namespace=default \
 --fetch-cert > mycert.pem
```

To retrieve the public cert used for encryption and store it locally. You can then run 'kubeseal --cert mycert.pem' instead to use the local cert e.g.
```
kubectl create secret generic secret-name --dry-run --from-literal=foo=bar -o [json|yaml] | \
kubeseal \
 --controller-name=sealed-secrets \
 --controller-namespace=default \
 --format [json|yaml] --cert mycert.pem > mysealedsecret.[json|yaml]
```

3. Apply the sealed secret
```
kubectl create -f mysealedsecret.[json|yaml]
```
Running `kubectl get secret secret-name -o [json|yaml]` will show the decrypted secret that was generated from the sealed secret.
