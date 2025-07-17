#!/bin/sh

echo 'bind_addr = "0.0.0.0"'
echo 'client_addr = "0.0.0.0"'

if [[ -n "${CONSUL_ADVERTISE_ADDR}" ]]; then
  echo "advertise_addr = \"${CONSUL_ADVERTISE_ADDR}\""
fi
