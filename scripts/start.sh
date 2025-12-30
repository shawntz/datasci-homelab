#!/bin/bash
# Startup script for ds-workbench
# Can start RStudio, Jupyter, or both

set -e

MODE="${1:-both}"

echo "=========================================="
echo "  DS Workbench Starting"
echo "=========================================="
echo "Mode: ${MODE}"
echo ""

start_rstudio() {
    echo "Starting RStudio Server on port 8787..."
    sudo /usr/lib/rstudio-server/bin/rserver --server-daemonize=0 &
}

start_jupyter() {
    echo "Starting JupyterLab on port 8888..."
    jupyter lab --config=/etc/jupyter/jupyter_server_config.py &
}

case "${MODE}" in
    rstudio)
        start_rstudio
        ;;
    jupyter)
        start_jupyter
        ;;
    both)
        start_rstudio
        start_jupyter
        ;;
    *)
        echo "Unknown mode: ${MODE}"
        echo "Usage: start.sh [rstudio|jupyter|both]"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "  Services Started"
echo "=========================================="
[ "${MODE}" = "rstudio" ] || [ "${MODE}" = "both" ] && echo "RStudio Server: http://localhost:8787"
[ "${MODE}" = "jupyter" ] || [ "${MODE}" = "both" ] && echo "JupyterLab:     http://localhost:8888"
echo ""

# Wait for processes
wait
