# Features Overview

Everything included in DataSci Homelab, organized by category.

---

## Base System

| Component | Version | Notes |
|-----------|---------|-------|
| **Operating System** | Ubuntu 22.04 LTS | Long-term support, stable base |
| **Architecture** | AMD64 + ARM64 | Native support, no emulation |
| **Locales** | en_US.UTF-8 | Full Unicode support |
| **Timezone** | America/Los_Angeles | Configurable via env |

---

## R Environment

### Core Installation

| Component | Version |
|-----------|---------|
| **R** | 4.4.2 |
| **RStudio Server** | 2025.12.0 |

### Pre-installed R Packages

=== "Core Data Science"

    | Package | Description |
    |---------|-------------|
    | `tidyverse` | Complete tidyverse ecosystem (dplyr, ggplot2, tidyr, etc.) |
    | `data.table` | High-performance data manipulation |
    | `duckdb` | Embedded analytical database |

=== "Visualization"

    | Package | Description |
    |---------|-------------|
    | `ggthemes` | Additional ggplot2 themes |
    | `wesanderson` | Wes Anderson color palettes |
    | `patchwork` | Combine multiple plots |
    | `scales` | Scale functions for visualization |
    | `showtext` | Custom fonts in plots |
    | `formattable` | Formatted tables |

=== "Statistics & Modeling"

    | Package | Description |
    |---------|-------------|
    | `lme4` | Linear mixed-effects models |
    | `lmerTest` | Tests for lmer models |
    | `emmeans` | Estimated marginal means |
    | `performance` | Model performance metrics |
    | `rstatix` | Pipe-friendly statistics |
    | `broom` | Tidy model outputs |
    | `broom.mixed` | Tidy mixed model outputs |
    | `tidymodels` | Tidyverse modeling framework |

=== "Database"

    | Package | Description |
    |---------|-------------|
    | `DBI` | Database interface |
    | `RPostgres` | PostgreSQL driver |
    | `RMySQL` | MySQL driver |
    | `odbc` | ODBC connections |
    | `dbplyr` | Database backend for dplyr |

=== "Development"

    | Package | Description |
    |---------|-------------|
    | `devtools` | Package development tools |
    | `usethis` | Workflow automation |
    | `renv` | Project environments |
    | `styler` | Code formatting |
    | `lintr` | Code linting |
    | `conflicted` | Handle function conflicts |

=== "Publishing"

    | Package | Description |
    |---------|-------------|
    | `quarto` | Next-gen R Markdown |
    | `tinytex` | Lightweight LaTeX |
    | `rticles` | Article templates |

=== "Utilities"

    | Package | Description |
    |---------|-------------|
    | `pacman` | Package management |
    | `glue` | String interpolation |
    | `here` | Project-relative paths |
    | `janitor` | Data cleaning |
    | `skimr` | Data summaries |
    | `eyeris` | Eye-tracking data processing |

---

## Python Environment

### Core Installation

| Component | Version |
|-----------|---------|
| **Python** | 3.x (system) |
| **pip** | Latest |
| **JupyterLab** | 4.3+ |

### Pre-installed Python Packages

=== "Scientific Computing"

    | Package | Description |
    |---------|-------------|
    | `numpy` | Numerical computing |
    | `pandas` | Data manipulation |
    | `scipy` | Scientific algorithms |
    | `scikit-learn` | Machine learning |

=== "Data Handling"

    | Package | Description |
    |---------|-------------|
    | `pyarrow` | Apache Arrow interface |
    | `polars` | Fast DataFrame library |
    | `duckdb` | Embedded analytics |

=== "Machine Learning"

    | Package | Description |
    |---------|-------------|
    | `xgboost` | Gradient boosting |
    | `lightgbm` | Fast gradient boosting |
    | `statsmodels` | Statistical models |

