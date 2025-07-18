#!/bin/sh
set -e

if [ -z "$CONSUL_CONFIG_DIR" ]; then
  CONSUL_CONFIG_DIR=/consul/config
fi
CONSUL_AUTO_DISCOVER_CONFIG="${CONSUL_CONFIG_DIR}/consul-auto-discover.hcl"

entrypoint_log() {
    if [ -z "${CONSUL_ENTRYPOINT_QUIET_LOGS:-}" ]; then
        echo "$@"
    fi
}

if [[ "${CONSUL_AUTO_DISCOVER}" != "true" ]]; then
    entrypoint_log "$0: consul-auto-discover is not enabled, skipping..."
    exit 0
fi

entrypoint_log "$0: Checking consul-auto-discover configuration..."

if [ ! -f "${CONSUL_AUTO_DISCOVER_CONFIG}" ]; then
    entrypoint_log "$0: consul-auto-discover configuration file not found, waiting for consul-auto-discover..."
    while [ ! -f "${CONSUL_AUTO_DISCOVER_CONFIG}" ]; do
        sleep 1
    done
fi

entrypoint_log "$0: consul-auto-discover completed, found ${CONSUL_AUTO_DISCOVER_CONFIG}"
