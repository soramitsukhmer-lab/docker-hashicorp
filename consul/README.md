## About
Consul is a distributed, highly available, and data center aware solution to connect and configure applications across dynamic, distributed infrastructure.

www.consul.io

## Usage

```yml
services:
  consul:
    image: ghcr.io/soramitsukhmer-lab/consul:dev
    command: agent -server -ui -bootstrap-expect=1
    ports:
      - "8300:8300/tcp" # Server RPC
      - "8301:8301/tcp" # LAN Serf
      - "8301:8301/udp" # LAN Serf
      # - "8302:8302/tcp" # WAN Serf (Disabled by default)
      # - "8302:8302/udp" # WAN Serf (Disabled by default)
      - "8500:8500"     # HTTP
      # - "8501:8501/tcp" # HTTPS (Disabled by default)
      # - "8502:8502/tcp" # gRPC
      # - "8503:8503/tcp" # gRPC TLS
      - "8600:8600/tcp" # DNS
      - "8600:8600/udp" # DNS
    volumes:
      - data:/consul/data
      - config:/consul/config

volumes:
  data:
  config:

networks:
  consul:
```
