# Architecture

Technical details of how DataSci Homelab is built and operates.

---

## System Architecture

```mermaid
flowchart TB
    subgraph Host["Host Machine"]
        subgraph Container["Docker Container"]
            RS[RStudio Server\nPort 8787]
            JL[JupyterLab\nPort 8888]
            RS & JL --> ENV[Shared User Environment\nR + Python]
        end

        subgraph Volumes["Docker Volumes"]
            V1["home"]
            V2["r-library"]
            V3["py-packages"]
            V4["data"]
        end

        ENV --> Volumes
    end

    style Container fill:#e1f5fe
    style Volumes fill:#fff3e0
    style Host fill:#f5f5f5
```

---

## Container Structure

### Base Image

Built on Ubuntu 22.04 LTS for:

- Long-term support (until 2027)
- Wide package availability
- Compatibility with R and Python ecosystems

### Layer Breakdown

```mermaid
flowchart LR
    subgraph Image["Docker Image (~8GB)"]
        direction TB
        L1[Layer 1: System packages\n~500MB]
        L2[Layer 2: R installation\n~300MB]
        L3[Layer 3: RStudio Server\n~700MB]
        L4[Layer 4: Python\n~200MB]
        L5[Layer 5: Quarto + TinyTeX\n~500MB]
        L6[Layer 6: R packages\n~1GB]
        L7[Layer 7: Python packages\n~800MB]

        L1 --> L2 --> L3 --> L4 --> L5 --> L6 --> L7
    end

    style L1 fill:#ffccbc
    style L2 fill:#c5cae9
    style L3 fill:#c5cae9
    style L4 fill:#c8e6c9
    style L5 fill:#fff9c4
    style L6 fill:#c5cae9
    style L7 fill:#c8e6c9
```

### Multi-Architecture Support

The image is built for both architectures:

| Architecture | Platforms |
|-------------|-----------|
| `linux/amd64` | Intel/AMD x86_64 |
| `linux/arm64` | Apple Silicon, AWS Graviton |

Built using Docker Buildx with QEMU emulation for cross-compilation.

---

## Service Architecture

### Startup Flow

```mermaid
flowchart TD
    A[Container Start] --> B[entrypoint.sh]
    B -->|Run as root| C[Configure User]

    subgraph Config["Configuration Phase"]
        C --> C1[Create/rename user]
        C --> C2[Set RSTUDIO_PASSWORD]
        C --> C3[Copy RStudio prefs]
    end

    C1 & C2 & C3 --> D[start.sh]
    D -->|Switch to user| E{Service Mode}

    E -->|both| F[RStudio Server]
    E -->|both| G[JupyterLab]
    E -->|rstudio| F
    E -->|jupyter| G

    F & G --> H[Wait for processes]

    style B fill:#ffcc80
    style D fill:#81d4fa
    style F fill:#c5cae9
    style G fill:#ffcc80
```

### Process Management

Both services run as background processes under the same user:

```bash
# RStudio Server
sudo /usr/lib/rstudio-server/bin/rserver --server-daemonize=0 &

# JupyterLab
jupyter lab --config=/etc/jupyter/jupyter_server_config.py &

# Parent process waits
wait
```

The container exits only when both services stop.

---

## Volume Architecture

### Volume Mapping

```mermaid
flowchart LR
    subgraph Host["Host (./volumes/)"]
        H1[home]
        H2[r-library]
        H3[python-packages]
        H4[shared-data]
        H5[config-overrides]
    end

    subgraph Container["Container"]
        C1["/home/rstudio"]
        C2["/usr/local/lib/R/site-library"]
        C3["/home/rstudio/.local"]
        C4["/data"]
        C5["/config-overrides"]
    end

    H1 -.->|mount| C1
    H2 -.->|mount| C2
    H3 -.->|mount| C3
    H4 -.->|mount| C4
    H5 -.->|mount readonly| C5

    style Host fill:#e8f5e9
    style Container fill:#e3f2fd
```

### Why These Locations?

**R Packages (`/usr/local/lib/R/site-library`):**

- R checks this path by default
- Writable without root
- Separate from system packages

**Python Packages (`~/.local`):**

- Default `--user` install location
- Pip automatically uses this
- Persists user-installed packages

**Home Directory (`/home/rstudio`):**

- Contains user preferences
- Contains project files
- Contains shell configuration

---

## Network Architecture

### Port Mapping

```mermaid
flowchart LR
    subgraph External["External Access"]
        B1[Browser :8787]
        B2[Browser :8888]
    end

    subgraph Host["Host"]
        H1[localhost:8787]
        H2[localhost:8888]
    end

    subgraph Container["Container"]
        C1[RStudio Server\n0.0.0.0:8787]
        C2[JupyterLab\n0.0.0.0:8888]
    end

    B1 --> H1 --> C1
    B2 --> H2 --> C2

    style External fill:#fff3e0
    style Host fill:#f5f5f5
    style Container fill:#e3f2fd
```

### With Cloudflare Tunnel

```mermaid
flowchart TD
    A[Internet] --> B[Cloudflare Network]
    B --> C[cloudflared\nRunning on host]
    C --> D[Docker Container\nlocalhost:8787/8888]

    style A fill:#e1f5fe
    style B fill:#fff3e0
    style C fill:#c8e6c9
    style D fill:#e3f2fd
```

---

## Configuration Architecture

### Configuration Priority

