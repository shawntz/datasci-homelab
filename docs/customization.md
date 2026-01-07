# Customization

How to tailor DataSci Homelab to your preferences.

---

## Configuration Hierarchy

DataSci Homelab uses a layered configuration approach:

1. **Base image** — Default packages and settings baked into the Docker image
2. **Config overrides** — Mounted files that override defaults without rebuilding
3. **Environment variables** — Runtime configuration via `.env`
4. **User preferences** — Settings saved in persistent volumes

---

## Environment Variables

All configurable via `.env`:

### Authentication

```ini
# RStudio credentials
RSTUDIO_USER=rstudio
RSTUDIO_PASSWORD=your-secure-password

# Jupyter token
JUPYTER_TOKEN=your-secure-token

# Disable auth entirely (not recommended)
DISABLE_AUTH=false
```

### Ports

```ini
RSTUDIO_PORT=8787
JUPYTER_PORT=8888
```

### Image Selection

```ini
# Pin to specific version
IMAGE_TAG=v1.2.0

# Or use latest
IMAGE_TAG=latest
```

---

## RStudio Preferences

### How Preferences Work

RStudio preferences are stored in:

```
~/.config/rstudio/rstudio-prefs.json
```

This file is in your home directory volume, so changes persist.

### Repository-Tracked Preferences

To apply the same preferences on every deployment:

**Location:** `config-overrides/rstudio-config/rstudio-prefs.json`

This file is copied to the user's config directory on container startup.

### Updating Preferences

1. Change settings in RStudio (Tools → Global Options)
2. Copy to the repo:

```bash
cp volumes/home/.config/rstudio/rstudio-prefs.json \
   config-overrides/rstudio-config/

git add config-overrides/rstudio-config/rstudio-prefs.json
git commit -m "Update RStudio preferences"
```

### Current Default Preferences

```json
{
  "editor_keybindings": "vim",
  "editor_theme": "Xcode",
  "font_size_points": 13,
  "server_editor_font": "SF Mono",
  "relative_line_numbers": true,
  "rainbow_parentheses": true,
  "reformat_on_save": true,
  "use_air_formatter": true,
  "auto_save_on_blur": true,
  "save_workspace": "never",
  "load_workspace": false,
  "restore_source_documents": false
}
```

### Common Customizations

=== "Disable Vim Mode"

    ```json
    {
      "editor_keybindings": "default"
    }
    ```

=== "Change Theme"

    ```json
    {
      "editor_theme": "Tomorrow Night"
    }
    ```

    Available themes: Ambiance, Chaos, Chrome, Clouds, Cobalt, Crimson Editor, Dawn, Dracula, Dreamweaver, Eclipse, Idle Fingers, Katzenmilch, Kr Theme, Material, Merbivore, Merbivore Soft, Mono Industrial, Monokai, Pastel On Dark, Solarized Dark, Solarized Light, TextMate, Tomorrow, Tomorrow Night, Tomorrow Night Blue, Tomorrow Night Bright, Tomorrow Night Eighties, Twilight, Vibrant Ink, Xcode

=== "Change Font"

    ```json
    {
      "server_editor_font_enabled": true,
      "server_editor_font": "Fira Code",
      "font_size_points": 14
    }
    ```

=== "Standard Line Numbers"

    ```json
    {
      "relative_line_numbers": false
    }
    ```

---

## JupyterLab Settings

### Accessing Settings

Settings → Settings Editor

Or edit directly:

```bash
# User settings are stored here
~/.jupyter/lab/user-settings/
```

### Common Settings

=== "Dark Theme"

    Settings → Theme → JupyterLab Dark

=== "Font Size"

    Settings → Settings Editor → Text Editor → Font Size

=== "Auto-Save"

    Settings → Settings Editor → Document Manager → Auto Save Interval

---

## Adding Packages to Base Image

For packages you always want available:

### R Packages

Edit `config/packages.R`:

```r
# Add to the appropriate category
viz_pkgs <- c(
  "ggthemes",
  "wesanderson",
  "your-new-package"  # Add here
)
```

### Python Packages

Edit `config/requirements.txt`:

```txt
numpy>=1.26.4
pandas>=2.2.2
your-new-package>=1.0.0
```

Then rebuild:

```bash
docker-compose build
docker-compose up -d
```

---

## Server Configuration

### RStudio Server

**File:** `config-overrides/rserver.conf`

