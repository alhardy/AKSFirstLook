# AKS First Look

This repo is a first look at Azure Kubernetes Service. It includes a step by step guide to configure an AKS cluster hosting an ASP.NET Core 3.0 API and .NET Core 3.0 worker process. The worker process subscribes to messages published by the API via Azure Service Bus using NServiceBus.

The guide will have you:
1. Configure an AKS cluster
2. Create an Azure Container Registry (ACR) for hosting the solutions docker images
3. Build and push the solutions docker images to ACR
4. Configure certificate management on the AKS cluster automating SSL Certificate issuing for the API using LetsEncrypt
5. Install Azure Pod Identity providing user assigned managed identities to pods allowing applications to authenticate with Azure resources using Managed Identities.
6. Create a NGINX Ingress controller for the ASP.NET Core API allowing for layer 7 load balancing features such as TLS termination
7. Create an Azure Keyvault instance storing application secrets whereby access is provided via Azure Pod Identity.

## Set your Azure Subscription

Set the Azure Subscription that you'll be working with.

```console
$ az login
$ az account list
$ export SUBSCRIPTIONID="{Subscritpion Id}"
$ az account set --subscription $SUBSCRIPTIONID
```

## Setup required az resources and deploy to AKS

### Create the resource group

Create the resource group for the azure resources being created.

```console
$ export RG="aksdemo-rg"
$ ./scripts/1-init-aks/1-create-rg.sh
```

### Create the AKS cluster and configure kubectl

Create a new AKS cluster and configure the kubectl cli for connecting to the new cluster.

```console
$ export AKS_NAME="aksdemocluster"
$ ./scripts/1-init-aks/2-create-aks.sh
$ ./scripts/1-init-aks/3-configure-cli.sh
```

### Create the ACR for hosting docker images

Create a new Azure Container Registry to host the applications docker image.

```console
$ export ACR_NAME="aksdemo001"
$ ./scripts/1-init-aks/4-create-acr.sh
```

### AKS ACR Access

Grant access for AKS to pull docker images from ACR.

```console
$ ./scripts/1-init-aks/5-grant-aks-acr-access.sh
```

## Docker

Build the applications docker image and push to Azure Container Registry.

```console
$ ./scripts/2-docker/1-build-docker-images.sh
$ ./scripts/2-docker/2-push-docker-images.sh
```

## Configure AKS

Configure a service account for tiller allowing installation of an NGINX ingress controller and cert manager via HELM

