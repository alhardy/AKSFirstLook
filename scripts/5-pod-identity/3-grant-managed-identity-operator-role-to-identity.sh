#!/bin/bash

if [ -z "$AKS_CLUSTER_CLIENTID" ]
then
      echo "AKS Cluster Client Id Not Set. Set the env variable with the following command:"
      echo "export AKS_CLUSTER_CLIENTID=\"xxxx-xxxx-xxxx-xxxx\" "
      return 1
fi

if [ -z "$IDENTITY_FULL_ID" ]
then
      echo "Full Id of the managed identity Not Set. Set the env variable with the following command:"
      echo "export IDENTITY_FULL_ID=\"xxxx-xxxx-xxxx-xxxx\" "
      return 1
fi



az role assignment create --role "Managed Identity Operator" --assignee $AKS_CLUSTER_CLIENTID --scope $IDENTITY_FULL_ID