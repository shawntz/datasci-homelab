"""JupyterLab Server Configuration with Authentication"""
import os

c = get_config()  # noqa: F821

# Authentication - use token from environment variable
jupyter_token = os.environ.get('JUPYTER_TOKEN', '')
if jupyter_token:
    c.ServerApp.token = jupyter_token
    c.ServerApp.password = ""
else:
    # If no token set, disable auth (fallback)
    c.ServerApp.token = ""
    c.ServerApp.password = ""

c.ServerApp.disable_check_xsrf = False

# Network configuration
c.ServerApp.ip = "0.0.0.0"
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.allow_root = False

# Allow remote origin
c.ServerApp.allow_origin = "*"
c.ServerApp.allow_remote_access = True

# Disable rate limiting
c.ServerApp.rate_limit_window = 0

# Set the default URL
c.ServerApp.default_url = "/lab"

# Notebook settings
c.NotebookApp.notebook_dir = "/home/rstudio/work"
