i#!/bin/bash

# Usage: ./deploy.sh <branch_name> <ec2_host>
BRANCH_NAME=$1
EC2_HOST=$2

set -e  # Exit immediately on any error

# --- Jenkins-injected credentials ---
DOCKER_USER="$DOCKER_USER"
DOCKER_PASS="$DOCKER_PASS"
EC2_USER="$EC2_USER"
EC2_KEY="$EC2_PRIVATE_KEY"

# --- Safety checks ---
if [ -z "$BRANCH_NAME" ] || [ -z "$EC2_HOST" ]; then
    echo "‚ùå Usage: ./deploy.sh <branch_name> <ec2_host>"
    exit 1
fi

if [ -z "$EC2_KEY" ]; then
    echo "‚ùå Error: EC2 private key not found from Jenkins credentials."
    exit 1
fi

# --- Determine Docker image name and tag ---
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
    IMAGE_TAG="$BRANCH_NAME"
    ;;
esac

FULL_IMAGE="$DOCKER_USER/$DOCKER_REPO:$IMAGE_TAG"

echo "Ì∫Ä Deploying branch '$BRANCH_NAME' to EC2 host: $EC2_HOST"
echo "Ì≥¶ Using Docker image: $FULL_IMAGE"

# --- Create a temporary key file for SSH ---
TEMP_KEY_FILE=$(mktemp)
echo "$EC2_KEY" > "$TEMP_KEY_FILE"
chmod 600 "$TEMP_KEY_FILE"

# --- Remote deployment via SSH ---
ssh -o StrictHostKeyChecking=no -i "$TEMP_KEY_FILE" "$EC2_USER@$EC2_HOST" bash << EOF
    set -e
    echo "Ì¥ë Logging into Docker Hub..."
    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

    echo "Ì≥• Pulling latest image: $FULL_IMAGE"
    docker pull "$FULL_IMAGE"

    echo "Ì∑π Cleaning up old container if any..."
    docker-compose -f docker-compose.yml down || true

    echo "Ì∫Ä Starting new container..."
    export DOCKER_IMAGE="$FULL_IMAGE"
    docker-compose -f docker-compose.yml up -d

    echo "‚úÖ Deployment successful!"
EOF

# --- Cleanup temporary SSH key ---
rm -f "$TEMP_KEY_FILE"

