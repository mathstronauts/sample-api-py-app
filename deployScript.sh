#!/bin/bash

#connecting to the .env file in the project folder
source .env

# to use the deployment script:
# ./deploy.sh VERSION ENV{dev|prod} BUILD_IMAGE{true|false}


# Variables
VERSION=$1
ENV=$2
BUILD_IMAGE=$3

# Check if version argument is supplied
if [ -z "$VERSION" ]; then
  echo "Please provide the version. Usage: ./deploy.sh <version>"
  exit 1
fi

# Check if environment argument is supplied
if [ "$ENV" != "prod" ] && [ "$ENV" != "dev" ]; then
  echo "Please provide a valid environment. Usage: ./deploy.sh <version> <env> <build_image>"
  echo "Valid values for <env> are 'prod' or 'dev'"
  exit 1
fi

# Check if build_image argument is supplied
if [ "$BUILD_IMAGE" != "true" ] && [ "$BUILD_IMAGE" != "false" ]; then
  echo "Please provide a valid build_image option. Usage: ./deploy.sh <version> <env> <build_image>"
  echo "Valid values for <build_image> are 'true' or 'false'"
  exit 1
fi

# Extract the container name (app name) from deployment.yaml using yq
APP_NAME=$(yq eval '.spec.selector.matchLabels.app' automation/kubernetes/base/deployment.yaml)

# Output the app name to ensure it's correct
echo "Application Name: $APP_NAME"

# Step 0: Perform all checks related to production environment
 #Ensure that code is deployed to prod only from the main branch
if [ "$ENV" = "prod" ]; then
  export KUBECONFIG=kubeconfigs/prod-ca-central-apps-kubeconfig.yaml
  echo "Using production kubeconfig."

  # Check if the current branch is 'main' before allowing production deployment
  current_branch=$(git rev-parse --abbrev-ref HEAD)
  if [ "$current_branch" != "main" ]; then
    echo "ERROR: You are trying to deploy to production from the '$current_branch' branch. Switch to the 'main' branch before deploying to production."
    exit 1
  fi
else
  # Step 1: Export the appropriate kubeconfig file for the development environment
    export KUBECONFIG=kubeconfigs/dev-ca-central-apps-kubeconfig.yaml
    echo "Using development kubeconfig."
fi


# Step 2: Optionally Build Docker Image
if [ "$BUILD_IMAGE" = "true" ]; then
  echo "Building Docker image..."
  docker build -t mathstronautslearn/$APP_NAME:$VERSION .
  

  # Step 3: Docker Login
  echo "Logging into Docker Hub..."
  echo $DOCKER_PASSWORD | docker login --username $DOCKER_USERNAME --password-stdin

  # Step 4: Push Docker Image
  echo "Pushing Docker image to Docker Hub..."
  docker push mathstronautslearn/$APP_NAME:$VERSION
  
else
  echo "Skipping Docker image build and push."
fi

# Step 5: Update Kubernetes Deployment YAML with new version
echo "Updating Kubernetes deployment..."
echo "Image: mathstronautslearn/$APP_NAME:$VERSION"
sed -i "s#image:.*#image: mathstronautslearn/$APP_NAME:$VERSION#g" automation/kubernetes/base/deployment.yaml


# Step 6: Apply Kubernetes manifests based on the environment
echo "Deploying to Kubernetes using the $ENV environment..."

# Apply base manifests and Environment manifests
kubectl apply -f automation/kubernetes/base/namespace.yaml
kubectl apply -f automation/kubernetes/overlays/$ENV/configmap.yaml
kubectl apply -f automation/kubernetes/base/deployment.yaml
kubectl apply -f automation/kubernetes/base/service.yaml
kubectl apply -f automation/kubernetes/overlays/$ENV/ingress.yaml

echo "Deployment to $ENV environment completed."
