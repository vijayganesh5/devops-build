#!/bin/bash

set -e

# Configuration
DOCKERHUB_USER="vijayganesh5"
DEV_REPO="vijayganesh5/devops-build-dev"
PROD_REPO="vijayganesh5/devops-build-prod"

# Branch-based tagging
BRANCH=$1

if [ -z "$BRANCH" ]; then
  echo "‚ùå Usage: ./build.sh <branch-name>"
  exit 1
fi

echo "Ì∫Ä Building Docker image for branch: $BRANCH"

# Build the Docker image
if [ "$BRANCH" == "dev" ]; then
  echo "Ì¥® Building development image..."
  docker build -t $DEV_REPO:latest .
  echo "‚úÖ Development image built successfully"
elif [ "$BRANCH" == "master" ]; then
  echo "Ì¥® Building production image..."
  docker build -t $PROD_REPO:latest .
  echo "‚úÖ Production image built successfully"
else
  echo "‚ùå Unsupported branch: $BRANCH. Use 'dev' or 'master' only."
  exit 1
fi

echo "Ì¥ë Logging in to Docker Hub..."
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKERHUB_USER" --password-stdin

echo "Ì≥§ Pushing image to Docker Hub..."
if [ "$BRANCH" == "dev" ]; then
  docker push $DEV_REPO:latest
  echo "‚úÖ Development image pushed to Docker Hub"
else
  docker push $PROD_REPO:latest
  echo "‚úÖ Production image pushed to Docker Hub"
fi

echo "‚úÖ Image successfully built and pushed for $BRANCH branch!"
