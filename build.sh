#!/bin/bash
set -e

DOCKER_USER="vijayganesh5"
IMAGE_NAME="devops-build-dev"

echo "Ìª†Ô∏è Building Docker image..."
docker build -t $DOCKER_USER/$IMAGE_NAME:latest .

echo "Ì¥ë Logging into Docker Hub..."
docker login -u "$DOCKER_USER"

echo "Ì≥§ Pushing image to Docker Hub..."
docker push $DOCKER_USER/$IMAGE_NAME:latest

echo "‚úÖ Image pushed successfully!"

