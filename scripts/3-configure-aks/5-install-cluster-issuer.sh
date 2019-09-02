#!/bin/bash

if [ -z "$NAMESPACE" ]
then
      echo "NAMESPACE Not Set. Set the env variable with the following command:"
      echo "export NAMESPACE=\"dev\" "
      return 1
fi

cd k8s

kubectl apply -f cluster-issuer.yaml --namespace $NAMESPACE