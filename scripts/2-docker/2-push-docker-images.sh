#!/bin/bash

set -e

if [ -z "$ACR_NAME" ]
then
      echo "ACR Name Not Set. Set the env variable with the following command:"
      echo "export ACR_NAME=\"acr-name\" "
      return 1
fi
echo "Logging in to ACR and pushing docker images"
set -x

az acr login -n $ACR_NAME

docker push "$ACR_NAME.azurecr.io/values-microservice:latest"

docker push "$ACR_NAME.azurecr.io/values-backend:latest"

set +x
echo "all images pushed to ACR"
