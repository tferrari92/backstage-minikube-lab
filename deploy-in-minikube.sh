#!/bin/bash

# Prompt the user for their GitHub token
read -p "Enter your GitHub token: " GITHUB_TOKEN
read -p "What image tag should be used for Backstage deployment?: " IMAGE_TAG

# Start cluster. Extra beefy beause Backstage is a bit heavy.
minikube start --cpus 4 --memory 4096

# We create the secret for the Github token with this command. This way the token won't get pushed to Github.
kubectl create ns backstage
kubectl create secret generic github-token -n backstage --from-literal=GITHUB_TOKEN="$GITHUB_TOKEN"

# Install Backstage
helm install backstage -n backstage backstage/helm-chart --values backstage/helm-chart/values-custom.yaml --set-string backstage.image.tag="$IMAGE_TAG" --dependency-update --create-namespace

# Install Redis
kubectl create ns my-app
kubectl apply -f k8s-manifests/my-app/redis

# Install Backend service
kubectl apply -f k8s-manifests/my-app/backend

# Install Frontend service
kubectl apply -f k8s-manifests/my-app/frontend

# Wait for the Postgres pod to be ready
echo "Waiting for postgres pod to be ready..."
until [[ $(kubectl -n backstage get pods -l "app.kubernetes.io/name=postgresql" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == "True" ]]; do
  echo "Waiting for postgres pod to be ready... It's required for backstage to start."
  sleep 3
done

# Wait for the Backstage pod to be ready
echo "Waiting for backstage pod to be ready..."
until [[ $(kubectl -n backstage get pods -l "app.kubernetes.io/name=backstage" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') == "True" ]]; do
  echo "Waiting for backstage pod to be ready..."
  sleep 3
done

# Port forward the Backstage service
kubectl port-forward -n backstage service/backstage 8080:7007