```mermaid
flowchart TD
    subgraph Priority["Configuration Priority (highest → lowest)"]
        direction TB
        P1["1. Environment variables (.env)"]
        P2["2. Mounted config files (config-overrides/)"]
        P3["3. User preferences (in volumes)"]
        P4["4. Image defaults (baked in)"]

        P1 --> P2 --> P3 --> P4
    end

    style P1 fill:#c8e6c9
    style P2 fill:#dcedc8
    style P3 fill:#f0f4c3
    style P4 fill:#fff9c4
```

### RStudio Configuration Flow

```mermaid
flowchart TD
    A[Container Start] --> B{rserver.conf exists?}
    B -->|Yes| C[Mount to /etc/rstudio/rserver.conf]
    B -->|No| D[Use image default]

    C & D --> E{rstudio-prefs.json exists?}
    E -->|Yes| F[Copy to ~/.config/rstudio/]
    E -->|No| G[Use default preferences]

    F & G --> H[RStudio Server starts]
    H --> I[User preferences take effect]

    style A fill:#e3f2fd
    style H fill:#c5cae9
    style I fill:#c8e6c9
```

---

## Security Architecture

### User Permissions

```mermaid
flowchart TD
    subgraph Root["root (UID 0)"]
        R1[Runs entrypoint script]
        R2[Sets user password]
        R3[Configures system files]
        R4[Drops privileges]
    end

    subgraph User["rstudio (UID 1000)"]
        U1[Runs RStudio Server via sudo]
        U2[Runs JupyterLab]
        U3[Owns home directory]
        U4[Cannot modify system files]
    end

    R4 --> User

    style Root fill:#ffcdd2
    style User fill:#c8e6c9
```

### Sudo Access

The user has limited sudo access:

```
rstudio ALL=(ALL) NOPASSWD: /usr/lib/rstudio-server/bin/rserver
```

Only the RStudio Server binary can be run as root.

### Authentication Flow

```mermaid
flowchart LR
    subgraph RStudio["RStudio Authentication"]
        direction LR
        R1[User] --> R2[Browser]
        R2 --> R3[RStudio Login]
        R3 --> R4[PAM]
        R4 --> R5["/etc/passwd"]
    end

    subgraph Jupyter["Jupyter Authentication"]
        direction LR
        J1[User] --> J2[Browser]
        J2 --> J3[Token Check]
        J3 --> J4[Jupyter Server]
    end

    style RStudio fill:#e3f2fd
    style Jupyter fill:#fff3e0
```

---

## Build Architecture

### GitHub Actions Workflow

```mermaid
flowchart TD
    A[Push to main] --> B[GitHub Actions]

    B --> C[Build AMD64]
    B --> D[Build ARM64]

    C & D --> E[Create Multi-arch Manifest]

    E --> F[Push to GHCR]
    E --> G[Push to Docker Hub]

    style A fill:#c8e6c9
    style B fill:#fff3e0
    style C fill:#e3f2fd
    style D fill:#e3f2fd
    style E fill:#f3e5f5
    style F fill:#e8eaf6
    style G fill:#e0f2f1
```

### Image Tags

| Tag Pattern | When Created | Purpose |
|-------------|-------------|---------|
| `latest` | Every push to main | Default tag |
| `v1.2.3` | Git tags | Version releases |
| `sha-abc123` | Every commit | Specific builds |
| `main` | Pushes to main | Branch tracking |

---

## Health Check Architecture

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8787"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

### Health States

```mermaid
stateDiagram-v2
    [*] --> Starting
    Starting --> Healthy: start_period (60s)

    Healthy --> Checking: every 30s
    Checking --> Healthy: Success
    Checking --> Retry: Failure

    Retry --> Healthy: Success
    Retry --> Unhealthy: 3 failures

    Unhealthy --> Restarting: restart policy
    Restarting --> Starting
```

---

## Package Installation Flow

### R Package Installation

```mermaid
flowchart TD
    A["install.packages('pkg')"] --> B[Check .libPaths]

    subgraph Paths["Library Paths (checked in order)"]
        P1["1. ~/R/library (if exists)"]
        P2["2. /usr/local/lib/R/site-library"]
        P3["3. /usr/lib/R/library"]
    end

    B --> Paths
    P2 -->|"Volume mounted ✓"| C[Install to site-library]
    C --> D[Package persists in Docker volume]

    style P2 fill:#c8e6c9
    style D fill:#a5d6a7
```

### Python Package Installation

```mermaid
flowchart TD
    A["pip install pkg"] --> B{--user flag?}
    B -->|"Auto in container"| C["Install to ~/.local/lib/python3.x/site-packages/"]
    C --> D[Package persists in Docker volume]

    style C fill:#c8e6c9
    style D fill:#a5d6a7
```

---

## File System Layout

```mermaid
flowchart TD
    subgraph Root["/"]
        subgraph etc["/etc"]
            etc_rs["/etc/rstudio/rserver.conf"]
            etc_jup["/etc/jupyter/jupyter_server_config.py"]
        end

        subgraph usr["/usr"]
            usr_lib["System R packages"]
            usr_local["User R packages (volume)"]
        end

        subgraph home["/home/rstudio"]
            home_config["rstudio-prefs.json"]
            home_local["Python packages (volume)"]
            home_work["Default workdir"]
        end

        data["Shared data (volume)"]
        config["Mounted configs"]
    end

    style usr_local fill:#c8e6c9
    style home fill:#c8e6c9
    style home_local fill:#c8e6c9
    style data fill:#c8e6c9
    style config fill:#fff3e0
```

!!! note "📦 = Volume Mounted"
    Directories marked with 📦 are mounted as Docker volumes and persist across container restarts.
