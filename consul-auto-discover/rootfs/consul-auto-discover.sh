#!/bin/sh
set -eo pipefail
ME=$(basename "$0")

if [ -z "$CONSUL_CONFIG_DIR" ]; then
  CONSUL_CONFIG_DIR=/consul/config
fi
CONSUL_AUTO_DISCOVER_CONFIG="${CONSUL_CONFIG_DIR}/consul-auto-discover.hcl"

# Check if CONSUL_AUTO_DISCOVER is enabled
if [[ "${CONSUL_AUTO_DISCOVER}" != "true" ]]; then
    entrypoint_log "$0: consul-auto-discover is not enabled, skipping..."
    exit 0
fi

# If CONSUL_AUTO_DISCOVER_CONFIG_ONCE is set to true, we will skip the initialization
# if the configuration file already exists. This is useful for one-time setups.
if [[ "${CONSUL_AUTO_DISCOVER_CONFIG_ONCE}" == "true" ]]; then
  if [ -f "${CONSUL_AUTO_DISCOVER_CONFIG}" ]; then
    echo "$ME: Consul auto discover configuration already exists, skipping initialization."
    exit 0
  fi
fi

echo "$ME: Initializing Consul auto discover configuration..."

# Check if Docker socket is available
# This is necessary for the discover command to work properly.
if [[ -z "${DOCKER_HOST}" ]]; then
  if [ ! -S "/var/run/docker.sock" ]; then
    echo "$ME: [ERROR] Unable to locate Docker socket at /var/run/docker.sock, please mount the Docker socket into the container."
    exit 1
  fi
fi

CONSUL_AUTO_DISCOVER_OPTS=${CONSUL_AUTO_DISCOVER_OPTS:-"provider=dockerswarm ${DOCKER_HOST:+"host=${DOCKER_HOST}"} type=node ${DOCKER_NODE_ROLE:+"role=${DOCKER_NODE_ROLE}"}"}
CONSUL_AUTO_DISCOVER_ADDRS=`discover -q addrs "${CONSUL_AUTO_DISCOVER_OPTS}"`

if [ -z "$CONSUL_AUTO_DISCOVER_ADDRS" ]; then
  echo "$ME: [ERROR] No addresses found for Consul auto discover configuration, exiting"
  exit 1
fi

# Perform the discovery and prepare the retry_join configuration
CONSUL_RETRY_JOIN="retry_join = ["
for addr in $CONSUL_AUTO_DISCOVER_ADDRS; do
  CONSUL_RETRY_JOIN="${CONSUL_RETRY_JOIN}\"${addr}\", "
  echo "$ME: ==> Found address '$addr' for Consul auto discover configuration, adding to 'retry_join' option..."
done
CONSUL_RETRY_JOIN="${CONSUL_RETRY_JOIN%??}]"  # Remove trailing comma and space

echo "$ME: Writing Consul configuration file to ${CONSUL_AUTO_DISCOVER_CONFIG}"
cat <<HCL > "${CONSUL_AUTO_DISCOVER_CONFIG}"
${CONSUL_RETRY_JOIN}
HCL

# Print the configuration file
echo "$ME: Consul configuration file:"
cat "${CONSUL_AUTO_DISCOVER_CONFIG}" | while read -r line; do
  if [[ -n "${line}" ]]; then
    echo "$ME: - $line"
  fi
done

echo "$ME: Done!"
