#!/bin/bash

# Creates VPN peering. Must be configured on both sides.

echo "--- Configuring VPC peering on our side ---"
gcloud compute networks peerings create vpc-peering
    --network=$DSO_PROJECT \
    --peer-project=$CUSTOMER_PROJECT_ID \
    --peer-network=$CUSTOMER_NETWORK_NAME 

echo "--- Configuring VPC peering on customer's GKE side ---"

gcloud compute networks peerings create vpc-peering
    --network=$CUSTOMER_NETWORK_NAME \
    --peer-project=$OUR_PROJECT_ID \
    --peer-network=$DSO_PROJECT