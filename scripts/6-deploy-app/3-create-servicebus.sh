#!/bin/bash

if [ -z "$RG" ]
then
      echo "Resource Group Name Not Set. Set the env variable with the following command:"
      echo "export RG=\"rg-name\" "
      return 1
fi

if [ -z "$SB_NAME" ]
then
      echo "SB_NAME Not Set. Set the env variable with the following command:"
      echo "export SB_NAME=\"aksdemo001-sb\" "
      return 1
fi


if [ -z "$KEYVAULT_NAME" ]
then
      echo "KEYVAULT_NAME Not Set. Set the env variable with the following command:"
      echo "export KEYVAULT_NAME=\"aksdemo001-kv\" "
      return 1
fi

az servicebus namespace create --resource-group $RG --name $SB_NAME --location australiaeast

# TODO: Managed Service Identity with NSB?
echo "Getting Service Bus connection string and adding to keyvault"

connectionString=$(az servicebus namespace authorization-rule keys list --resource-group $RG --namespace-name $SB_NAME --name RootManageSharedAccessKey --query primaryConnectionString --output tsv)
az keyvault secret set --vault-name $KEYVAULT_NAME --name Secrets--ServiceBusConnectionString --value $connectionString