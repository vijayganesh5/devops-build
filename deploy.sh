#!/bin/bash

# Usage: ./deploy.sh <branch_name> <ec2_host>
BRANCH_NAME=$1
EC2_HOST=$2

set -e

# Docker Hub credentials from Jenkins
DOCKER_USER=${DOCKER_USER}
DOCKER_PASS=${DOCKER_PASS}

# EC2 SSH credentials from Jenkins
EC2_USER=${EC2_USER}
EC2_KEY=${EC2_PRIVATE_KEY}

# Determine Docker repo and tag
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

FULL_IMAGE="$DOCKER_USER/$DOCKER_REPO:$IMAGE_TAG"

echo "íº€ Deploying branch $BRANCH_NAME to EC2 ($EC2_HOST) with image: $FULL_IMAGE ..."

ssh -o StrictHostKeyChecking=no -i "$EC2_KEY" $EC2_USER@$EC2_HOST << EOF
    set -e
    echo "í´‘ Logging into Docker Hub..."
    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

    echo "í³¥ Pulling Docker image: $FULL_IMAGE"
    docker pull $FULL_IMAGE

    # Stop old container using docker-compose if exists
    export DOCKER_IMAGE=$FULL_IMAGE
    docker-compose -f docker-compose.yml down || true

    echo "â–¶ï¸ Starting new container using docker-compose..."
    docker-compose -f docker-compose.yml up -d

    echo "âœ… Deployment finished!"
EOF

