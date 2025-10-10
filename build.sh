#!/bin/bash

# Variables
DOCKER_USER="vijayganesh5"
IMAGE_NAME="react-app"

# Build the image
docker build -t $DOCKER_USER/devops-build-dev:latest .

# Push to DockerHub dev repo
docker push $DOCKER_USER/devops-build-dev:latest
