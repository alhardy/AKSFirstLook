#!/bin/bash

if [ -z "$SUBSCRIPTIONID" ]
then
      echo "SUBSCRIPTIONID Not Set. Set the env variable with the following command:"
      echo "export SUBSCRIPTIONID=\"xxxx-xxxx-xxxx-xxxx\" "
      return 1
fi

if [ -z "$KEYVAULT_NAME" ]
then
      echo "KEYVAULT_NAME Not Set. Set the env variable with the following command:"
      echo "export KEYVAULT_NAME=\"aksdemo001-kv\" "
      return 1
fi

if [ -z "$CLIENTID" ]
then
      echo "CLIENTID Not Set. Set the env variable with the following command:"
      echo "export CLIENTID=\"xxxx-xxxx-xxxx-xxxx\" "
      return 1
fi

if [ -z "$PRINCIPALID" ]
then
      echo "PRINCIPALID Not Set. Set the env variable with the following command:"
      echo "export PRINCIPALID=\"xxxx-xxxx-xxxx-xxxx\" "
      return 1
fi

if [ -z "$RG" ]
then
      echo "Resource Group Name Not Set. Set the env variable with the following command:"
      echo "export RG=\"rg-name\" "
      return 1
fi

set -x

# Assign Reader Role to new Identity for your Key Vault
az role assignment create --role Reader --assignee $PRINCIPALID --scope /subscriptions/$SUBSCRIPTIONID/resourcegroups/$RG/providers/Microsoft.KeyVault/vaults/$KEYVAULT_NAME

# set policy to access keys in your Key Vault
az keyvault set-policy -n $KEYVAULT_NAME --key-permissions get list --spn $CLIENTID

# set policy to access secrets in your Key Vault
az keyvault set-policy -n $KEYVAULT_NAME --secret-permissions get list --spn $CLIENTID

# set policy to access certs in your Key Vault
az keyvault set-policy -n $KEYVAULT_NAME --certificate-permissions get list --spn $CLIENTID

# Add some secrets
az keyvault secret set --vault-name $KEYVAULT_NAME --name Secrets--SecretOne --value SecretOneValue
az keyvault secret set --vault-name $KEYVAULT_NAME --name Secrets--SecretTwo --value SecretTwoValue

set +x