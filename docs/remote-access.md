# Remote Access

Access your DataSci Homelab from anywhere using Cloudflare Tunnel.

---

## Overview

Cloudflare Tunnel creates a secure connection between your homelab and Cloudflare's network, allowing you to access RStudio and JupyterLab from anywhere without:

- Opening ports on your router
- Setting up dynamic DNS
- Managing SSL certificates
- Exposing your home IP address

---

## Prerequisites

- A domain name (can be free from Cloudflare)
- A Cloudflare account (free tier works)
- `cloudflared` CLI installed locally

---

## Setup Guide

### Step 1: Install cloudflared

=== "macOS"

    ```bash
    brew install cloudflared
    ```

=== "Linux"

    ```bash
    # Debian/Ubuntu
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o cloudflared.deb
    sudo dpkg -i cloudflared.deb

    # Or download binary directly
    curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o cloudflared
    chmod +x cloudflared
    sudo mv cloudflared /usr/local/bin/
    ```

=== "Windows"

    Download from [Cloudflare releases](https://github.com/cloudflare/cloudflared/releases)

### Step 2: Authenticate with Cloudflare

```bash
cloudflared tunnel login
```

This opens a browser window. Select the domain you want to use.

### Step 3: Create a Tunnel

```bash
cloudflared tunnel create datasci-homelab
```

This outputs a tunnel ID and creates a credentials file at:
```
~/.cloudflared/<tunnel-id>.json
```

Save the tunnel ID — you'll need it.

### Step 4: Configure DNS

```bash
# Create DNS record for RStudio
cloudflared tunnel route dns datasci-homelab rstudio.yourdomain.com

# Create DNS record for Jupyter
cloudflared tunnel route dns datasci-homelab jupyter.yourdomain.com
```

### Step 5: Create Configuration

Create `~/.cloudflared/config.yml`:

```yaml
tunnel: <your-tunnel-id>
credentials-file: /Users/yourname/.cloudflared/<tunnel-id>.json

ingress:
  - hostname: rstudio.yourdomain.com
    service: http://localhost:8787
  - hostname: jupyter.yourdomain.com
    service: http://localhost:8888
  - service: http_status:404
```

!!! warning "Paths Must Be Absolute"
    Use full paths in the credentials-file field.

### Step 6: Start the Tunnel

```bash
cloudflared tunnel run datasci-homelab
```

### Step 7: Access Remotely

Open in any browser:

- `https://rstudio.yourdomain.com`
- `https://jupyter.yourdomain.com`

---

## Running as a Service

### macOS (launchd)

```bash
sudo cloudflared service install
sudo launchctl start com.cloudflare.cloudflared
```

### Linux (systemd)

```bash
sudo cloudflared service install
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```

Now the tunnel starts automatically on boot.

---

## Security Considerations

### Authentication

!!! danger "Enable Authentication"
    With remote access enabled, **never** run with `DISABLE_AUTH=true`.

Always set strong passwords:

```ini
# .env
RSTUDIO_PASSWORD=very-long-secure-password-here
JUPYTER_TOKEN=another-very-long-secure-token
```

### Cloudflare Access (Recommended)

Add an extra authentication layer via Cloudflare Access:

1. Go to Cloudflare Zero Trust dashboard
2. Create an Access Application
3. Add your domain patterns:
   - `rstudio.yourdomain.com`
   - `jupyter.yourdomain.com`
4. Configure authentication:
   - Email OTP (free)
   - Google/GitHub OAuth
   - Or other identity providers

This adds a login page before users even reach RStudio/Jupyter.

### IP Restrictions

In Cloudflare Access, you can restrict access to:

- Specific countries
- IP ranges
- Only authenticated users

---

## Troubleshooting

### Tunnel Not Connecting

```bash
# Check tunnel status
cloudflared tunnel list
cloudflared tunnel info datasci-homelab

# Test locally first
curl http://localhost:8787
curl http://localhost:8888
```

### 502 Bad Gateway

The service isn't running or accessible:

```bash
# Verify container is running
docker-compose ps

# Check services are listening
docker-compose exec homelab curl http://localhost:8787
```

### Certificate Errors

Cloudflare handles SSL automatically. If you see cert errors:

1. Wait a few minutes for DNS propagation
2. Clear browser cache
3. Try incognito mode

### DNS Not Resolving

```bash
# Check DNS records
dig rstudio.yourdomain.com

# Verify route exists
cloudflared tunnel route list
```

---

## Alternative: SSH Tunneling

If you can't use Cloudflare Tunnel:

### From Remote Machine

```bash
# Forward RStudio
ssh -L 8787:localhost:8787 user@your-server

# Forward both
ssh -L 8787:localhost:8787 -L 8888:localhost:8888 user@your-server
```

Then access `http://localhost:8787` on your local machine.

### Persistent SSH Tunnel

Use `autossh`:

```bash
autossh -M 0 -f -N -L 8787:localhost:8787 user@your-server
```

---

## Alternative: Tailscale

[Tailscale](https://tailscale.com) is another excellent option:

1. Install Tailscale on your server
2. Install Tailscale on your devices
3. Access via Tailscale IP: `http://100.x.x.x:8787`

Benefits:

- No domain required
- Zero configuration
- Works behind NAT
- Free for personal use

---

## Mobile Access

Both RStudio Server and JupyterLab work on mobile browsers:

- **iPad**: Full functionality
- **iPhone/Android**: Works but cramped

For the best mobile experience:

1. Use a tablet
2. Enable authentication
3. Consider Cloudflare Access for extra security

---

## Multi-User Access

If multiple people need access:

### Option 1: Shared Credentials

Everyone uses the same username/password. Simple but no isolation.

### Option 2: Multiple Containers

Run separate containers for each user:

```yaml
# docker-compose-user1.yml
services:
  homelab-user1:
    ports:
      - "8787:8787"
      - "8888:8888"
    environment:
      - RSTUDIO_USER=user1
```

### Option 3: RStudio Server Pro / JupyterHub

For true multi-user with isolation, consider:

- RStudio Server Pro (paid)
- JupyterHub (free, but more complex)

---

## Bandwidth Considerations

Data science workflows can transfer significant data:

| Operation | Typical Size |
|-----------|-------------|
| Loading notebook | 1-10 MB |
| Rendering plot | 0.1-5 MB |
| Large dataset preview | 10-100 MB |
| PDF download | 1-20 MB |

For remote access over slow connections:

- Work with sampled data remotely
- Download full results rather than streaming
- Consider running heavy jobs locally and accessing results remotely
