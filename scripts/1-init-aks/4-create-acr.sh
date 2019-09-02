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

echo "Creating ACR named $ACR_NAME. This may take a while..."
set -x

az acr create -g $RG -n $ACR_NAME --sku Basic