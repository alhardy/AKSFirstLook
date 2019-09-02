#!/bin/bash

set -e

if [ -z "$ACR_NAME" ]
then
      echo "ACR Name Not Set. Set the env variable with the following command:"
      echo "export ACR_NAME=\"acr-name\" "
      return 1
fi

echo 'building values microservice docker image'
docker build . -f values-microservice.Dockerfile -t "$ACR_NAME.azurecr.io/values-microservice:latest"

echo 'building values backend docker image'
docker build . -f values-backend.Dockerfile -t "$ACR_NAME.azurecr.io/values-backend:latest"
