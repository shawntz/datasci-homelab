#!/bin/bash
set -e

echo "==================================="
echo "DataSci Homelab Setup Script"
echo "==================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Creating .env file from template..."
    cp .env.example .env
    echo ""
    echo "WARNING: Please edit .env and set secure passwords before starting services!"
    echo "  - Set RSTUDIO_PASSWORD to a strong password"
    echo "  - Set JUPYTER_TOKEN to a strong token"
    echo ""
    read -p "Press Enter to continue after updating .env, or Ctrl+C to exit..."
fi

# Create volume directories if they don't exist
echo "Creating volume directories..."
mkdir -p volumes/rstudio-packages
mkdir -p volumes/rstudio-home
mkdir -p volumes/jupyter-home
mkdir -p volumes/shared-data

# Set proper permissions for RStudio user (UID 1000)
echo "Setting permissions for RStudio volumes..."
chmod -R 755 volumes/rstudio-packages
chmod -R 755 volumes/rstudio-home

# Set proper permissions for Jupyter user (UID 1000)
echo "Setting permissions for Jupyter volumes..."
chmod -R 755 volumes/jupyter-home

# Set permissions for shared data
echo "Setting permissions for shared data directory..."
chmod -R 777 volumes/shared-data

echo ""
echo "==================================="
echo "Setup Complete!"
echo "==================================="
echo ""
echo "Next steps:"
echo "  1. Pull pre-built images: docker-compose pull"
echo "  2. Start services: docker-compose up -d"
echo "  3. Check status: docker-compose ps"
echo "  4. View logs: docker-compose logs -f"
echo ""
echo "Access your services:"
echo "  - RStudio Server: http://localhost:8787 (or your configured port)"
echo "  - Jupyter Lab: http://localhost:8888 (or your configured port)"
echo ""
echo "To stop services: docker-compose down"
echo "To update services: docker-compose pull && docker-compose up -d"
echo ""
