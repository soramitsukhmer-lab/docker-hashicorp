#!/bin/sh
set -eou pipefail
ME=$(basename "$0")
CONSUL_INIT_CONFIG="/consul/config/consul-init.hcl"

echo "$ME: Initializing Consul configuration..."

if [ -z "${CONSUL_ADVERTISE_INTERFACE:-}" ]; then
  echo "$ME: CONSUL_ADVERTISE_INTERFACE is not set, using default 'eth0'."
  CONSUL_ADVERTISE_INTERFACE=eth0
else
  echo "$ME: Using CONSUL_ADVERTISE_INTERFACE=${CONSUL_ADVERTISE_INTERFACE}."
fi
export CONSUL_ADVERTISE_ADDR=`sockaddr eval 'GetInterfaceIP "'${CONSUL_ADVERTISE_INTERFACE}'"'`

if [[ -n "${CONSUL_ADVERTISE_WAN_INTERFACE}" ]]; then
    echo "$ME: Using CONSUL_ADVERTISE_WAN_INTERFACE=${CONSUL_ADVERTISE_WAN_INTERFACE}."
    export CONSUL_ADVERTISE_ADDR_WAN=`sockaddr eval 'GetInterfaceIP "'${CONSUL_ADVERTISE_WAN_INTERFACE}'"'`
fi

echo "$ME: Writing Consul configuration file to ${CONSUL_INIT_CONFIG}"
/consul-init.sh > "${CONSUL_INIT_CONFIG}"

# Print the configuration file
echo "$ME: Consul configuration file:"
cat "${CONSUL_INIT_CONFIG}" | while read -r line; do
  echo "$ME: - $line"
done

echo "$ME: Done!"
