#!/bin/sh
set -eo pipefail
ME=$(basename "$0")

if [ -z "$CONSUL_CONFIG_DIR" ]; then
  CONSUL_CONFIG_DIR=/consul/config
fi
CONSUL_AUTO_DISCOVER_CONFIG="${CONSUL_CONFIG_DIR}/consul-auto-discover.hcl"

# Check if Docker socket is available
# This is necessary for the discover command to work properly.
if [ ! -S "/var/run/docker.sock" ]; then
  echo "$ME: Docker socket not found at /var/run/docker.sock, please mount the Docker socket into the container."
  exit 1
fi

# Check if consul-init configuration already exists
if [ -f "${CONSUL_AUTO_DISCOVER_CONFIG}" ]; then
  # By default, we do not override existing configuration
  # unless CONSUL_AUTO_DISCOVER_CONFIG_OVERRIDE is set to true.
  if [[ -z "${CONSUL_AUTO_DISCOVER_CONFIG_OVERRIDE}" ]]; then
    echo "$ME: Consul auto discover configuration already exists, skipping initialization."
    exit 0
  fi
fi

echo "$ME: Initializing Consul auto discover configuration..."

CONSUL_AUTO_DISCOVER=${CONSUL_AUTO_DISCOVER:-"provider=dockerswarm type=node role=manager"}
CONSUL_AUTO_DISCOVER_ADDRS=`discover -q addrs "${CONSUL_AUTO_DISCOVER}"`

if [ -z "$CONSUL_AUTO_DISCOVER_ADDRS" ]; then
  echo "$ME: No addresses found for Consul auto discover configuration, exiting"
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
rejoin_after_leave = true
HCL

# Print the configuration file
echo "$ME: Consul configuration file:"
cat "${CONSUL_AUTO_DISCOVER_CONFIG}" | while read -r line; do
  if [[ -n "${line}" ]]; then
    echo "$ME: - $line"
  fi
done

echo "$ME: Done!"
