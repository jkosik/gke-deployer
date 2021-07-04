# Jumphost

## SSH access to Jumphost
```
export JH_EXTERNAL_IP=`gcloud compute instances describe jh --format='get(networkInterfaces[0].accessConfigs[0].natIP)'`
ssh -i PRIVATE_SSH_KEY user@$JH_EXTERNAL_IP
```