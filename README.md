# DataSci Homelab

A Docker-based data science homelab environment with RStudio Server and Jupyter Lab, designed for persistent package installations and remote access via Cloudflare tunnels.

## Overview

This repository provides a single source of truth for your data science environment, with:
- **RStudio Server** with R, tidyverse, Quarto, and database connectors
- **Jupyter Lab** with Python, pandas, scikit-learn, and multi-kernel support
- **Persistent package storage** - packages survive container restarts and rebuilds
- **Shared data directory** - accessible from both environments
- **Dual registry support** - images mirrored to GHCR and Docker Hub
- **Cloudflare tunnel ready** - easily expose to the internet securely

## Features

### RStudio Server
- Base: `rocker/verse` (includes tidyverse + publishing tools)
- Pre-installed packages:
  - Data science: tidyverse, tidymodels, data.table
  - Database: RPostgres, RMySQL, DBI, odbc
  - Publishing: Quarto, tinytex, rticles
  - Development: devtools, usethis, renv
  - Visualization: plotly, patchwork
- Volume-mounted package persistence
- Custom .Rprofile for better defaults

### Jupyter Lab
- Base: `jupyter/datascience-notebook` (Python + R + Julia kernels)
- Pre-installed packages:
  - Data science: pandas, numpy, scikit-learn, seaborn, plotly
  - ML: xgboost, lightgbm, statsmodels
  - Database: psycopg2, pymysql, sqlalchemy
  - Tools: polars, duckdb, nbdime, jupyterlab-git
  - Publishing: Quarto, jupyter-book
- Volume-mounted package persistence
- JupyterLab extensions enabled

### Shared Features
- Persistent storage for packages across rebuilds
- Shared `/data` directory between containers
- Git and version control tools
- Health checks and auto-restart
- Configurable ports and credentials
- **Multi-architecture support**: Works on both AMD64 (Intel/AMD) and ARM64 (Apple Silicon) machines

## Quick Start

### Prerequisites
- Docker Desktop or Docker Engine
- Docker Compose
- At least 8GB RAM available
- 20GB free disk space (for images and volumes)

## Installation

Follow these steps in order to set up your data science homelab:

### Step 1: Clone the Repository

```bash
git clone https://github.com/shawntz/datasci-homelab datasci-homelab
cd datasci-homelab
```

### Step 2: Run the Setup Script

This creates necessary directories and configuration files:

```bash
./scripts/setup.sh
```

### Step 3: Configure Your Environment

Edit the `.env` file and set secure passwords:

```bash
nano .env  # or use your preferred editor
```

Update these values:
- `RSTUDIO_PASSWORD` - your RStudio password
- `JUPYTER_TOKEN` - your Jupyter access token

### Step 4: Pull the Pre-built Images

The Docker images are automatically mirrored to both GitHub Container Registry (GHCR) and Docker Hub.

**Using docker-compose (recommended):**
```bash
# Pulls from GHCR by default (configured in docker-compose.yml)
docker-compose pull
```

**Or pull manually from GHCR:**
```bash
docker pull ghcr.io/shawntz/datasci-homelab:latest
```

**Or pull manually from Docker Hub:**
```bash
docker pull shawnschwartz/datasci-homelab:latest
```

> **Note:** By default, `docker-compose.yml` is configured to pull from GHCR. To switch to Docker Hub, edit `docker-compose.yml` and comment out the GHCR image lines (lines with `ghcr.io`), then uncomment the Docker Hub image lines (lines with `shawnschwartz/`).

### Step 5: Start the Services

```bash
docker-compose up -d
```

### Step 6: Access Your Environments

- **RStudio:** http://localhost:8787 (username: `rstudio`, password: from .env)
- **Jupyter:** http://localhost:8888 (token: from .env)

## Usage

### Starting and Stopping

```bash
# Start services
docker-compose up -d

# Stop services (containers removed, volumes persist)
docker-compose down

# View logs
docker-compose logs -f

# View status
docker-compose ps
```

### Installing Packages

Packages installed during your sessions are automatically persisted!

**In RStudio:**
```r
install.packages("packagename")
```
Packages are stored in `/usr/local/lib/R/site-library` which is volume-mounted.

**In Jupyter (Python):**
```python
!pip install packagename
```
Packages are automatically installed to your user directory (`~/.local`) with the `--user` flag, which is volume-mounted for persistence.

**In Jupyter (R kernel):**
```r
install.packages("packagename")
```

Packages will survive:
- Container restarts (`docker-compose restart`)
- Container recreation (`docker-compose down && docker-compose up -d`)
- Image rebuilds (unless you delete the volumes)

### Backing Up Package Lists

To create a backup of installed packages:

```bash
./scripts/backup-packages.sh
```

This creates timestamped package lists in `package-lists/`:
- `r_packages_TIMESTAMP.csv` - R packages and versions
- `python_packages_TIMESTAMP.txt` - Python packages (pip format)
- `conda_env_TIMESTAMP.yml` - Conda environment export

### Updating Images

To update to the latest base images:

```bash
docker-compose pull
docker-compose up -d --build
```

Your installed packages in volumes will remain intact.

### Shared Data Directory

