# DataSci Homelab

A complete, containerized data science environment with **RStudio Server** and **JupyterLab** — ready to deploy anywhere.

---

<div class="feature-grid" markdown>

<div class="feature-card" markdown>
### :material-docker: 1 Container, 2 IDEs
Run both RStudio Server and JupyterLab from a single Docker container. Switch between R and Python workflows seamlessly.
</div>

<div class="feature-card" markdown>
### :material-package-variant: Persistent Packages
Install packages once, keep them forever. Volumes persist your R and Python libraries across container restarts and rebuilds.
</div>

<div class="feature-card" markdown>
### :material-cog-sync: Zero Configuration
Pre-configured with sensible defaults. Pull the image, start the container, and you're ready to work.
</div>

<div class="feature-card" markdown>
### :material-chip: Multi-Architecture
Native support for both AMD64 (Intel/AMD) and ARM64 (Apple Silicon). No emulation, no performance penalty.
</div>

</div>

---

## Why Not Just Use RStudio Desktop?

Here's a secret: **RStudio Desktop is just an Electron app** — a web browser wrapped in a native window. You're already using a browser to run RStudio, it's just hidden from you.

So why install and maintain a separate application when you can:

- **Open RStudio as a browser tab** — or install it as a Progressive Web App (PWA) for a native-like experience
- **Clean up your dock** — no more juggling RStudio, VS Code, and other IDE icons
- **Skip the installers** — no downloading `.dmg` files, no "drag to Applications," no update prompts
- **Containerize everything** — R, Python, packages, and configurations all managed in one place

With RStudio Server running in Docker, you get the exact same interface with none of the desktop app baggage. Your browser becomes your IDE, and Docker handles the rest.

!!! tip "Pro tip: Install as PWA"
    In Chrome or Edge, click the install icon in the address bar to add RStudio Server as a standalone app. You get a dedicated window, dock icon, and cmd+tab switching — without actually installing anything.

---

## What's Included

=== "RStudio Server"

    - **R 4.5.2** with full development tools
    - **Tidyverse** ecosystem pre-installed
    - **Quarto** for reproducible publishing
    - **TinyTeX** for LaTeX/PDF output
    - Database connectors (PostgreSQL, MySQL, DuckDB)
    - Vim keybindings and custom theming

=== "JupyterLab"

    - **JupyterLab 4.3+** with modern interface
    - **Python 3.10** with scientific stack
    - **R kernel** via IRkernel
    - Git integration and diff tools
    - Interactive widgets support

=== "Shared Tools"

    - **Git** for version control
    - **Quarto** for both R and Python
    - Shared `/data` directory
    - Health checks and auto-restart
    - Cloudflare Tunnel ready

---

## Quick Start

```bash
# Clone the repository
git clone https://github.com/shawntz/datasci-homelab
cd datasci-homelab

# Run setup script
./scripts/setup.sh

# Pull and start
docker-compose pull
docker-compose up -d
```

Then open:

- **RStudio**: [http://localhost:8787](http://localhost:8787)
- **JupyterLab**: [http://localhost:8888](http://localhost:8888)

[:material-rocket-launch: Full Installation Guide](getting-started.md){ .md-button .md-button--primary }
[:material-book-open-variant: Why This Exists](motivation.md){ .md-button }

---

## Who Is This For?

**Data scientists and researchers** who want:

- A reproducible environment that works the same everywhere
- Freedom from dependency conflicts on their main machine
- Easy remote access from any device
- Quick setup for new team members or machines
- The flexibility to work in R, Python, or both

**Not recommended for:**

- Production workloads (this is a development environment)
- Situations requiring GPU compute (use cloud instances instead)
- Users who need only one IDE and prefer native installation

---

## Project Goals

1. **Single source of truth** — One repo defines your entire data science environment
2. **Reproducibility** — Same environment on Mac, Linux, or cloud
3. **Persistence** — Never lose installed packages again
4. **Simplicity** — Works out of the box, customizable when needed
5. **Portability** — Access from anywhere via Cloudflare Tunnel

---

## At a Glance

| Component | Version |
|-----------|---------|
| Base OS | Ubuntu 22.04 LTS |
| R | 4.5.2 |
| RStudio Server | 2025.12.0 |
| Python | 3.10 |
| JupyterLab | 4.3+ |
| Quarto | 1.8.26 |

---

<div style="text-align: center; margin-top: 3rem;">

**Ready to get started?**

[:material-download: Installation Guide](getting-started.md){ .md-button .md-button--primary }

</div>
