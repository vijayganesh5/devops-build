#!/bin/bash

# Usage: ./build.sh <branch_name> <docker_username> <docker_password>
BRANCH_NAME=$1
DOCKER_USERNAME=$2
DOCKER_PASSWORD=$3

set -e  # Exit immediately on error

# --- Safety Check ---
if [ ! -d "build" ]; then
    echo "‚ùå Error: build/ folder not found in $(pwd)"
    echo "‚ö†Ô∏è Please ensure you have pre-built React files before running this script."
    exit 1
fi

# --- Determine Docker Image Name and Tag ---
case "$BRANCH_NAME" in
  dev)
    DOCKER_REPO="devops-build-dev"
    IMAGE_TAG="latest"
    ;;
  main|master)
    DOCKER_REPO="devops-build-prod"
    IMAGE_TAG="latest"
    ;;
  *)
    DOCKER_REPO="devops-build-dev"
    IMAGE_TAG="${BRANCH_NAME}"
    ;;
esac

FULL_IMAGE="$DOCKER_USERNAME/$DOCKER_REPO:$IMAGE_TAG"

echo "Ì∑© Branch Detected: $BRANCH_NAME"
echo "Ì∫£ Docker Repository: $FULL_IMAGE"

# --- Docker Login ---
echo "Ì¥ë Logging into Docker Hub..."
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

# --- Build Docker Image ---
echo "Ìª†Ô∏è Building Docker image: $FULL_IMAGE ..."
docker build -t "$FULL_IMAGE" .

# --- Push Docker Image ---
echo "Ì≥§ Pushing Docker image to Docker Hub..."
docker push "$FULL_IMAGE"

echo "‚úÖ Docker image pushed successfully: $FULL_IMAGE"

