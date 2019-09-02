#!/bin/bash

if [ -z "$NAMESPACE" ]
then
      echo "NAMESPACE Not Set. Set the env variable with the following command:"
      echo "export NAMESPACE=\"dev\" "
      return 1
fi

if [ -z "$ACR_NAME" ]
then
      echo "ACR Name Not Set. Set the env variable with the following command:"
      echo "export ACR_NAME=\"acr-name\" "
      return 1
fi

set -e

cd k8s

envsubst < ingress.yaml | kubectl apply -f -
