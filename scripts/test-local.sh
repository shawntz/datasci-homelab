#!/usr/bin/env bash
#
# Test the image locally on current platform
#
# Usage:
#   ./scripts/test-local.sh [MODE]
#
# MODE: rstudio, jupyter, or both (default: both)

set -e

MODE="${1:-both}"

echo "=========================================="
echo "  Building and Testing Locally"
echo "=========================================="
echo "Mode: ${MODE}"
echo ""

# Build for current platform only
echo "Building image for $(uname -m)..."
docker build -t ds-workbench:test .

echo ""
echo "Starting container..."
echo ""

# Run the container
docker run --rm -it \
  -p 8787:8787 \
  -p 8888:8888 \
  -v "$(pwd)/work:/home/rstudio/work" \
  -e DISABLE_AUTH=true \
  ds-workbench:test \
  ${MODE}
