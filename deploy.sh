#!/bin/bash

set -e

BRANCH=$1

if [ -z "$BRANCH" ]; then
  echo "‚ùå Usage: ./deploy.sh <branch-name>"
  exit 1
fi

echo "Ì∫Ä Deploying $BRANCH build to EC2..."

# Stop any running containers
echo "Ìªë Stopping any existing container..."
docker stop devops-react || true
docker rm devops-react || true

# Pull latest image
if [ "$BRANCH" == "dev" ]; then
  echo "Ì≥• Pulling latest dev image..."
  docker pull vijayganesh5/devops-build-dev:latest
  echo "Ì∞≥ Starting dev container..."
  docker run -d -p 80:80 --name devops-react vijayganesh5/devops-build-dev:latest
elif [ "$BRANCH" == "master" ]; then
  echo "Ì≥• Pulling latest prod image..."
  docker pull vijayganesh5/devops-build-prod:latest
  echo "Ì∞≥ Starting prod container..."
  docker run -d -p 80:80 --name devops-react vijayganesh5/devops-build-prod:latest
else
  echo "‚ùå Unsupported branch: $BRANCH. Use 'dev' or 'master' only."
  exit 1
fi

# Wait for container to start
echo "‚è≥ Waiting for container to start..."
sleep 5

# Verify deployment
if docker ps | grep -q devops-react; then
    echo "‚úÖ Deployment successful! Application is running on port 80"
    echo "Ì≥ä Container status:"
    docker ps | grep devops-react
else
    echo "‚ùå Deployment failed - container not running!"
    echo "Ì¥ç Checking container logs:"
    docker logs devops-react || true
    exit 1
fi
