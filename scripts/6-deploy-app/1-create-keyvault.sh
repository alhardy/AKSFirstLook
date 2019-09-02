#!/bin/bash

if [ -z "$RG" ]
then
      echo "Resource Group Name Not Set. Set the env variable with the following command:"
      echo "export RG=\"rg-name\" "
      return 1
fi

if [ -z "$KEYVAULT_NAME" ]
then
      echo "KEYVAULT_NAME Not Set. Set the env variable with the following command:"
      echo "export KEYVAULT_NAME=\"aksdemo001-kv\" "
      return 1
fi

az keyvault create -n $KEYVAULT_NAME -g $RG -l australiaeast