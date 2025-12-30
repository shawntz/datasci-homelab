#!/usr/bin/env bash
#
# Push datasci-homelab to both Docker Hub and GitHub Container Registry
#
# Usage:
#   ./scripts/push-to-registries.sh [TAG]
#
# Arguments:
#   TAG    Image tag to push (default: latest)
#
# Environment Variables:
#   DOCKERHUB_USERNAME    Docker Hub username (default: shawnschwartz)
#   GHCR_USERNAME         GitHub username (default: shawntz)

set -e

TAG="${1:-latest}"
DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-shawnschwartz}"
GHCR_USERNAME="${GHCR_USERNAME:-shawntz}"
REPO_NAME="datasci-homelab"

echo "=========================================="
echo "  Push to Multiple Registries"
echo "=========================================="
echo "Image:     ${REPO_NAME}"
echo "Tag:       ${TAG}"
echo "Docker Hub: ${DOCKERHUB_USERNAME}"
echo "GHCR:      ${GHCR_USERNAME}"
echo ""

# Check if user is logged in to Docker Hub
echo "Checking Docker Hub authentication..."
if grep -q "docker.io" ~/.docker/config.json 2>/dev/null || grep -q "https://index.docker.io" ~/.docker/config.json 2>/dev/null; then
  echo "✓ Docker Hub authenticated"
else
  echo "⚠️  Not logged in to Docker Hub"
  echo "Please run: docker login"
  exit 1
fi
echo ""

# Check if user is logged in to GHCR
echo "Checking GHCR authentication..."
if grep -q "ghcr.io" ~/.docker/config.json 2>/dev/null; then
  echo "✓ GHCR authenticated"
else
  echo "⚠️  Not logged in to GitHub Container Registry"
  echo "Please run: docker login ghcr.io"
  exit 1
fi
echo ""

# Build and push multi-platform images
echo "Building and pushing multi-platform images..."
echo "This will build for linux/amd64 and linux/arm64"
echo ""

exec ./scripts/build-multiplatform.sh --push --tag "${TAG}"
