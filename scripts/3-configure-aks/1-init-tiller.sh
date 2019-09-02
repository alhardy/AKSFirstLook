#!/bin/bash

set -e

cd k8s

echo "Creating service account and role binding for Ttilleriller"
set -x

kubectl apply -f helm-rbac.yaml

helm init --service-account tiller --node-selectors "beta.kubernetes.io/os"="linux"

set +x
echo "tiller service account and role binding applied"