# Jumphost

## SSH access to Jumphost
```
export JH_IP=`gcloud compute instances describe jh --format='get(networkInterfaces[0].accessConfigs[0].natIP)'`
ssh user@$JH_IP -i PRIVATE_SSH_KEY
```