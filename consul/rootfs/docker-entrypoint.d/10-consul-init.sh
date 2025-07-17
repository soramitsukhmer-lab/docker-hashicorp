#!/bin/sh
set -e

if [[ "${CONSUL_INIT}" != "true" ]]; then
    exit 0
fi

entrypoint_log() {
    if [ -z "${CONSUL_ENTRYPOINT_QUIET_LOGS:-}" ]; then
        echo "$@"
    fi
}

entrypoint_log "$0: Waiting for consul-init..."
while [ ! -f /consul/config/consul-init.hcl ]; do
    sleep 1
done
entrypoint_log "$0: consul-init completed, found /consul/config/consul-init.hcl"
