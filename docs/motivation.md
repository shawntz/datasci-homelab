# Motivation

Why build yet another data science environment? This page explains the problems this project solves and the philosophy behind its design.

---

## The Problem with Local Installations

If you've done data science work for any length of time, you've probably experienced these pain points:

### Dependency Hell

```
Error: package 'xyz' was installed under R version 4.2.0
```

Your operating system ships one version of R. Homebrew installs another. RStudio wants a third. Python's situation is even worse — system Python, Homebrew Python, pyenv, conda, virtualenv... the combinations are endless.

When something breaks, you're left debugging your *environment* instead of doing actual work.

### The "It Works on My Machine" Problem

You write a brilliant analysis. You share it with a colleague. They can't run it because:

- They have a different OS
- They're missing a system library
- Their package versions don't match
- Something is configured differently

Reproducing your environment on another machine often takes longer than writing the code did.

### Polluting Your Main System

Every data science project brings its own dependencies. Over time, your laptop accumulates:

- Multiple R versions
- Conflicting Python environments
- System libraries you installed once for one package
- Configuration files scattered across your home directory

Eventually, something breaks in a way you can't fix without nuking everything and starting over.

### Remote Access Limitations

RStudio Desktop and JupyterLab are designed for local use. If you want to:

- Work from a different computer
- Access your environment from a tablet
- Let a colleague look at your code
- Run long jobs on a more powerful machine

...you need to set up RStudio Server or JupyterHub, which is its own project.

---

## The Container Solution

Docker containers solve these problems elegantly:

| Problem | Container Solution |
|---------|-------------------|
| Dependency conflicts | Each container is isolated |
| Reproducibility | Same image runs identically everywhere |
| System pollution | Nothing installed on host |
| Remote access | Built-in web interface |

But running RStudio Server or JupyterLab in Docker has traditionally been painful:

- **Separate containers** — Most setups run RStudio and Jupyter in different containers, complicating shared data and context switching
- **Lost packages** — By default, packages are lost when containers restart
- **Configuration complexity** — You need to understand Docker volumes, networking, and permissions
- **Architecture issues** — Many images don't support ARM64 (Apple Silicon)

---

## What This Project Does Differently

### One Container, Two IDEs

Instead of orchestrating multiple containers, DataSci Homelab runs both RStudio Server and JupyterLab in a single container. They share:

- The same filesystem
- The same user account
- The same installed packages (R and Python)
- The same `/data` directory

Switch between them by changing browser tabs.

### True Package Persistence

Packages are stored in Docker volumes that persist across:

- Container restarts
- Container rebuilds
- Image updates

Install a package once; it's there until you explicitly remove the volume.

### Pre-Configured Everything

The image ships with:

- All common data science packages pre-installed
- Sensible default configurations
- Health checks for reliability
- Authentication options for security

Pull and run. No configuration required.

### Native Multi-Architecture

Built natively for both AMD64 and ARM64. If you're on Apple Silicon, you get a native image — no Rosetta emulation, no performance penalty.

### Remote-Ready by Default

RStudio Server and JupyterLab are web applications. Access them from:

- Your laptop
- Your phone
- A different computer
- Anywhere in the world (with Cloudflare Tunnel)

---

## Design Philosophy

### Batteries Included, But Swappable

The base image includes everything you need for common data science work. But nothing prevents you from:

- Installing additional packages at runtime
- Mounting your own configuration files
- Building on top of this image for specialized needs

### Persistence Over Reproducibility (For Packages)

Typical Docker wisdom says: "put everything in the image." But data scientists install packages constantly. Rebuilding an image every time you need a new package is impractical.

DataSci Homelab separates:

- **The base environment** (in the image) — R, Python, RStudio, Jupyter
- **Your packages** (in volumes) — Install once, persist forever

### Local-First, Remote-Optional

The primary use case is running on your own machine. But the same setup works for:

- A home server
- A cloud VM
- A Kubernetes pod

The Cloudflare Tunnel integration is documented but not required.

### Opinionated Defaults, Easy Overrides

The default configuration reflects best practices for data science work:

- UTF-8 encoding everywhere
- POSIX line endings
- CRAN mirror configured
- Common packages pre-installed

But every default can be overridden via environment variables or mounted config files — no image rebuild required.

---

## Who Built This and Why

This project was built by a data scientist who got tired of:

1. Reinstalling packages every time macOS updated
2. Explaining environment setup to new team members
3. Debugging R/Python version conflicts
4. Not being able to access work from different machines

The goal was simple: **define the environment once, use it everywhere, never think about it again.**

If that resonates with you, welcome aboard.

---


**Ready to try it?**

[:material-download: Get Started](getting-started.md){ .md-button .md-button--primary }
[:material-scale-balance: See the Benefits](benefits.md){ .md-button }

