#!/bin/bash
set -e

# Check if BRANCH_NAME is passed as an argument, else default to dev
BRANCH_NAME=${1:-dev}

CONTAINER_NAME="react-app"

# Determine Docker image based on branch
if [ "$BRANCH_NAME" == "dev" ]; then
    IMAGE="vijayganesh5/devops-build-dev:latest"
elif [ "$BRANCH_NAME" == "master" ]; then
    IMAGE="vijayganesh5/devops-build-prod:latest"
else
    echo "‚ùå Unsupported branch: $BRANCH_NAME"
    exit 1
fi

echo "Ìªë Stopping old container if exists..."
docker rm -f $CONTAINER_NAME || true

echo "‚¨áÔ∏è Pulling latest image: $IMAGE"
docker pull $IMAGE

echo "Ì∫Ä Starting new container: $CONTAINER_NAME"
docker run -d --name $CONTAINER_NAME -p 80:80 $IMAGE

echo "‚úÖ Deployment completed successfully for branch: $BRANCH_NAME"

