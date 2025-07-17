#!/bin/sh
set -eo pipefail
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
cat <<CONSUL > "${CONSUL_INIT_CONFIG}"
bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"
${CONSUL_ADVERTISE_ADDR:+"advertise_addr = \"${CONSUL_ADVERTISE_ADDR}\""}
${CONSUL_ADVERTISE_ADDR_WAN:+"advertise_addr_wan = \"${CONSUL_ADVERTISE_ADDR_WAN}\""}
CONSUL

# Print the configuration file
echo "$ME: Consul configuration file:"
cat "${CONSUL_INIT_CONFIG}" | while read -r line; do
  echo "$ME: - $line"
done

echo "$ME: Done!"