```ini
# Server settings
www-address=0.0.0.0
www-port=8787
auth-none=0
auth-minimum-user-id=0

# Session settings
session-timeout-minutes=60

# Resource limits
limit-cpu-time-minutes=0
limit-file-upload-size-mb=1024
```

### Jupyter Server

**File:** `config-overrides/jupyter_server_config.py`

```python
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.allow_origin = '*'
c.ServerApp.open_browser = False
```

---

## Volume Customization

### Using External Volumes

```yaml
# docker-compose.override.yml
services:
  homelab:
    volumes:
      # Mount external data
      - /path/to/external/data:/data

      # Use named volumes
      - r-packages:/usr/local/lib/R/site-library

volumes:
  r-packages:
    external: true
```

### Separate Home Directories

If you want separate home directories for RStudio and Jupyter:

```yaml
# docker-compose.override.yml
services:
  homelab:
    volumes:
      - ./volumes/rstudio-home:/home/rstudio
      - ./volumes/jupyter-home:/home/jupyter
```

---

## Adding System Dependencies

For R/Python packages that need system libraries:

### Method 1: Runtime Installation

```bash
docker-compose exec -u root homelab apt-get update
docker-compose exec -u root homelab apt-get install -y libsomething-dev
```

!!! warning
    Changes are lost on container recreation.

### Method 2: Custom Dockerfile

```dockerfile
# Dockerfile.custom
FROM ghcr.io/shawntz/datasci-homelab:latest

USER root
RUN apt-get update && apt-get install -y \
    libsomething-dev \
    another-package \
    && rm -rf /var/lib/apt/lists/*

USER rstudio
```

```yaml
# docker-compose.override.yml
services:
  homelab:
    build:
      context: .
      dockerfile: Dockerfile.custom
```

---

## Timezone Configuration

Default timezone is America/Los_Angeles. To change:

### Method 1: Environment Variable

```yaml
# docker-compose.override.yml
services:
  homelab:
    environment:
      - TZ=America/New_York
```

### Method 2: Rebuild Image

Edit the `Dockerfile`:

```dockerfile
ENV TZ=America/New_York
```

---

## Custom Startup Scripts

### Adding Initialization Steps

Create a custom entrypoint script:

```bash
# config-overrides/custom-init.sh
#!/bin/bash

# Your custom initialization
echo "Running custom init..."

# Call the original entrypoint
exec /entrypoint-override.sh "$@"
```

Update `docker-compose.yml`:

```yaml
entrypoint: ["/config-overrides/custom-init.sh"]
```

---

## R Configuration

### Global R Profile

**File:** `/usr/lib/R/etc/Rprofile.site` (in image)

Or add to `~/.Rprofile` (persists in volume):

```r
# Custom options
options(
  repos = c(CRAN = "https://cloud.r-project.org"),
  download.file.method = "libcurl",
  Ncpus = parallel::detectCores(),
  width = 120,
  scipen = 999
)

# Load packages silently
suppressPackageStartupMessages({
  library(tidyverse)
})

# Custom prompt
options(prompt = "R> ")
```

### Environment Variables for R

```r
# ~/.Renviron
MY_API_KEY=secret
DATABASE_URL=postgres://...
```

---

## Python Configuration

### pip Configuration

**File:** `~/.config/pip/pip.conf`

```ini
[global]
index-url = https://pypi.org/simple
trusted-host = pypi.org

[install]
user = true
```

### Python Startup

**File:** `~/.pythonrc`

```python
import pandas as pd
import numpy as np

pd.set_option('display.max_columns', 50)
pd.set_option('display.width', 120)
```

Then set:

```bash
export PYTHONSTARTUP=~/.pythonrc
```

---

## Creating Your Own Base Image

For heavily customized setups:

```dockerfile
# Dockerfile.custom
FROM ghcr.io/shawntz/datasci-homelab:latest

# Add your customizations
USER root

# System packages
RUN apt-get update && apt-get install -y \
    your-package \
    && rm -rf /var/lib/apt/lists/*

# R packages
RUN Rscript -e "install.packages('your-package')"

# Python packages
RUN pip install your-package

USER rstudio
```

Build and use:

```bash
docker build -f Dockerfile.custom -t my-datasci-homelab .
```

Update `docker-compose.yml` to use your image:

```yaml
image: my-datasci-homelab:latest
```
