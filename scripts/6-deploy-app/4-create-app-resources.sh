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

set -x

envsubst < values-microservice-deployment.yaml | kubectl create -f -
kubectl create -f services.yaml -n $NAMESPACE

envsubst < values-backend-deployment.yaml | kubectl create -f -

set +x
echo "app resources created"
