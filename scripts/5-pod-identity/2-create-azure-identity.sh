#!/bin/bash


if [ -z "$RG" ]
then
      echo "Resource Group Name Not Set. Set the env variable with the following command:"
      echo "export RG=\"rg-name\" "
      return 1
fi

az identity create -g $RG -n values-microservice-identity -o json

clusterId="/subscriptions/$SUBSCRIPTIONID/resourcegroups/$RG/providers/Microsoft.ContainerService/managedClusters/$AKS_NAME"
export AKS_CLUSTER_CLIENTID=$(az aks list -g $RG --query "[?id=='$clusterId'].{clientId:servicePrincipalProfile.clientId}" -o tsv)
export IDENTITY_FULL_ID=$(az identity show --id /subscriptions/$SUBSCRIPTIONID/resourcegroups/$RG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/values-microservice-identity --query id)
export CLIENTID=$(az identity show --id /subscriptions/$SUBSCRIPTIONID/resourcegroups/$RG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/values-microservice-identity --query clientId)
export PRINCIPALID=$(az identity show --id /subscriptions/$SUBSCRIPTIONID/resourcegroups/$RG/providers/Microsoft.ManagedIdentity/userAssignedIdentities/values-microservice-identity --query principalId)