#!/bin/bash

cd k8s

envsubst < aadpodidentitybinding.yaml | kubectl apply -f -