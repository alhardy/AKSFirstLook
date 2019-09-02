#!/bin/bash

set -e

if [ "$1" = "" ]; then
    echo "Provide the public IP address of the ingress controller"
    exit 1
fi

# Name to associate with public IP address
if [ -z "$DNS_NAME" ]
then
      echo "DNS_NAME Not Set. Set the env variable with the following command:"
      echo "export DNS_NAME=\"aksdemo001\" "
      return 1
fi

IP=$1

set -x

# Get the resource-id of the public ip
PUBLICIPID=$(az network public-ip list --query "[?ipAddress!=null]|[?contains(ipAddress, '$IP')].[id]" --output tsv)

az network public-ip update --ids $PUBLICIPID --dns-name $DNS_NAME

set +x
echo "Updated public ip address with DNS name"