#!/bin/bash

set -e

if [ -z "$RG" ]
then
      echo "Resource Group Name Not Set. Set the env variable with the following command:"
      echo "export RG=\"rg-name\" "
      return 1
fi

if [ -z "$AKS_NAME" ]
then
      echo "K8S Name Not Set. Set the env variable with the following command:"
      echo "export AKS_NAME=\"k8s-name\" "
      return 1
fi


set -x

az aks get-credentials -g $RG -n $AKS_NAME

set +x

echo "kubectl is now configured. Run the following command to see your nodes"
echo "kubectl get nodes"