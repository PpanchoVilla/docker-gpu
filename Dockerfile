FROM nvidia/cuda:12.6.2-cudnn-devel-ubuntu24.04

# Noninteractive APT
ENV DEBIAN_FRONTEND=noninteractive

# Base tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl wget git vim nano tzdata \
    python3 python3-pip python3-venv python3-dev build-essential \
    libssl-dev libffi-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Configure pip for better download performance
RUN pip config set global.timeout 300 && \
    pip config set global.retries 5 && \
    pip config set global.index-url https://pypi.org/simple/

# Skip pip upgrade (system packages already installed)
# RUN python3 -m pip install --upgrade pip wheel setuptools --break-system-packages

# TensorFlow with CUDA support (pip wheels for cu12) - split into smaller chunks
RUN pip install --no-cache-dir --timeout 300 --retries 5 \
    "tensorflow[and-cuda]==2.18.*" --break-system-packages

RUN pip install --no-cache-dir --timeout 300 --retries 5 \
    "tensorflow-probability~=0.24" --break-system-packages

# JupyterLab and data science stack
RUN pip install --no-cache-dir --timeout 300 --retries 5 \
    jupyterlab notebook ipywidgets \
    numpy scipy pandas matplotlib seaborn scikit-learn \
    tensorboard tensorboard-plugin-profile --break-system-packages

# nvitop and exporter deps
RUN pip install --no-cache-dir --timeout 300 --retries 5 \
    nvitop prometheus-client fastapi uvicorn --break-system-packages

# gpu-monitor (optional, ignore failures)
RUN git clone https://github.com/bigsk1/gpu-monitor /opt/gpu-monitor && \
    pip install --no-cache-dir --timeout 300 --retries 5 \
    -r /opt/gpu-monitor/requirements.txt --break-system-packages || true

# Syncthing (basic)
RUN apt-get update && apt-get install -y --no-install-recommends syncthing && \
    rm -rf /var/lib/apt/lists/*

# Create user and workspace
ARG USERNAME=developer
ARG UID=1001
ARG GID=1001
RUN set -eux; \
    if ! getent group "$GID" >/dev/null; then groupadd -g "$GID" "$USERNAME"; fi; \
    if ! id -u "$USERNAME" >/dev/null 2>&1; then useradd -m -u "$UID" -g "$GID" -s /bin/bash "$USERNAME"; fi
RUN mkdir -p /workspace && chown -R $USERNAME:$USERNAME /workspace
WORKDIR /workspace

# Expose ports: Jupyter 8888, nvitop-exporter 9000
EXPOSE 8888 9000

# Copy entrypoint and supervisor config
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /usr/local/bin/entrypoint.sh

# Install supervisor
RUN apt-get update && apt-get install -y --no-install-recommends supervisor && \
    rm -rf /var/lib/apt/lists/*

ENV JUPYTER_PORT=8888 NVITOP_EXPORTER_PORT=9000
USER $USERNAME
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
