#!/bin/bash
# Entrypoint wrapper that runs as root to set password, then switches to user
set -e

# Default to 'rstudio' if RSTUDIO_USER is not set
RSTUDIO_USER=${RSTUDIO_USER:-rstudio}

# If custom username is requested and it's not 'rstudio', rename the user
if [ "$RSTUDIO_USER" != "rstudio" ]; then
    echo "Creating custom user: $RSTUDIO_USER"
    # Rename the user from rstudio to the custom name
    usermod -l "$RSTUDIO_USER" rstudio || true
    # Rename the group if it exists
    groupmod -n "$RSTUDIO_USER" rstudio 2>/dev/null || true
    # Update home directory name if needed (but keep mount point the same)
    usermod -d "/home/$RSTUDIO_USER" "$RSTUDIO_USER" 2>/dev/null || true
    # Create symlink from old home to new home for compatibility
    if [ ! -L "/home/$RSTUDIO_USER" ] && [ -d "/home/rstudio" ]; then
        ln -sf /home/rstudio "/home/$RSTUDIO_USER" 2>/dev/null || true
    fi
fi

# Set password for the user (custom or default)
if [ -n "${RSTUDIO_PASSWORD}" ]; then
    echo "Setting password for user: $RSTUDIO_USER"
    echo "$RSTUDIO_USER:${RSTUDIO_PASSWORD}" | chpasswd
fi

# Switch to the user and run the original startup script
exec su -s /bin/bash -c "/usr/local/bin/start-services.sh $*" "$RSTUDIO_USER"
