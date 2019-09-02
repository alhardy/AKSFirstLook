#!/bin/bash

cd k8s

envsubst < aadpodidentity.yaml | kubectl apply -f -