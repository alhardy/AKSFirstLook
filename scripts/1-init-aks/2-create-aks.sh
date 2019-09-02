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
      echo "Kubernetes Cluster Name Not Set. Set the env variable with the following command:"
      echo "export AKS_NAME=\"AKS_NAME\" "
      return 1
fi

echo "Creating AKS cluster named $AKS_NAME. This may take a while..."
set -x

az aks create -g $RG -n $AKS_NAME --node-count 2 --enable-addons monitoring --generate-ssh-keys