#!/usr/bin/env bash
#
# Build multi-platform Docker image for datasci-homelab
#
# Usage:
#   ./scripts/build-multiplatform.sh [OPTIONS]
#
# Options:
#   --push              Push to registries after building
#   --tag TAG           Specify custom tag (default: latest)
#   --platform PLATFORM Specify platforms (default: linux/amd64,linux/arm64)
#   --help              Show this help message

set -e

# Default values
PUSH=""
TAG="latest"
PLATFORMS="linux/amd64,linux/arm64"
DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-shawnschwartz}"
GHCR_USERNAME="${GHCR_USERNAME:-shawntz}"
REPO_NAME="datasci-homelab"
BUILDER_NAME="datasci-homelab-builder"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --push)
      PUSH="--push"
      shift
      ;;
    --tag)
      TAG="$2"
      shift 2
      ;;
    --platform)
      PLATFORMS="$2"
      shift 2
      ;;
    --help | -h)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --push              Push to registries after building"
      echo "  --tag TAG           Specify custom tag (default: latest)"
      echo "  --platform PLATFORM Specify platforms (default: linux/amd64,linux/arm64)"
      echo "  --help, -h          Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

echo "=========================================="
echo "  Building Multi-Platform Image"
echo "=========================================="
echo "Platforms: ${PLATFORMS}"
echo "Tag:       ${TAG}"
echo "Push:      $([ -n "$PUSH" ] && echo "Yes" || echo "No")"
echo ""

# Create buildx builder if it doesn't exist
if ! docker buildx inspect ${BUILDER_NAME} > /dev/null 2>&1; then
  echo "Creating buildx builder: ${BUILDER_NAME}"
  docker buildx create --name ${BUILDER_NAME} --driver docker-container --bootstrap
fi

# Use the builder
docker buildx use ${BUILDER_NAME}

# Build the image
echo ""
echo "Building image..."
echo ""

docker buildx build \
  --platform ${PLATFORMS} \
  --tag ${DOCKERHUB_USERNAME}/${REPO_NAME}:${TAG} \
  --tag ghcr.io/${GHCR_USERNAME}/${REPO_NAME}:${TAG} \
  ${PUSH} \
  .

echo ""
echo "=========================================="
echo "  Build Complete"
echo "=========================================="
echo ""

if [ -n "$PUSH" ]; then
  echo "Image pushed to:"
  echo "  - docker.io/${DOCKERHUB_USERNAME}/${REPO_NAME}:${TAG}"
  echo "  - ghcr.io/${GHCR_USERNAME}/${REPO_NAME}:${TAG}"
  echo ""
  echo "View your images at:"
  echo "  Docker Hub: https://hub.docker.com/r/${DOCKERHUB_USERNAME}/${REPO_NAME}"
  echo "  GHCR: https://github.com/${GHCR_USERNAME}?tab=packages"
else
  echo "Image built locally (not pushed)"
  echo ""
  echo "To push the image, run:"
  echo "  ./scripts/build-multiplatform.sh --push --tag ${TAG}"
fi
echo ""
