#!/usr/bin/env bash
set -euo pipefail

# Ensure NVIDIA runtime env vars
export NVIDIA_VISIBLE_DEVICES=all
export NVIDIA_DRIVER_CAPABILITIES=all

# Optional: initialize Syncthing config directory
mkdir -p /home/developer/.config/syncthing
chown -R developer:developer /home/developer/.config

# Start supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