=== "Visualization"

    | Package | Description |
    |---------|-------------|
    | `matplotlib` | Core plotting |
    | `seaborn` | Statistical visualization |
    | `plotly` | Interactive plots |
    | `pillow` | Image processing |

=== "Jupyter"

    | Package | Description |
    |---------|-------------|
    | `jupyterlab` | Modern Jupyter interface |
    | `notebook` | Classic notebook |
    | `ipykernel` | IPython kernel |
    | `ipywidgets` | Interactive widgets |
    | `jupyterlab-git` | Git integration |
    | `nbdime` | Notebook diffing |

=== "Database"

    | Package | Description |
    |---------|-------------|
    | `psycopg2-binary` | PostgreSQL driver |
    | `pymysql` | MySQL driver |
    | `sqlalchemy` | SQL toolkit |

=== "Utilities"

    | Package | Description |
    |---------|-------------|
    | `rpy2` | R-Python bridge |
    | `python-dotenv` | Environment variables |
    | `tqdm` | Progress bars |
    | `requests` | HTTP library |
    | `beautifulsoup4` | HTML parsing |

---

## Publishing Tools

| Tool | Version | Description |
|------|---------|-------------|
| **Quarto** | 1.8.26 | Universal publishing system |
| **Pandoc** | 3.5 | Document converter |
| **TinyTeX** | Latest | Minimal LaTeX distribution |

### Quarto Features

- Render to HTML, PDF, Word, presentations
- Works with both R and Python
- Integrated with RStudio and Jupyter
- Cross-reference support
- Citation management

---

## System Tools

### Editors

| Tool | Description |
|------|-------------|
| `vim` | Terminal text editor |
| `nano` | Simple text editor |

### Development

| Tool | Description |
|------|-------------|
| `git` | Version control |
| `build-essential` | C/C++ compiler toolchain |
| `gfortran` | Fortran compiler |
| `cmake` | Build system |

### Fonts

| Font | Use Case |
|------|----------|
| Liberation fonts | Document rendering |
| DejaVu fonts | Terminal/code |
| Lato | Custom documents |
| SF Mono | RStudio editor (via preferences) |

---

## RStudio Configuration

### Default Preferences

The following preferences are applied automatically:

```json
{
  "editor_keybindings": "vim",
  "editor_theme": "Xcode",
  "font_size_points": 13,
  "server_editor_font": "SF Mono",
  "relative_line_numbers": true,
  "rainbow_parentheses": true,
  "reformat_on_save": true,
  "auto_save_on_blur": true
}
```

See [Customization](customization.md) for how to modify these.

---

## JupyterLab Configuration

### Default Settings

- Token-based authentication
- Git extension enabled
- Notebook diffing enabled
- Interactive widgets support

### Available Kernels

| Kernel | Language |
|--------|----------|
| Python 3 | Python |
| R | R (via IRkernel) |

---

## Volume Persistence

| Path | Purpose | Persisted |
|------|---------|-----------|
| `/home/rstudio` | User home directory | ✓ |
| `/usr/local/lib/R/site-library` | R packages | ✓ |
| `/home/rstudio/.local` | Python user packages | ✓ |
| `/data` | Shared data | ✓ |

---

## Networking

| Port | Service |
|------|---------|
| 8787 | RStudio Server |
| 8888 | JupyterLab |

Both services are available on `0.0.0.0` (all interfaces) within the container.

---

## Health Checks

The container includes health checks:

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8787"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 60s
```

This ensures:

- Automatic restart on failure
- Docker Compose health status
- Proper startup sequencing

---

## What's NOT Included

Intentionally excluded to keep the image focused:

- **GPU/CUDA support** — Use cloud instances for GPU workloads
- **Database servers** — Connect to external databases
- **Apache Spark** — Use dedicated Spark clusters
- **Deep learning frameworks** — Install as needed (TensorFlow, PyTorch)

These can be added via:

1. Installing at runtime (packages persist in volumes)
2. Building a custom image based on this one
3. Using Docker Compose to add additional services
