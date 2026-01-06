# Troubleshooting

Solutions to common issues with DataSci Homelab.

---

## Quick Diagnostics

Run these commands to diagnose issues:

```bash
# Check container status
docker-compose ps

# View recent logs
docker-compose logs --tail=100

# Check container health
docker inspect datasci-homelab --format='{{.State.Health.Status}}'

# Test services inside container
docker-compose exec homelab curl -s http://localhost:8787 | head
docker-compose exec homelab curl -s http://localhost:8888 | head
```

---

## Container Issues

### Container Won't Start

**Symptom:** `docker-compose up` fails or container exits immediately.

**Check logs:**
```bash
docker-compose logs
```

**Common causes:**

=== "Port Already in Use"

    ```
    Error: bind: address already in use
    ```

    **Fix:** Change ports in `.env`:
    ```ini
    RSTUDIO_PORT=8780
    JUPYTER_PORT=8880
    ```

=== "Out of Memory"

    ```
    Error: cannot allocate memory
    ```

    **Fix:** Increase Docker memory allocation:
    - Docker Desktop → Settings → Resources → Memory → Increase to 8GB+

=== "Permission Denied"

    ```
    Error: permission denied
    ```

    **Fix:**
    ```bash
    chmod -R 755 volumes/
    chmod +x scripts/*.sh
    ```

=== "Image Not Found"

    ```
    Error: manifest unknown
    ```

    **Fix:**
    ```bash
    docker-compose pull
    ```

### Container Keeps Restarting

**Check why it's failing:**
```bash
docker-compose logs --tail=50
```

**Common causes:**

- Service crash inside container
- Health check failing
- Resource exhaustion

**Fix:** Try running without health check:
```bash
docker-compose run --rm --no-healthcheck homelab
```

### Container Running But Services Not Accessible

**Verify services are listening:**
```bash
docker-compose exec homelab ss -tlnp
```

Expected output shows ports 8787 and 8888 listening.

**Check port mapping:**
```bash
docker port datasci-homelab
```

---

## RStudio Issues

### RStudio Login Fails

**Symptom:** Correct password rejected.

**Reset password:**
```bash
docker-compose exec homelab bash -c 'echo "$RSTUDIO_USER:newpassword" | sudo chpasswd'
```

**Check current user:**
```bash
docker-compose exec homelab whoami
docker-compose exec homelab echo $RSTUDIO_USER
```

### RStudio Blank Screen

**Clear session data:**
```bash
rm -rf volumes/home/.local/share/rstudio/sessions/*
rm -rf volumes/home/.rstudio/
docker-compose restart
```

### RStudio "Unable to Connect to Service"

**Check RStudio process:**
```bash
docker-compose exec homelab pgrep -a rserver
```

**Restart RStudio only:**
```bash
docker-compose exec -u root homelab pkill rserver
docker-compose exec homelab sudo /usr/lib/rstudio-server/bin/rserver &
```

### Package Installation Fails

**Missing system dependency:**
```r
# Error message like:
# ERROR: configuration failed for package 'xxx'
# package 'xxx' requires 'libyyy'
```

**Fix:**
```bash
docker-compose exec -u root homelab apt-get update
docker-compose exec -u root homelab apt-get install -y libyyy-dev
```

**Then retry installation in R.**

### Packages Not Persisting

**Check volume mount:**
```bash
docker-compose exec homelab ls -la /usr/local/lib/R/site-library/
```

**Verify .libPaths() includes the volume:**
```r
.libPaths()
# Should include: /usr/local/lib/R/site-library
```

---

## Jupyter Issues

### Jupyter Token Not Working

**Get current token:**
```bash
docker-compose exec homelab jupyter server list
```

**Or check logs:**
```bash
docker-compose logs homelab | grep -i token
```

**Set a new token:**
Update `JUPYTER_TOKEN` in `.env` and restart:
```bash
docker-compose down
docker-compose up -d
```

### Kernel Not Starting

**List available kernels:**
```bash
docker-compose exec homelab jupyter kernelspec list
```

**Reinstall Python kernel:**
```bash
docker-compose exec homelab python -m ipykernel install --user --name python3
```

**Reinstall R kernel:**
```bash
docker-compose exec homelab Rscript -e "IRkernel::installspec(user = TRUE)"
```

### Jupyter Extensions Not Loading

