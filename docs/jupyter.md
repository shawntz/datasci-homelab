# JupyterLab

Deep dive into the JupyterLab configuration and features.

---

## Overview

JupyterLab is the next-generation interface for Jupyter notebooks. In DataSci Homelab, it's configured with:

- Python and R kernels
- Git integration
- Notebook diffing
- Interactive widgets
- Persistent package storage

---

## Accessing JupyterLab

**URL:** [http://localhost:8888](http://localhost:8888)

**Authentication:** Enter the token from your `JUPYTER_TOKEN` in `.env`

---

## Available Kernels

### Python 3

The default Python kernel with the full scientific stack.

```python
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# Your Python code here
```

### R

Use R directly in Jupyter via IRkernel.

```r
library(tidyverse)

ggplot(mtcars, aes(mpg, hp)) +
  geom_point()
```

---

## Package Management

### Python Packages

```python
# Install in a notebook cell
!pip install packagename

# Or with specific version
!pip install packagename==1.2.3
```

Packages are installed to `~/.local/lib/python3.x/site-packages/`, which is volume-mounted for persistence.

### R Packages (in R Kernel)

```r
install.packages("packagename")
```

Uses the same R library as RStudio Server.

### Verifying Installation

```python
# Python
import packagename
print(packagename.__version__)
```

```r
# R
library(packagename)
packageVersion("packagename")
```

---

## Extensions

### Pre-installed Extensions

| Extension | Description |
|-----------|-------------|
| `jupyterlab-git` | Git integration panel |
| `nbdime` | Notebook diffing and merging |
| `ipywidgets` | Interactive widgets |

### Git Extension

Access via the Git icon in the left sidebar:

1. **Clone** repositories
2. **Stage/unstage** changes
3. **Commit** with messages
4. **Push/pull** to remotes
5. **View history** and diffs

### Using Widgets

```python
import ipywidgets as widgets

slider = widgets.IntSlider(
    value=50,
    min=0,
    max=100,
    description='Value:'
)
display(slider)
```

---

## Working with Files

### File Browser

The left sidebar file browser shows:

- `/home/rstudio/` - Your home directory
- `/data/` - Shared data directory

### Uploading Files

1. Click the upload button in the file browser
2. Or drag-and-drop files directly

### Downloading Files

Right-click on any file → Download

---

## Data Science Workflows

### Loading Data

```python
import pandas as pd

# From CSV
df = pd.read_csv('/data/myfile.csv')

# From shared directory
df = pd.read_csv('/data/shared/dataset.csv')

# From Parquet (fast!)
df = pd.read_parquet('/data/large_dataset.parquet')
```

### Visualization

=== "Matplotlib"

    ```python
    import matplotlib.pyplot as plt

    plt.figure(figsize=(10, 6))
    plt.plot(df['x'], df['y'])
    plt.xlabel('X axis')
    plt.ylabel('Y axis')
    plt.title('My Plot')
    plt.show()
    ```

=== "Seaborn"

    ```python
    import seaborn as sns

    sns.set_theme()
    sns.scatterplot(data=df, x='x', y='y', hue='category')
    ```

=== "Plotly"

    ```python
    import plotly.express as px

    fig = px.scatter(df, x='x', y='y', color='category')
    fig.show()
    ```

### Database Connections

```python
from sqlalchemy import create_engine
import pandas as pd

# PostgreSQL
engine = create_engine('postgresql://user:pass@host:5432/dbname')

# Query to DataFrame
df = pd.read_sql("SELECT * FROM table", engine)

# DuckDB (embedded)
import duckdb
con = duckdb.connect('mydata.duckdb')
df = con.execute("SELECT * FROM table").df()
```

---

## R-Python Integration

Use rpy2 to mix R and Python in the same notebook:

```python
%load_ext rpy2.ipython
```

```python
%%R
library(ggplot2)
ggplot(mtcars, aes(mpg, hp)) + geom_point()
```

```python
# Pass data from Python to R
%%R -i df
summary(df)
```

---

## Quarto in Jupyter

Create Quarto documents from Jupyter notebooks:

### Method 1: Convert Notebook

```bash
quarto render notebook.ipynb --to html
quarto render notebook.ipynb --to pdf
```

### Method 2: Native Quarto

Create `.qmd` files and open them in JupyterLab's text editor, then render:

```bash
quarto render document.qmd
```

---

## Keyboard Shortcuts

### Command Mode (Blue border)

| Key | Action |
|-----|--------|
| `Enter` | Edit mode |
| `A` | Insert cell above |
| `B` | Insert cell below |
| `D D` | Delete cell |
| `M` | Change to Markdown |
| `Y` | Change to Code |
| `Shift+Enter` | Run and select below |
| `Ctrl+Enter` | Run cell |

### Edit Mode (Green border)

| Key | Action |
|-----|--------|
| `Esc` | Command mode |
| `Tab` | Autocomplete |
| `Shift+Tab` | Show signature |
| `Ctrl+Shift+-` | Split cell |

---

## Configuration

### JupyterLab Settings

Access via Settings → Settings Editor

Common customizations:

- Theme (dark/light)
- Font size
- Auto-save interval
- Keyboard shortcuts

### Server Configuration

The server is configured via `/etc/jupyter/jupyter_server_config.py`:

```python
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.allow_origin = '*'
```

---

## Tips & Tricks

### Magic Commands

```python
# Time a cell
%%time
expensive_operation()

# Time multiple runs
%%timeit
operation()

# Run shell commands
!ls -la

# Environment variables
%env MY_VAR=value

# Load external scripts
%run script.py
```

### Rich Output

```python
# Display multiple outputs
from IPython.display import display

display(df1)
display(df2)
```

### Autoreload

```python
%load_ext autoreload
%autoreload 2

# Now modules reload automatically when changed
import mymodule
```

---

## Troubleshooting

### Kernel Not Starting

```bash
# Check kernel list
docker-compose exec homelab jupyter kernelspec list

# Reinstall Python kernel
docker-compose exec homelab python -m ipykernel install --user

# Reinstall R kernel
docker-compose exec homelab Rscript -e "IRkernel::installspec()"
```

### Token Not Working

```bash
# Check the configured token
docker-compose exec homelab jupyter server list

# Or check logs
docker-compose logs homelab | grep token
```

### Extension Not Working

```bash
# List extensions
docker-compose exec homelab jupyter labextension list

# Rebuild JupyterLab
docker-compose exec homelab jupyter lab build
```

### Notebook Won't Save

Check permissions:

```bash
docker-compose exec homelab ls -la /home/rstudio/
```

If permissions are wrong:

```bash
docker-compose exec homelab chown -R rstudio:rstudio /home/rstudio/
```
