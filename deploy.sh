#!/bin/bash
set -e

# Usage: ./deploy.sh <branch_name> <ec2_host>
BRANCH_NAME=$1
EC2_HOST=$2

# DockerHub credentials (passed from Jenkins)
DOCKER_USER=${DOCKER_USER}
DOCKER_PASS=${DOCKER_PASS}

if [ -z "$DOCKER_USER" ] || [ -z "$DOCKER_PASS" ]; then
  echo "‚ùå ERROR: Docker credentials not provided. Exiting."
  exit 1
fi

# Determine correct image repo
if [ "$BRANCH_NAME" == "dev" ]; then
  DOCKER_REPO="${DOCKER_USER}/devops-build-dev"
elif [ "$BRANCH_NAME" == "main" ] || [ "$BRANCH_NAME" == "master" ]; then
  DOCKER_REPO="${DOCKER_USER}/devops-build-prod"
else
  DOCKER_REPO="${DOCKER_USER}/devops-build-dev"
fi

FULL_IMAGE="${DOCKER_REPO}:latest"

echo "Ì∫Ä Deploying image: $FULL_IMAGE"
echo "Ì¥ë Logging into Docker Hub..."
echo "$DOCKER_PASS" | sudo docker login -u "$DOCKER_USER" --password-stdin

echo "Ìªë Removing any existing container..."
sudo docker rm -f react-app || true

echo "Ì≥¶ Pulling latest image..."
sudo docker pull "$FULL_IMAGE"

echo "Ì∑π Cleaning up old images..."
sudo docker system prune -f

echo "‚ñ∂Ô∏è Starting new container..."
sudo docker run -d \
  --name react-app \
  -p 80:80 \
  --restart unless-stopped \
  "$FULL_IMAGE"

echo "‚úÖ Deployment successful! App is live at http://$EC2_HOST/"