Both RStudio and Jupyter can access `/data`:

**In RStudio:**
```r
data <- read.csv("/data/myfile.csv")
```

**In Jupyter:**
```python
import pandas as pd
data = pd.read_csv("/data/myfile.csv")
```

Host location: `./volumes/shared-data/`

## Cloudflare Tunnel Setup

To access your homelab from anywhere:

1. Install cloudflared:
   ```bash
   brew install cloudflared  # macOS
   ```

2. Login and create a tunnel:
   ```bash
   cloudflared tunnel login
   cloudflared tunnel create datasci-homelab
   ```

3. Configure the tunnel (create `~/.cloudflared/config.yml`):
   ```yaml
   tunnel: <your-tunnel-id>
   credentials-file: `~/.cloudflared/<tunnel-id>.json`

   ingress:
     - hostname: rstudio.yourdomain.com
       service: http://localhost:8787
     - hostname: jupyter.yourdomain.com
       service: http://localhost:8888
     - service: http_status:404
   ```

4. Start the tunnel:
   ```bash
   cloudflared tunnel run datasci-homelab
   ```

5. Access remotely via your configured hostnames.

## Directory Structure

```
datasci-homelab/
├── docker-compose.yml          # Service orchestration
├── .env                        # Your configuration (not in git)
├── .env.example                # Configuration template
├── .gitignore                  # Git ignore rules
├── README.md                   # This file
├── rstudio/
│   ├── Dockerfile              # RStudio image definition
│   └── rprofile.R              # R configuration
├── jupyter/
│   ├── Dockerfile              # Jupyter image definition
│   └── jupyter_config.py       # Jupyter configuration
├── scripts/
│   ├── setup.sh                # Setup automation
│   ├── backup-packages.sh      # Package backup utility
│   └── build-and-push.sh       # Build and push to GHCR
└── volumes/                    # Persistent data (not in git)
    ├── rstudio-packages/       # R package library
    ├── rstudio-home/           # RStudio user home and projects
    ├── jupyter-home/           # Jupyter notebooks and user-installed packages
    └── shared-data/            # Shared data directory
```

## Troubleshooting

### Containers won't start

Check logs:
```bash
docker-compose logs
```

Common issues:
- Port already in use: Change ports in `.env`
- Permission denied: Run `chmod -R 755 volumes/`
- Out of memory: Allocate more RAM to Docker

### Packages not persisting

Verify volume mounts:
```bash
docker-compose exec rstudio ls -la /usr/local/lib/R/site-library
docker-compose exec jupyter ls -la /opt/conda/lib/python3.11/site-packages
```

### RStudio password not working

Reset password:
```bash
docker-compose exec rstudio passwd rstudio
```

### Jupyter token not working

Get the current token:
```bash
docker-compose logs jupyter | grep token
```

## Maintenance

### Backing Up Volumes

The `volumes/` directory contains all your persistent data:

```bash
# Create a backup
tar -czf datasci-homelab-backup-$(date +%Y%m%d).tar.gz volumes/

# Restore from backup
tar -xzf datasci-homelab-backup-YYYYMMDD.tar.gz
```

### Cleaning Up

Remove stopped containers and unused images:
```bash
docker-compose down
docker system prune -a
```

> [!WARNING]
> To completely reset (WARNING: deletes all packages and data):
```bash
docker-compose down -v
rm -rf volumes/
./scripts/setup.sh
```

## Customization

### Adding More Packages to Base Image

Edit `rstudio/Dockerfile` or `jupyter/Dockerfile` and rebuild:
```bash
docker-compose build
docker-compose up -d
```

### RStudio Preferences

RStudio preferences (theme, keybindings, pane layout, etc.) are tracked in the repo and applied automatically on container startup.

**Location:** `config-overrides/rstudio-config/rstudio-prefs.json`

**To update preferences after changing settings in RStudio:**
```bash
cp volumes/home/.config/rstudio/rstudio-prefs.json config-overrides/rstudio-config/
git add config-overrides/rstudio-config/rstudio-prefs.json
git commit -m "Update RStudio preferences"
```

**Current defaults include:**
- Vim keybindings
- Xcode theme with SF Mono font
- Relative line numbers
- Rainbow parentheses
- Auto-save on blur
- Air formatter with reformat on save
- Custom pane layout with extra source column

No image rebuild is required - preferences are mounted and applied on each `docker-compose up`.

### Changing Ports

Edit `.env`:
```
RSTUDIO_PORT=8080
JUPYTER_PORT=8889
```

Then restart:
```bash
docker-compose down
docker-compose up -d
```

### Resource Limits

Uncomment resource limit lines in `.env` and set values:
```
RSTUDIO_MEM_LIMIT=8g
RSTUDIO_CPU_LIMIT=4
```

## Contributing

Feel free to submit issues and enhancement requests!

## License

MIT License - feel free to use and modify for your needs.

## Acknowledgments

- RStudio: [Rocker Project](https://rocker-project.org/)
- Jupyter: [Jupyter Docker Stacks](https://jupyter-docker-stacks.readthedocs.io/)
- Cloudflare Tunnels: [Cloudflare](https://www.cloudflare.com/products/tunnel/)
