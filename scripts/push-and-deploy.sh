#!/bin/bash

set -e

REGISTRY="ghcr.io"
USERNAME="jisujit"
IMAGE_NAME="ai-focus"
TAG="${1:-latest}"

echo "Building and pushing container image..."

# Build image
cd ../ai-focus-app
docker build -t $REGISTRY/$USERNAME/$IMAGE_NAME:$TAG .

# Login to GitHub Container Registry (requires GitHub token)
echo $GITHUB_TOKEN | docker login ghcr.io -u $USERNAME --password-stdin

# Push image
docker push $REGISTRY/$USERNAME/$IMAGE_NAME:$TAG

echo "Image pushed: $REGISTRY/$USERNAME/$IMAGE_NAME:$TAG"

# Update image tag in manifests if not latest
if [ "$TAG" != "latest" ]; then
    cd ../ai-focus-infrastructure
    sed -i "s|newTag: .*|newTag: $TAG|" apps/ai-focus/base/kustomization.yaml
    
    # Commit and push changes
    git add apps/ai-focus/base/kustomization.yaml
    git commit -m "Update ai-focus image to $TAG"
    git push origin main
    
    echo "Manifests updated with new image tag: $TAG"
fi

echo "ArgoCD will automatically sync the changes within 3 minutes"
