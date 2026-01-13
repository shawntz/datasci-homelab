# syntax=docker/dockerfile:1
# Multi-platform data science workbench with RStudio and Jupyter
# Supports: linux/amd64, linux/arm64

FROM ubuntu:22.04

# Metadata
LABEL maintainer="Shawn Schwartz"
LABEL description="Multi-platform data science homelab with RStudio Server and JupyterLab"
LABEL org.opencontainers.image.source="https://github.com/shawntz/datasci-homelab"

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    TZ=America/Los_Angeles \
    R_VERSION=4.4.2 \
    RSTUDIO_VERSION=2025.12.0+387 \
    QUARTO_VERSION=1.8.26 \
    PANDOC_VERSION=3.5 \
    DEFAULT_USER=rstudio

# Install system dependencies and locales
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    locales \
    ca-certificates \
    software-properties-common \
    gnupg2 \
    wget \
    curl \
    git \
    unzip \
    zip \
    nano \
    vim \
    less \
    build-essential \
    gfortran \
    gdebi-core \
    pandoc \
    fonts-liberation \
    fonts-dejavu \
    fontconfig \
    sudo \
    && locale-gen en_US.UTF-8 \
    && update-locale LANG=en_US.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install R development libraries
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libgit2-dev \
    libssh2-1-dev \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
    libbz2-dev \
    liblzma-dev \
    libpcre2-dev \
    libreadline-dev \
    libicu-dev \
    pkg-config \
    cmake \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install R from Ubuntu repository (4.4.x available in Ubuntu 22.04)
RUN add-apt-repository -y ppa:c2d4u.team/c2d4u4.0+ && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    r-base \
    r-base-dev \
    r-recommended \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure R
RUN echo "options(repos = c(CRAN = 'https://cloud.r-project.org'), download.file.method = 'libcurl')" >> /usr/lib/R/etc/Rprofile.site && \
    echo "options(Ncpus = parallel::detectCores())" >> /usr/lib/R/etc/Rprofile.site

# Install RStudio Server dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    psmisc \
    lsb-release \
    libclang-dev \
    libpq5 \
    libedit2 \
    libssl3 \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install RStudio Server for ARM64 and AMD64
RUN ARCH=$(dpkg --print-architecture) && \
    echo "Architecture detected: $ARCH" && \
    RSTUDIO_DEB_VERSION=$(echo ${RSTUDIO_VERSION} | tr '+' '-') && \
    if [ "$ARCH" = "arm64" ]; then \
        echo "Downloading RStudio Server for ARM64..." && \
        wget -O rstudio-server.deb "https://s3.amazonaws.com/rstudio-ide-build/server/jammy/arm64/rstudio-server-${RSTUDIO_DEB_VERSION}-arm64.deb" && \
        echo "Installing RStudio Server..." && \
        apt-get update && \
        apt-get install -y -f ./rstudio-server.deb && \
        rm rstudio-server.deb; \
    else \
        echo "Downloading RStudio Server for AMD64..." && \
        wget -O rstudio-server.deb "https://s3.amazonaws.com/rstudio-ide-build/server/jammy/amd64/rstudio-server-${RSTUDIO_DEB_VERSION}-amd64.deb" && \
        echo "Installing RStudio Server..." && \
        apt-get update && \
        apt-get install -y -f ./rstudio-server.deb && \
        rm rstudio-server.deb; \
    fi && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Quarto
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "arm64" ]; then \
        echo "Downloading Quarto for ARM64..." && \
        wget -O quarto.deb https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-arm64.deb && \
        apt-get update && \
        apt-get install -y -f ./quarto.deb && \
        rm quarto.deb; \
    else \
        echo "Downloading Quarto for AMD64..." && \
        wget -O quarto.deb https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb && \
        apt-get update && \
        apt-get install -y -f ./quarto.deb && \
        rm quarto.deb; \
    fi && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install TinyTeX (lightweight TeX Live distribution)
RUN mkdir -p /tinytex-install && chmod 777 /tinytex-install && \
    TMPDIR=/tinytex-install \
    wget -qO- "https://yihui.org/tinytex/install-bin-unix.sh" | TMPDIR=/tinytex-install bash && \
    /root/.TinyTeX/bin/*/tlmgr path add && \
    rm -rf /tinytex-install

# Install Python 3
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create symlinks for python/pip
RUN ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip

# Install Lato font from Google Fonts
RUN mkdir -p /usr/share/fonts/truetype/lato && \
    cd /tmp && \
    wget -q https://github.com/google/fonts/raw/main/ofl/lato/Lato-Regular.ttf && \
    wget -q https://github.com/google/fonts/raw/main/ofl/lato/Lato-Bold.ttf && \
    wget -q https://github.com/google/fonts/raw/main/ofl/lato/Lato-Italic.ttf && \
    wget -q https://github.com/google/fonts/raw/main/ofl/lato/Lato-BoldItalic.ttf && \
    mv *.ttf /usr/share/fonts/truetype/lato/ && \
    fc-cache -fv

# Upgrade pip and install Python packages
COPY config/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir -r /tmp/requirements.txt

# Install R packages
COPY config/packages.R /tmp/packages.R
RUN Rscript /tmp/packages.R

# Install IRkernel for Jupyter (ensure it's installed, then register)
# Use Ncpus=1 for reliability under QEMU emulation during cross-compilation
RUN Rscript -e "if (!requireNamespace('IRkernel', quietly = TRUE)) install.packages('IRkernel', Ncpus = 1L)" && \
    Rscript -e "IRkernel::installspec(user = FALSE)"

# Create default user
RUN useradd -m -s /bin/bash -u 1000 ${DEFAULT_USER} && \
    echo "${DEFAULT_USER}:${DEFAULT_USER}" | chpasswd && \
    mkdir -p /home/${DEFAULT_USER}/work && \
    chown -R ${DEFAULT_USER}:${DEFAULT_USER} /home/${DEFAULT_USER} && \
    echo "${DEFAULT_USER} ALL=(ALL) NOPASSWD: /usr/lib/rstudio-server/bin/rserver" >> /etc/sudoers

# Configure RStudio Server
RUN echo "www-address=0.0.0.0" >> /etc/rstudio/rserver.conf && \
    echo "www-port=8787" >> /etc/rstudio/rserver.conf && \
    echo "auth-none=1" >> /etc/rstudio/rserver.conf && \
    echo "auth-minimum-user-id=0" >> /etc/rstudio/rserver.conf && \
    echo "server-daemonize=0" >> /etc/rstudio/rserver.conf

# Configure JupyterLab settings
RUN mkdir -p /etc/jupyter && \
    mkdir -p /usr/local/share/jupyter/lab/settings

# Copy JupyterLab configuration
COPY config/jupyter_server_config.py /etc/jupyter/jupyter_server_config.py
COPY config/overrides.json /usr/local/share/jupyter/lab/settings/overrides.json
RUN chmod 644 /etc/jupyter/jupyter_server_config.py && \
    chmod 644 /usr/local/share/jupyter/lab/settings/overrides.json

# Create startup script for both services
COPY scripts/start.sh /usr/local/bin/start.sh
RUN chmod 755 /usr/local/bin/start.sh

# Expose ports
EXPOSE 8787 8888

# Default to rstudio user
USER ${DEFAULT_USER}
WORKDIR /home/${DEFAULT_USER}/work

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/start.sh"]
CMD ["both"]
