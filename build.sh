#!/bin/bash
set -e

IMAGE_NAME="vijayganesh5/devops-build"
TAG="dev"

echo "Building Docker image..."
docker build -t $IMAGE_NAME:$TAG .

echo "Pushing image to DockerHub..."
docker push $IMAGE_NAME:$TAG

echo "Build and push completed successfully!"

# Created by Vijay Ganesh
