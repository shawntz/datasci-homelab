# Getting Started

Get your data science environment up and running in under 5 minutes.

---

## Prerequisites

Before you begin, ensure you have:

- [x] **Docker Desktop** (Mac/Windows) or **Docker Engine** (Linux)
- [x] **Docker Compose** (included with Docker Desktop)
- [x] At least **8GB RAM** available for Docker
- [x] **20GB free disk space** for images and volumes

!!! tip "Check Docker Installation"
    ```bash
    docker --version
    docker-compose --version
    ```

    Both commands should return version numbers. If not, [install Docker](https://docs.docker.com/get-docker/) first.

---

## Step 1: Clone the Repository

```bash
git clone https://github.com/shawntz/datasci-homelab
cd datasci-homelab
```

---

## Step 2: Run the Setup Script

The setup script creates necessary directories and configuration files:

```bash
./scripts/setup.sh
```

This script:

- Creates the `volumes/` directory structure for persistence
- Copies `.env.example` to `.env` for configuration
- Initializes the R package library volume
- Sets correct permissions

---

## Step 3: Configure Your Environment

Edit the `.env` file to set your credentials:

```bash
nano .env  # or use your preferred editor
```

**Required settings:**

```ini
# Authentication
RSTUDIO_PASSWORD=your-secure-password
JUPYTER_TOKEN=your-secure-token

# Optional: Custom username (default: rstudio)
RSTUDIO_USER=your-username
```

!!! warning "Security Note"
    The `.env` file contains secrets and is excluded from git. Never commit it to version control.

---

## Step 4: Pull the Docker Image

The pre-built image is available from GitHub Container Registry (GHCR) and Docker Hub:

=== "Using docker-compose (Recommended)"

    ```bash
    docker-compose pull
    ```

    This pulls the image specified in `docker-compose.yml` (GHCR by default).

=== "Manual Pull from GHCR"

    ```bash
    docker pull ghcr.io/shawntz/datasci-homelab:latest
    ```

=== "Manual Pull from Docker Hub"

    ```bash
    docker pull shawnschwartz/datasci-homelab:latest
    ```

!!! info "Image Size"
    The image is approximately 4-5GB. Initial pull may take a few minutes depending on your connection.

---

## Step 5: Start the Services

```bash
docker-compose up -d
```

The `-d` flag runs containers in detached mode (background).

**Verify the container is running:**

```bash
docker-compose ps
```

You should see:

```
NAME              STATUS          PORTS
datasci-homelab   Up (healthy)    0.0.0.0:8787->8787, 0.0.0.0:8888->8888
```

---

## Step 6: Access Your Environment

Open your browser and navigate to:

| Service | URL | Credentials |
|---------|-----|-------------|
| RStudio Server | [http://localhost:8787](http://localhost:8787) | Username from `.env`, password from `.env` |
| JupyterLab | [http://localhost:8888](http://localhost:8888) | Token from `.env` |

---

## Verify Everything Works

### Test RStudio

1. Open [http://localhost:8787](http://localhost:8787)
2. Log in with your credentials
3. In the console, run:

```r
library(tidyverse)
ggplot(mtcars, aes(mpg, hp)) + geom_point()
```

You should see a scatter plot in the Plots pane.

### Test JupyterLab

1. Open [http://localhost:8888](http://localhost:8888)
2. Enter your token
3. Create a new Python notebook and run:

```python
import pandas as pd
import matplotlib.pyplot as plt

df = pd.DataFrame({'x': range(10), 'y': range(10)})
df.plot(x='x', y='y')
plt.show()
```

You should see a line plot.

### Test R Kernel in Jupyter

1. In JupyterLab, create a new notebook with the "R" kernel
2. Run:

```r
library(ggplot2)
ggplot(iris, aes(Sepal.Length, Sepal.Width, color = Species)) +
  geom_point()
```

---

## Common Commands

```bash
# Start services
docker-compose up -d

# Stop services (data persists)
docker-compose down

# View logs
docker-compose logs -f

# Restart services
docker-compose restart

# Check status
docker-compose ps
```

---

## Next Steps

<div class="feature-grid" markdown>

<div class="feature-card" markdown>
### :material-package: Install Packages
Learn how to install and persist R and Python packages.

[Usage Guide →](usage.md)
</div>

<div class="feature-card" markdown>
### :material-cog: Customize
Configure themes, keybindings, and preferences.

[Customization →](customization.md)
</div>

<div class="feature-card" markdown>
### :material-cloud: Remote Access
Set up Cloudflare Tunnel for remote access.

[Remote Access →](remote-access.md)
</div>

<div class="feature-card" markdown>
### :material-information: Learn More
Understand the architecture and design decisions.

[Architecture →](architecture.md)
</div>

</div>

---

## Troubleshooting

### Container won't start

```bash
# Check logs for errors
docker-compose logs

# Common fixes:
# - Port already in use: Change ports in .env
# - Permission denied: Run chmod -R 755 volumes/
# - Out of memory: Allocate more RAM to Docker
```

### Can't access the web interface

1. Verify the container is running: `docker-compose ps`
2. Check if ports are exposed: `docker port datasci-homelab`
3. Try accessing via `127.0.0.1` instead of `localhost`

### Authentication not working

```bash
# Reset RStudio password
docker-compose exec homelab passwd $RSTUDIO_USER

# Get Jupyter token from logs
docker-compose logs homelab | grep token
```

For more issues, see the [Troubleshooting Guide](troubleshooting.md).
