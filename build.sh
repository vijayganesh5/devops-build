#!/bin/bash

# Usage: ./build.sh <branch_name> <docker_username> <docker_password>
BRANCH_NAME=$1
DOCKER_USERNAME=$2
DOCKER_PASSWORD=$3

set -e

# Determine Docker repo and image tag
if [ "$BRANCH_NAME" == "dev" ]; then
    DOCKER_REPO="devops-build-dev"
    IMAGE_TAG="latest"
elif [ "$BRANCH_NAME" == "master" ]; then
    DOCKER_REPO="devops-build-prod"
    IMAGE_TAG="latest"
else
    DOCKER_REPO="devops-build-dev"
    IMAGE_TAG="$BRANCH_NAME"
fi

FULL_IMAGE="$DOCKER_USERNAME/$DOCKER_REPO:$IMAGE_TAG"

echo "Ì¥ë Logging into Docker Hub..."
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

echo "Ìª†Ô∏è Building Docker image: $FULL_IMAGE ..."
docker build -t $FULL_IMAGE .

echo "Ì≥§ Pushing Docker image to Docker Hub..."
docker push $FULL_IMAGE

echo "‚úÖ Docker image pushed successfully!"