> NOTE: Additional security should be configured for tiller when running in production. HELM 3 will not require tiller [avoiding it's security concerns](https://medium.com/@jeroen.rosenberg/using-helm-charts-without-tiller-f1588bc1f0c4).

```console
$ ./scripts/3-configure-aks/1-init-tiller.sh
```

Create the NGINX ingress controller in the "dev" namespace for layer 7 load balancing which we'll use for TLS termination. This will pause waiting for the External IP, Ctrl+C once available and use to configure dns name

```console
$ export NAMESPACE="dev"
$ ./scripts/3-configure-aks/2-nginx-ingress-controller.sh
```

Configure DNS, pass in the External IP address of the ingress controller

```console
$ export DNS_NAME="aksdemo001"
$ ./scripts/3-configure-aks/3-configure-dns-name.sh {External IP of Ingress Controller}
```

Install cert manager and use LetsEncrypt for automatic certificate issuing and renewal. You may need to wait for the cert manager to be running before installing the cluster issuer.

```console
$ ./scripts/3-configure-aks/4-install-cert-manager.sh
$ ./scripts/3-configure-aks/5-install-cluster-issuer.sh
```

## Managed Pod Identity using AAD Pod Identity

Install Pod Identity allowing pods to use a user assigned managed identity to access keyvault and other azure resources.

Details: [aad-pod-identity](https://github.com/Azure/aad-pod-identity)

### Install the aad-pod-identity infrastructure

```console
$ ./scripts/5-pod-identity/1-install-pod-identity.sh
```

### Create User Managed Azure Identity

Create the managed identity "values-microservice-identity" to be used by the application to access azure resources

```console
$ ./scripts/5-pod-identity/2-create-azure-identity.sh
```

### Grant Managed Identity Operator to AKS Cluster

Assign Managed Identity Operator the the cluster's service principal

 ```console
 $ ./scripts/5-pod-identity/3-grant-managed-identity-operator-role-to-identity.sh
 ```

Install the applications azure identity resource, and role binding to assign the identity to selected pods

> TODO: params in yaml cause issues when assigning, hard coding ids with double quotes works.

 ```console
 $ ./scripts/5-pod-identity/4-install-azure-identity.sh
 $ ./scripts/5-pod-identity/5-create-azure-identity-binding.sh
 ```

## Deploy application to AKS

Create an Azure KeyVault instance to store application's secrets and assign the applications managed identity access to get and list secrets

```console
$ export KEYVAULT_NAME="aksdemo001-kv"
$ ./scripts/6-deploy-app/1-create-keyvault.sh
$ ./scripts/6-deploy-app/2-assign-azure-identity-roles-keyvault.sh {clientId} {subscriptionId} {principalId}
```

The values api publishes commands that are subscribed to by the values backend, create the Azure Service Bus namespace and set the connection string in KeyVault.

> TODO: Use the managed service identity for servicebus rather than connection string

```console
$ export SB_NAME="aksdemo001sb"
$ ./scripts/6-deploy-app/3-create-servicebus.sh
```

Deploy the application's K8s resource and create an ingress route allowing access from the internet.

```console
$ ./scripts/6-deploy-app/4-create-app-resources.sh
$ ./scripts/6-deploy-app/5-create-app-ingress.sh
```

Browse to:
 - `https://aksdemo001.australiaeast.cloudapp.azure.com/env`
 - `https://aksdemo001.australiaeast.cloudapp.azure.com/secrets`
 - Send a command via the api to be consumed by the backend worker: 
  
   Stream all worker pods in a new shell
   ```console
   $ kubectl logs -f -l apptype=worker -n dev
   ```
   
   Send a POST request to the command endpoint and view the handled command in the worker's log stream
    ```console
    $ curl -d '["value1"]' -H 'Content-Type: application/json' -X POST https://aksdemo001.australiaeast.cloudapp.azure.com/command
    ```

## Notes

- Scale the api

    ```console
    $ kubectl scale --replicas=6 deployment/values-microservice-deployment -n dev
    ```

- Delete api pods

   ```console
   $ kubectl delete pods -l ms=values -n dev
   $ kubectl get pods -n dev --watch
   ```
  
 - Get pods logs in dev namespace
 
    ```console
    $ kubectl get pods -n dev
    $ kubectl logs {pod name} -n dev
    ```

- Confirm LetsEncrypt certificate issued
 
    ```console
    $ kubectl describe certificate tls-secret -n dev
    ```
- When pushing docker images fails with "error creating overlay mount to /var/lib/docker/overlay2/../merged: device or resource busy" try limiting the number of parallel uploads to 1 as a work around i.e. using the following and then running docker push again.

  ```console
  $ sudo systemctl stop docker
  $ sudo nano /etc/docker/daemon.json
  {
    "max-concurrent-uploads": 1
  }
  $ sudo systemctl start docker
  ```
  
 - Get aad pod identity assigned identities
 
   ```console
    $ kubectl get AzureAssignedIdentities --all-namespaces 
   ```
  
 - aad-pod-identity mic does not always assign the azure identity before application startup, in most cases after a crashloop or two the identity is assigned an application starts up. See https://github.com/Azure/aad-pod-identity/issues/279 for example. To observe this behaviour:
   
   Tail the mic elected leader in a new shell
   
   ```console
   $ kubectl get pods # get the pod name of the mic elected leader
   $ kubectl logs -f {mic elected leader pod name}
   ```
   In a new shell delete the deployment
   
     ```console
     $ kubectl delete deployment values-microservice-deployment -n dev
     $ kubectl delete deployment values-backend-deployment -n dev
     $ kubectl delete svc values-microservice-svc -n dev
     ```
   
   In the mic log tail, notice the identity binding being removed.
   
   Re-create the deployment
   
   ```console
   $ ./scripts/6-deploy-app/3-create-app-resources.sh
   $ kubectl get pods -n dev --watch
   ```
   
   In the mic log tail you'll see the assigning of the identity, notice in some cases there are restarts before successfully starting the pod
   
   
    