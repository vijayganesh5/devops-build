#!/bin/bash

# Variables
DOCKER_USER="vijayganesh5"

# Stop old container if running
docker rm -f react-app || true

# Pull latest image from DockerHub dev repo
docker pull $DOCKER_USER/devops-build-dev:latest

# Run new container
docker run -d -p 80:80 --name react-app $DOCKER_USER/devops-build-dev:latest
