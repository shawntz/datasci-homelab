#!/bin/bash
# Entrypoint wrapper that runs as root to set password, then switches to rstudio user
set -e

# Set RStudio password if provided (running as root)
if [ -n "${RSTUDIO_PASSWORD}" ]; then
    echo "Setting RStudio password..."
    echo "rstudio:${RSTUDIO_PASSWORD}" | chpasswd
fi

# Switch to rstudio user and run the original startup script
exec su -s /bin/bash -c "/usr/local/bin/start-services.sh $*" rstudio
