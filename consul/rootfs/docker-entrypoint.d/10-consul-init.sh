#!/bin/sh
set -e

if [ -z "$CONSUL_CONFIG_DIR" ]; then
  CONSUL_CONFIG_DIR=/consul/config
fi
CONSUL_INIT_CONFIG="${CONSUL_CONFIG_DIR}/consul-init.hcl"

entrypoint_log() {
    if [ -z "${CONSUL_ENTRYPOINT_QUIET_LOGS:-}" ]; then
        echo "$@"
    fi
}

if [[ "${CONSUL_INIT}" != "true" ]]; then
    entrypoint_log "$0: consul-init is not enabled, skipping..."
    exit 0
fi

entrypoint_log "$0: Checking consul-init configuration..."

if [ ! -f "${CONSUL_INIT_CONFIG}" ]; then
    entrypoint_log "$0: consul-init configuration file not found, waiting for consul-init..."
    while [ ! -f "${CONSUL_INIT_CONFIG}" ]; do
        sleep 1
    done
fi

entrypoint_log "$0: consul-init completed, found ${CONSUL_INIT_CONFIG}"
