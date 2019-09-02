#!/bin/bash

set -e

if [ -z "$NAMESPACE" ]
then
      echo "NAMESPACE Not Set. Set the env variable with the following command:"
      echo "export NAMESPACE=\"dev\" "
      return 1
fi

echo "Creating Namespace for ingress resources"
set -x

kubectl create namespace $NAMESPACE

helm install stable/nginx-ingress \
    --namespace $NAMESPACE \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux

kubectl get service -l app=nginx-ingress --namespace $NAMESPACE --watch

set +x
echo "nginx ingress controller created in namspace $NAMESPACE."