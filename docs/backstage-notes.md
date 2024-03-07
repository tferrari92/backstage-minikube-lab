# No automatic deletion from catalog

# Development and Production environment
We use app-config.yaml for local testing (when running yarn dev) and app-config.production.yaml when deploying to Minikube.

# app-config.yaml in Kubernetes ConfigMap
I didn't find a way to pass in the Backstage app-config through a ConfigMap instead of hard coding it into the image when building the Docker image.