**Rebuild JupyterLab:**
```bash
docker-compose exec homelab jupyter lab build
```

**Check extension status:**
```bash
docker-compose exec homelab jupyter labextension list
```

### Notebook Won't Save

**Check permissions:**
```bash
docker-compose exec homelab ls -la /home/rstudio/
```

**Fix permissions:**
```bash
docker-compose exec -u root homelab chown -R rstudio:rstudio /home/rstudio/
```

---

## Volume Issues

### Data Disappeared

**Volumes only deleted with `-v` flag:**
```bash
docker-compose down    # Data persists
docker-compose down -v # Data deleted!
```

**Check volumes exist:**
```bash
ls -la volumes/
```

**Recover from backup:**
```bash
tar -xzf backup.tar.gz
```

### Volume Permissions Wrong

**Symptom:** "Permission denied" when accessing files.

**Fix:**
```bash
docker-compose exec -u root homelab chown -R rstudio:rstudio /home/rstudio/
docker-compose exec -u root homelab chown -R rstudio:rstudio /usr/local/lib/R/site-library/
```

### Volume Mount Not Working

**Verify mount points:**
```bash
docker-compose exec homelab df -h
docker-compose exec homelab mount | grep volumes
```

**Check docker-compose.yml syntax:**
```yaml
volumes:
  - ./volumes/home:/home/rstudio  # Note the ./ prefix
```

---

## Network Issues

### Can't Access from Other Devices

**By default, only accessible from localhost.**

**Allow LAN access:** Edit `.env`:
```ini
RSTUDIO_PORT=0.0.0.0:8787:8787
```

Or modify docker-compose.yml:
```yaml
ports:
  - "0.0.0.0:8787:8787"
```

### Firewall Blocking Access

**macOS:**
- System Preferences → Security → Firewall → Allow Docker

**Linux:**
```bash
sudo ufw allow 8787
sudo ufw allow 8888
```

### Slow Connection

**Check if health checks are failing:**
```bash
docker inspect datasci-homelab --format='{{json .State.Health}}'
```

**Reduce logging:**
```bash
docker-compose logs --tail=10  # Fewer lines
```

---

## Performance Issues

### RStudio/Jupyter Slow

**Check resource usage:**
```bash
docker stats datasci-homelab
```

**Increase resources in Docker Desktop:**
- Memory: 8GB minimum, 16GB recommended
- CPUs: 4+ recommended

**Check for runaway processes:**
```bash
docker-compose exec homelab top
```

### High Disk Usage

**Check volume sizes:**
```bash
du -sh volumes/*
```

**Clean package cache:**
```bash
# R package cache
docker-compose exec homelab rm -rf /tmp/Rtmp*

# Python package cache
docker-compose exec homelab pip cache purge
```

---

## Recovery Procedures

### Complete Reset (Last Resort)

!!! danger "This Deletes All Data"
    Only use if nothing else works.

```bash
# Stop everything
docker-compose down -v

# Remove volumes directory
rm -rf volumes/

# Re-run setup
./scripts/setup.sh

# Pull fresh image
docker-compose pull

# Start fresh
docker-compose up -d
```

### Partial Reset (Keep Data)

```bash
# Stop container
docker-compose down

# Remove container (not volumes)
docker rm datasci-homelab

# Pull fresh image
docker-compose pull

# Start fresh container with existing volumes
docker-compose up -d
```

### Export Data Before Reset

```bash
# Backup everything
tar -czf full-backup.tar.gz volumes/

# Backup just home directory
tar -czf home-backup.tar.gz volumes/home/

# Backup package lists
./scripts/backup-packages.sh
```

---

## Getting Help

### Information to Include

When asking for help, include:

1. **Docker version:** `docker --version`
2. **Compose version:** `docker-compose --version`
3. **OS and architecture:** `uname -a`
4. **Container logs:** `docker-compose logs --tail=100`
5. **Container status:** `docker-compose ps`
6. **Error messages:** Exact text, not paraphrased

### Where to Get Help

- [GitHub Issues](https://github.com/shawntz/datasci-homelab/issues)
- Search existing issues first
- Provide reproduction steps

### Debug Mode

Run container in foreground to see all output:

```bash
docker-compose up  # No -d flag
```

Run a shell inside the container:

```bash
docker-compose exec homelab bash
```

Run as root for debugging:

```bash
docker-compose exec -u root homelab bash
```
