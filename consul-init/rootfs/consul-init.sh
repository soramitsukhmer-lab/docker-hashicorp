#!/bin/sh
set -eo pipefail
ME=$(basename "$0")
CONSUL_INIT_CONFIG="/consul/config/consul-init.hcl"

echo "$ME: Initializing Consul configuration..."

# You can set CONSUL_ADVERTISE_INTERFACE to the name of the interface you'd like to
# advertise to and this will look up the IP and pass the proper -advertise= option along
# to Consul.
if [ -z "$CONSUL_ADVERTISE" ]; then
  if [ -n "$CONSUL_ADVERTISE_INTERFACE" ]; then
    CONSUL_ADVERTISE_ADDRESS=$(ip -o -4 addr list $CONSUL_ADVERTISE_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
    if [ -z "$CONSUL_ADVERTISE_ADDRESS" ]; then
      echo "Could not find IP for interface '$CONSUL_ADVERTISE_INTERFACE', exiting"
      exit 1
    fi

    CONSUL_ADVERTISE="advertise_addr = \"$CONSUL_ADVERTISE_ADDRESS\""
    echo "==> Found address '$CONSUL_ADVERTISE_ADDRESS' for interface '$CONSUL_ADVERTISE_INTERFACE', setting bind option..."
  fi
fi

# You can set CONSUL_ADVERTISE_WAN_INTERFACE to the name of the interface you'd like to
# advertise wan to and this will look up the IP and pass the proper -advertise-wan= option along
# to Consul.
if [ -z "$CONSUL_ADVERTISE_WAN" ]; then
  if [ -n "$CONSUL_ADVERTISE_WAN_INTERFACE" ]; then
    CONSUL_ADVERTISE_WAN_ADDRESS=$(ip -o -4 addr list $CONSUL_ADVERTISE_WAN_INTERFACE | head -n1 | awk '{print $4}' | cut -d/ -f1)
    if [ -z "$CONSUL_ADVERTISE_WAN_ADDRESS" ]; then
      echo "Could not find IP for interface '$CONSUL_ADVERTISE_WAN_INTERFACE', exiting"
      exit 1
    fi

    CONSUL_ADVERTISE_WAN="advertise_addr_wan = \"$CONSUL_ADVERTISE_WAN_ADDRESS\""
    echo "==> Found address '$CONSUL_ADVERTISE_WAN_ADDRESS' for interface '$CONSUL_ADVERTISE_WAN_INTERFACE', setting bind option..."
  fi
fi

echo "$ME: Writing Consul configuration file to ${CONSUL_INIT_CONFIG}"
cat <<CONSUL > "${CONSUL_INIT_CONFIG}"
bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"
${CONSUL_ADVERTISE}
${CONSUL_ADVERTISE_WAN}
CONSUL

# Print the configuration file
echo "$ME: Consul configuration file:"
cat "${CONSUL_INIT_CONFIG}" | while read -r line; do
  if [[ -n "${line}" ]]; then
    echo "$ME: - $line"
  fi
done

echo "$ME: Done!"
