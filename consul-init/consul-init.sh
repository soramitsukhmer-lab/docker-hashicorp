#!/bin/sh
set -eou pipefail
ME=$(basename "$0")

echo "$ME: Initializing Consul configuration..."

# Evaluate the host advertise address
if [ -z "${CONSUL_ADVERTISE_INTERFACE:-}" ]; then
  echo "$ME: CONSUL_ADVERTISE_INTERFACE is not set, using default 'eth0'."
  CONSUL_ADVERTISE_INTERFACE=eth0
else
  echo "$ME: Using CONSUL_ADVERTISE_INTERFACE=${CONSUL_ADVERTISE_INTERFACE}."
fi
CONSUL_ADVERTISE_ADDR=`sockaddr eval 'GetInterfaceIP "'${CONSUL_ADVERTISE_INTERFACE}'"'`

# Write the configuration file
echo "$ME: Writing Consul configuration file to /consul/config/consul-init.hcl"
cat <<HCL >/consul/config/consul-init.hcl
bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"
advertise_addr = "${CONSUL_ADVERTISE_ADDR}"
HCL

# Print the configuration file
echo "$ME: Consul configuration file:"
cat /consul/config/consul-init.hcl | while read -r line; do
  echo "$ME: - $line"
done

echo "$ME: Done!"
