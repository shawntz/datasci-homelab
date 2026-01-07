# Daily Workflow

How to use DataSci Homelab in your daily data science work.

---

## Starting Your Day

```bash
# Start the environment
docker-compose up -d

# Check it's running
docker-compose ps
```

Then open:

- [http://localhost:8787](http://localhost:8787) for RStudio
- [http://localhost:8888](http://localhost:8888) for JupyterLab

---

## Working with Projects

### Creating a New Project

=== "In RStudio"

    1. File → New Project → New Directory
    2. Choose project type
    3. Set location to `/home/rstudio/projects/`
    4. Create Project

=== "In JupyterLab"

    1. Navigate to your projects folder
    2. Click the New Folder button
    3. Create notebooks and files

### Recommended Structure

```
/home/rstudio/
├── projects/
│   ├── project-1/
│   │   ├── data/
│   │   ├── scripts/
│   │   ├── output/
│   │   └── project-1.Rproj
│   └── project-2/
├── notebooks/
│   └── exploration.ipynb
└── shared/
    └── common-scripts/
```

---

## Installing Packages

### R Packages

```r
# Single package
install.packages("packagename")

# Multiple packages
install.packages(c("pkg1", "pkg2", "pkg3"))

# From GitHub
devtools::install_github("user/repo")

# From Bioconductor
BiocManager::install("packagename")
```

### Python Packages

```bash
# In terminal or notebook
pip install packagename

# Specific version
pip install packagename==1.2.3

# From requirements file
pip install -r requirements.txt
```

!!! success "Packages Persist"
    All packages are stored in Docker volumes and persist across container restarts.

---

## Working with Data

### The Shared Data Directory

Both RStudio and JupyterLab can access `/data`:

```r
# R
data <- read_csv("/data/myfile.csv")
write_csv(results, "/data/output.csv")
```

```python
# Python
import pandas as pd
df = pd.read_csv("/data/myfile.csv")
df.to_csv("/data/output.csv", index=False)
```

### Adding Data from Host

Data placed in `./volumes/shared-data/` on your host is available at `/data` in the container:

```bash
# On your host machine
cp ~/Downloads/dataset.csv ./volumes/shared-data/
```

Then in the container:

```r
data <- read_csv("/data/dataset.csv")
```

---

## Switching Between R and Python

### Same Project, Different Languages

Your home directory is shared between RStudio and JupyterLab:

1. Create project files in RStudio
2. Open the same directory in JupyterLab
3. Work with `.ipynb` and `.R` files interchangeably

### Using R in Jupyter

1. Create a new notebook
2. Select "R" kernel
3. Write R code as normal

### Using Python in RStudio

Open Terminal in RStudio:

```bash
python script.py
```

Or use `reticulate`:

```r
library(reticulate)
py_run_string("print('Hello from Python!')")
```

---

## Version Control

### Git Setup (First Time)

=== "In RStudio"

    ```r
    usethis::use_git_config(
      user.name = "Your Name",
      user.email = "your@email.com"
    )
    ```

=== "In Terminal"

    ```bash
    git config --global user.name "Your Name"
    git config --global user.email "your@email.com"
    ```

### Daily Git Workflow

=== "RStudio Git Pane"

    1. Make changes to files
    2. Click files in Git pane to stage
    3. Click "Commit" and write message
    4. Click "Push" to upload

=== "JupyterLab Git"

    1. Open Git panel (left sidebar)
    2. Stage changes with +
    3. Write commit message
    4. Click commit, then push

=== "Terminal"

    ```bash
    git add .
    git commit -m "Your message"
    git push
    ```

---

## Rendering Documents

### Quarto Documents

=== "RStudio"

    Click "Render" button or:
    ```r
    quarto::quarto_render("document.qmd")
    ```

=== "Terminal"

    ```bash
    quarto render document.qmd
    quarto render document.qmd --to pdf
    ```

### R Markdown

```r
rmarkdown::render("document.Rmd")
```

### Jupyter to HTML/PDF

```bash
quarto render notebook.ipynb
jupyter nbconvert --to html notebook.ipynb
```

---

## Long-Running Jobs

### Background Execution in R

```r
# Using callr for background jobs
library(callr)

job <- r_bg(function() {
  # Long running code
  Sys.sleep(3600)
  return("Done!")
})

# Check status
job$is_alive()

# Get result when done
job$get_result()
```

### Background Execution in Python

```python
import subprocess

# Run in background
process = subprocess.Popen(['python', 'long_script.py'])

# Check later
process.poll()  # Returns None if still running
```

### Using Terminal

```bash
# Run with nohup to continue after disconnect
nohup Rscript long_script.R > output.log 2>&1 &

# Check progress
tail -f output.log
```

---

## Backing Up Your Work

### Manual Backup

```bash
# From host machine
tar -czf backup-$(date +%Y%m%d).tar.gz volumes/
```

### Package Lists

```bash
# Run the backup script
./scripts/backup-packages.sh
```

This creates:

- `r_packages_TIMESTAMP.csv` - R packages
- `python_packages_TIMESTAMP.txt` - Python packages

---

## Ending Your Day

```bash
# Stop containers (data persists)
docker-compose down

# Or just stop without removing
docker-compose stop
```

!!! info "Data Safety"
    Using `down` or `stop` preserves all your data in volumes. Only `down -v` removes volumes.

---

## Common Tasks

### Update System Packages

```bash
# Enter container as root
docker-compose exec -u root homelab bash

# Update
apt-get update && apt-get upgrade -y

# Exit
exit
```

### Restart Services

```bash
# Restart everything
docker-compose restart

# Restart just the container
docker restart datasci-homelab
```

### Check Logs

```bash
# All logs
docker-compose logs

# Follow logs
docker-compose logs -f

# Last 100 lines
docker-compose logs --tail=100
```

### Clean Up

```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Full cleanup (careful!)
docker system prune
```

---

## Tips for Efficiency

### 1. Use Keyboard Shortcuts

Both RStudio and JupyterLab have extensive keyboard shortcuts. Learn the common ones:

- `Ctrl+Enter` - Run current line/cell
- `Ctrl+Shift+Enter` - Run all
- `Ctrl+S` - Save

### 2. Split Your Screen

Open RStudio on one half, JupyterLab on the other for polyglot workflows.

### 3. Use the Terminal

Both IDEs have integrated terminals. Use them for:

- Git operations
- File management
- Running scripts

### 4. Keep Data in `/data`

Store datasets in the shared data directory for easy access from both environments.

### 5. Commit Often

With the integrated Git tools, there's no excuse. Small, frequent commits.
