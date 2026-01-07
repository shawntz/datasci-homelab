# Installation Options

This page covers different ways to install and run DataSci Homelab.

---

## Standard Installation (Recommended)

The quickest way to get started using pre-built images.

### 1. Clone and Setup

```bash
git clone https://github.com/shawntz/datasci-homelab
cd datasci-homelab
./scripts/setup.sh
```

### 2. Configure

Edit `.env` with your preferred settings:

```ini
RSTUDIO_USER=rstudio
RSTUDIO_PASSWORD=your-password
JUPYTER_TOKEN=your-token
RSTUDIO_PORT=8787
JUPYTER_PORT=8888
```

### 3. Pull and Run

```bash
docker-compose pull
docker-compose up -d
```

---

## Building from Source

Build the image locally if you want to:

- Customize the base packages
- Add proprietary software
- Modify system configurations
- Test changes before pushing

### Build Commands

```bash
# Build for your current architecture
docker-compose build

# Build with no cache (clean build)
docker-compose build --no-cache

# Build and start
docker-compose up -d --build
```

### Multi-Architecture Build

To build for both AMD64 and ARM64:

```bash
# Create a builder (one-time setup)
docker buildx create --name multiarch --use

# Build and push to registry
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --tag your-registry/datasci-homelab:latest \
  --push .
```

---

## Registry Options

The image is mirrored to both registries:

### GitHub Container Registry (GHCR) — Default

```yaml
# docker-compose.yml
image: ghcr.io/shawntz/datasci-homelab:${IMAGE_TAG:-latest}
```

**Advantages:**

- Integrated with GitHub Actions
- No rate limits for authenticated users
- Faster pulls from GitHub infrastructure

### Docker Hub

```yaml
# docker-compose.yml
image: shawnschwartz/datasci-homelab:${IMAGE_TAG:-latest}
```

**Advantages:**

- Familiar registry
- Works everywhere
- Good fallback option

To switch registries, edit `docker-compose.yml` and comment/uncomment the appropriate `image:` line.

---

## Version Pinning

For reproducibility, pin to a specific version:

```yaml
# Use a specific release
image: ghcr.io/shawntz/datasci-homelab:v1.2.0

# Or use a commit SHA
image: ghcr.io/shawntz/datasci-homelab:sha-abc1234
```

Available tags:

| Tag | Description |
|-----|-------------|
| `latest` | Most recent stable build |
| `v1.x.x` | Semantic version releases |
| `sha-xxxxxx` | Specific commit builds |
| `main` | Latest from main branch |

---

## Environment Variables

All configurable options:

| Variable | Default | Description |
|----------|---------|-------------|
| `RSTUDIO_USER` | `rstudio` | Username for RStudio login |
| `RSTUDIO_PASSWORD` | `rstudio` | Password for RStudio login |
| `JUPYTER_TOKEN` | (none) | Access token for JupyterLab |
| `RSTUDIO_PORT` | `8787` | Host port for RStudio Server |
| `JUPYTER_PORT` | `8888` | Host port for JupyterLab |
| `DISABLE_AUTH` | `false` | Disable authentication (not recommended) |
| `IMAGE_TAG` | `latest` | Docker image tag to use |

---

## Volume Mounts

Default volume configuration:

```yaml
volumes:
  # User home directory
  - ./volumes/home:/home/rstudio

  # R package library
  - ./volumes/r-library:/usr/local/lib/R/site-library

  # Python user packages
  - ./volumes/python-packages:/home/rstudio/.local

  # Shared data directory
  - ./volumes/shared-data:/data

  # Configuration overrides
  - ./config-overrides:/config-overrides:ro
```

### Custom Volume Locations

To use different paths, override in `.env` or `docker-compose.override.yml`:

```yaml
# docker-compose.override.yml
services:
  homelab:
    volumes:
      - /path/to/your/data:/data
      - /path/to/r-packages:/usr/local/lib/R/site-library
```

---

## Running Single Services

By default, both RStudio and JupyterLab start. To run only one:

```yaml
# docker-compose.yml
command: rstudio  # Only RStudio
# or
command: jupyter  # Only JupyterLab
# or
command: both     # Both (default)
```

Or override at runtime:

```bash
docker-compose run --rm homelab rstudio
```

---

## Resource Limits

Limit CPU and memory usage:

```yaml
# docker-compose.override.yml
services:
  homelab:
    deploy:
      resources:
        limits:
          cpus: '4'
          memory: 8G
        reservations:
          cpus: '2'
          memory: 4G
```

---

## Network Configuration

### Using a Custom Network

```yaml
# docker-compose.override.yml
services:
  homelab:
    networks:
      - my-network

networks:
  my-network:
    external: true
```

### Exposing to LAN Only

```yaml
# docker-compose.override.yml
services:
  homelab:
    ports:
      - "192.168.1.100:8787:8787"
      - "192.168.1.100:8888:8888"
```

---

## Verification

After installation, verify everything works:

```bash
# Check container status
docker-compose ps

# Check health
docker inspect datasci-homelab --format='{{.State.Health.Status}}'

# View logs
docker-compose logs -f

# Test R
docker-compose exec homelab Rscript -e "print('R works!')"

# Test Python
docker-compose exec homelab python -c "print('Python works!')"
```

---

## Uninstalling

To completely remove DataSci Homelab:

```bash
# Stop and remove containers
docker-compose down

# Remove volumes (WARNING: deletes all packages and data!)
docker-compose down -v

# Remove the image
docker rmi ghcr.io/shawntz/datasci-homelab:latest

# Remove the directory
cd .. && rm -rf datasci-homelab
```

!!! danger "Data Loss Warning"
    Running `docker-compose down -v` will delete all persistent data, including installed packages and files in the home directory.
