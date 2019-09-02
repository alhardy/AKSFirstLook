#!/bin/bash

set -e

if [ -z "$RG" ]
then
      echo "Resource Group Name Not Set. Set the env variable with the following command:"
      echo "export RG=\"rg-name\" "
      return 1
fi

if [ -z "$ACR_NAME" ]
then
      echo "ACR Name Not Set. Set the env variable with the following command:"
      echo "export ACR_NAME=\"acr-name\" "
      return 1
fi


if [ -z "$AKS_NAME" ]
then
      echo "Kubernetes Cluster Name Not Set. Set the env variable with the following command:"
      echo "export AKS_NAME=\"AKS_NAME\" "
      return 1
fi

echo "Granting Kubernetes Cluster "$AKS_NAME" access to ACR $ACR_NAME."
set -x

# Get the id of the service principal configured for AKS
CLIENT_ID=$(az aks show --resource-group $RG --name $AKS_NAME --query "servicePrincipalProfile.clientId" --output tsv)

# Get the ACR registry resource id
ACR_ID=$(az acr show --name $ACR_NAME --resource-group $RG --query "id" --output tsv)

# Create role assignment
az role assignment create --assignee $CLIENT_ID --role acrpull --scope $ACR_ID