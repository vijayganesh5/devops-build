#!/bin/bash

set -e

BRANCH=$1

if [ -z "$BRANCH" ]; then
  echo "‚ùå Usage: ./deploy.sh <branch-name>"
  exit 1
fi

echo "Ì∫Ä Deploying $BRANCH build to EC2..."

# Stop any running containers
docker stop devops-react || true
docker rm devops-react || true

# Pull latest image
if [ "$BRANCH" == "dev" ]; then
  docker pull vijayganesh5/devops-build-dev:latest
  docker run -d -p 80:80 --name devops-react vijayganesh5/devops-build-dev:latest
elif [ "$BRANCH" == "master" ]; then
  docker pull vijayganesh5/devops-build-prod:latest
  docker run -d -p 80:80 --name devops-react vijayganesh5/devops-build-prod:latest
else
  echo "‚ùå Unsupported branch. Use 'dev' or 'master' only."
  exit 1
fi

echo "‚úÖ Deployment successful on EC2!"

