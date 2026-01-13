#!/usr/bin/env bash
#
# Build multi-platform Docker image for datasci-homelab
#
# Usage:
#   ./scripts/build-multiplatform.sh [OPTIONS]
#
# Options:
#   --release           Interactive release mode: prompt for version, push, and create GitHub release
#   --push              Push to registries after building
#   --tag TAG           Specify custom tag (default: latest)
#   --platform PLATFORM Specify platforms (default: linux/amd64,linux/arm64)
#   --help              Show this help message

set -e

# Default values
PUSH=""
RELEASE_MODE=""
TAG="latest"
PLATFORMS="linux/amd64,linux/arm64"
DOCKERHUB_USERNAME="${DOCKERHUB_USERNAME:-shawnschwartz}"
GHCR_USERNAME="${GHCR_USERNAME:-shawntz}"
REPO_NAME="datasci-homelab"
BUILDER_NAME="datasci-homelab-builder"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --release)
      RELEASE_MODE="true"
      PUSH="--push"
      shift
      ;;
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
      echo "  --release           Interactive release mode: prompt for version, push, and create GitHub release"
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

# Interactive release mode
if [ -n "$RELEASE_MODE" ]; then
  echo "=========================================="
  echo "  Release Mode"
  echo "=========================================="
  echo ""

  # Get latest git tag for reference
  LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")
  echo "Latest git tag: ${LATEST_TAG}"
  echo ""

  # Prompt for version tag
  read -p "Enter version tag (e.g., v1.0.0): " VERSION_TAG

  # Validate version tag format
  if [[ ! "$VERSION_TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Warning: Version tag '$VERSION_TAG' doesn't match semver format (vX.Y.Z)"
    read -p "Continue anyway? (y/N): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
      echo "Aborted."
      exit 1
    fi
  fi

  # Confirm release
  echo ""
  echo "This will:"
  echo "  1. Build multi-platform image for: ${PLATFORMS}"
  echo "  2. Push to Docker Hub and GHCR with tags: ${VERSION_TAG}, latest"
  echo "  3. Create git tag: ${VERSION_TAG}"
  echo "  4. Create GitHub release: ${VERSION_TAG}"
  echo ""
  read -p "Proceed with release? (y/N): " CONFIRM
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
  fi

  TAG="$VERSION_TAG"
fi

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

# In release mode, tag with both version and latest
if [ -n "$RELEASE_MODE" ]; then
  docker buildx build \
    --platform ${PLATFORMS} \
    --tag ${DOCKERHUB_USERNAME}/${REPO_NAME}:${TAG} \
    --tag ${DOCKERHUB_USERNAME}/${REPO_NAME}:latest \
    --tag ghcr.io/${GHCR_USERNAME}/${REPO_NAME}:${TAG} \
    --tag ghcr.io/${GHCR_USERNAME}/${REPO_NAME}:latest \
    ${PUSH} \
    .
else
  docker buildx build \
    --platform ${PLATFORMS} \
    --tag ${DOCKERHUB_USERNAME}/${REPO_NAME}:${TAG} \
    --tag ghcr.io/${GHCR_USERNAME}/${REPO_NAME}:${TAG} \
    ${PUSH} \
    .
fi

echo ""
echo "=========================================="
echo "  Build Complete"
echo "=========================================="
echo ""

if [ -n "$PUSH" ]; then
  echo "Image pushed to:"
  echo "  - docker.io/${DOCKERHUB_USERNAME}/${REPO_NAME}:${TAG}"
  echo "  - ghcr.io/${GHCR_USERNAME}/${REPO_NAME}:${TAG}"
  if [ -n "$RELEASE_MODE" ]; then
    echo "  - docker.io/${DOCKERHUB_USERNAME}/${REPO_NAME}:latest"
    echo "  - ghcr.io/${GHCR_USERNAME}/${REPO_NAME}:latest"
  fi
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

# Create GitHub release in release mode
if [ -n "$RELEASE_MODE" ]; then
  echo ""
  echo "=========================================="
  echo "  Creating GitHub Release"
  echo "=========================================="
  echo ""

  # Check if gh CLI is installed
  if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed."
    echo "Install it from: https://cli.github.com/"
    echo ""
    echo "You can manually create the release with:"
    echo "  git tag ${TAG} && git push origin ${TAG}"
    exit 1
  fi

  # Check if authenticated
  if ! gh auth status &> /dev/null; then
    echo "Error: Not authenticated with GitHub CLI."
    echo "Run: gh auth login"
    exit 1
  fi

  # Create and push git tag
  echo "Creating git tag: ${TAG}"
  git tag -a "${TAG}" -m "Release ${TAG}" 2>/dev/null || {
    echo "Tag ${TAG} already exists locally, skipping tag creation..."
  }

  echo "Pushing tag to origin..."
  git push origin "${TAG}" 2>/dev/null || {
    echo "Tag ${TAG} already exists on remote, continuing..."
  }

  # Generate release notes
  RELEASE_NOTES="## Docker Images

Pull from Docker Hub:
\`\`\`bash
docker pull ${DOCKERHUB_USERNAME}/${REPO_NAME}:${TAG}
\`\`\`

Pull from GitHub Container Registry:
\`\`\`bash
docker pull ghcr.io/${GHCR_USERNAME}/${REPO_NAME}:${TAG}
\`\`\`

## Platforms
- linux/amd64
- linux/arm64
"

  # Create GitHub release
  echo "Creating GitHub release..."
  gh release create "${TAG}" \
    --title "Release ${TAG}" \
    --notes "${RELEASE_NOTES}" \
    --latest

  echo ""
  echo "=========================================="
  echo "  Release Complete!"
  echo "=========================================="
  echo ""
  echo "GitHub Release: https://github.com/${GHCR_USERNAME}/${REPO_NAME}/releases/tag/${TAG}"
fi
echo ""
